import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class TeacherBookingsScreen extends StatefulWidget {
  const TeacherBookingsScreen({super.key});

  @override
  State<TeacherBookingsScreen> createState() => _TeacherBookingsScreenState();
}

class _TeacherBookingsScreenState extends State<TeacherBookingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('Authentication token missing');

      final bookings = await BookingService.getTeacherBookings(token: token);
      if (mounted) {
        setState(() {
          _bookings = bookings;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeSession(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Session'),
        content: const Text('Mark this session as completed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Complete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('No token');
      await BookingService.completeBooking(token: token, bookingId: booking.id);
      await _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session marked as completed!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelSession(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Session'),
        content: const Text('Are you sure you want to cancel this session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('No token');
      await BookingService.cancelBooking(token: token, bookingId: booking.id);
      await _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session cancelled'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.success;
      case 'cancelled':
        return AppTheme.danger;
      default:
        return AppTheme.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('My Sessions'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: isDark ? Colors.white : AppTheme.textDarkLight,
      ),
      body: GlowBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.lg),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppTheme.danger),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _bookings.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.event_note_outlined,
                        title: 'No sessions scheduled',
                        description: 'When students book sessions with you, they will appear here.',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(AppTheme.lg),
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final booking = _bookings[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.md),
                              child: ModernCard(
                                hover: false,
                                padding: const EdgeInsets.all(AppTheme.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            booking.studentName ?? 'Student',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppTheme.md,
                                            vertical: AppTheme.xs,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(booking.status).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                            border: Border.all(
                                              color: _statusColor(booking.status).withOpacity(0.2),
                                            ),
                                          ),
                                          child: Text(
                                            booking.status.toUpperCase(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              color: _statusColor(booking.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.md),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.book_outlined,
                                          size: 16,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                        const SizedBox(width: AppTheme.sm),
                                        Text(
                                          booking.subject,
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: AppTheme.lg),
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 16,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                        const SizedBox(width: AppTheme.sm),
                                        Text(
                                          '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year}',
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.xs),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: 16,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                        const SizedBox(width: AppTheme.sm),
                                        Text(
                                          '${booking.durationHours} hours',
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (booking.isScheduled) ...[
                                      const SizedBox(height: AppTheme.sm),
                                      Row(
                                        children: [
                                          Icon(
                                            booking.paymentStatus == 'paid' ? Icons.payment : Icons.payment_outlined,
                                            size: 16,
                                            color: booking.paymentStatus == 'paid' ? AppTheme.success : AppTheme.danger,
                                          ),
                                          const SizedBox(width: AppTheme.sm),
                                          Text(
                                            'Payment Status: ${booking.paymentStatus?.toUpperCase() ?? "UNPAID"}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: booking.paymentStatus == 'paid' ? AppTheme.success : AppTheme.danger,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (booking.isScheduled) ...[
                                      const SizedBox(height: AppTheme.lg),
                                      if (booking.paymentStatus == 'paid') ...[
                                        Row(
                                          children: [
                                            Expanded(
                                              child: PrimaryButton(
                                                onPressed: () => _openJitsiMeet(booking),
                                                icon: Icons.video_call_outlined,
                                                label: 'Join Virtual Class',
                                                backgroundColor: AppTheme.success,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.md),
                                      ] else ...[
                                        Container(
                                          padding: const EdgeInsets.all(AppTheme.md),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: AppTheme.danger.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                          ),
                                          child: const Text(
                                            'Waiting for student payment before classroom is enabled.',
                                            style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: AppTheme.md),
                                      ],
                                      Row(
                                        children: [
                                          Expanded(
                                            child: PrimaryButton(
                                              onPressed: () => _completeSession(booking),
                                              icon: Icons.check,
                                              label: 'Complete',
                                              backgroundColor: AppTheme.success,
                                            ),
                                          ),
                                          const SizedBox(width: AppTheme.md),
                                          Expanded(
                                            child: SecondaryButton(
                                              onPressed: () => _cancelSession(booking),
                                              label: 'Cancel',
                                              borderColor: AppTheme.danger,
                                              textColor: AppTheme.danger,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  void _openJitsiMeet(Booking booking) {
    final jitsiUrl = 'https://meet.jit.si/TeacherFinder_Room_${booking.id.replaceAll("-", "")}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.video_call_outlined, color: AppTheme.success),
            SizedBox(width: 8),
            Text('Virtual Classroom'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your class session is ready to begin! Click below to enter the secure virtual classroom room on Jitsi Meet.'),
            const SizedBox(height: AppTheme.md),
            SelectableText(
              jitsiUrl,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entering classroom...'), backgroundColor: AppTheme.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('Enter Classroom', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
