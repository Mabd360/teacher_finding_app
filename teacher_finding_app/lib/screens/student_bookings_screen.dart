import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';
import 'review_screen.dart';

class StudentBookingsScreen extends StatefulWidget {
  const StudentBookingsScreen({super.key});

  @override
  State<StudentBookingsScreen> createState() => _StudentBookingsScreenState();
}

class _StudentBookingsScreenState extends State<StudentBookingsScreen> {
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

      final bookings = await BookingService.getStudentBookings(token: token);
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

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('My Bookings'),
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
                        icon: Icons.calendar_today_outlined,
                        title: 'No bookings yet',
                        description: 'Book a session with a teacher to get started!',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(AppTheme.lg),
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final booking = _bookings[index];
                            final totalCost = booking.feePerHour != null
                                ? (booking.feePerHour! * booking.durationHours)
                                : 0.0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.md),
                              child: ModernCard(
                                hover: false,
                                padding: const EdgeInsets.all(AppTheme.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _statusIcon(booking.status),
                                          color: _statusColor(booking.status),
                                          size: 22,
                                        ),
                                        const SizedBox(width: AppTheme.sm),
                                        Expanded(
                                          child: Text(
                                            booking.teacherName ?? 'Teacher',
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
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.xs),
                                    Row(
                                      children: [
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
                                        const SizedBox(width: AppTheme.lg),
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: 16,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                        const SizedBox(width: AppTheme.sm),
                                        Text(
                                          '${booking.durationHours}h',
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (booking.feePerHour != null) ...[
                                      const SizedBox(height: AppTheme.md),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Price',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                            ),
                                          ),
                                          Text(
                                            '\$${totalCost.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primary,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
                                            'Payment: ${booking.paymentStatus?.toUpperCase() ?? "UNPAID"}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: booking.paymentStatus == 'paid' ? AppTheme.success : AppTheme.danger,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: AppTheme.md),
                                    Row(
                                      children: [
                                        if (booking.isScheduled && booking.paymentStatus != 'paid') ...[
                                          Expanded(
                                            child: PrimaryButton(
                                              label: 'Pay Now',
                                              onPressed: () => _payMock(booking),
                                              backgroundColor: AppTheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: AppTheme.md),
                                        ],
                                        if (booking.isScheduled && booking.paymentStatus == 'paid') ...[
                                          Expanded(
                                            child: PrimaryButton(
                                              label: 'Join Class',
                                              onPressed: () => _openJitsiMeet(booking),
                                              backgroundColor: AppTheme.success,
                                              icon: Icons.video_call_outlined,
                                            ),
                                          ),
                                          const SizedBox(width: AppTheme.md),
                                        ],
                                        if (booking.isScheduled)
                                          Expanded(
                                            child: SecondaryButton(
                                              label: 'Cancel',
                                              onPressed: () => _cancelBooking(booking),
                                              borderColor: AppTheme.danger,
                                              textColor: AppTheme.danger,
                                            ),
                                          ),
                                        if (booking.isCompleted && !booking.hasReview) ...[
                                          Expanded(
                                            child: PrimaryButton(
                                              onPressed: () async {
                                                await Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => ReviewScreen(booking: booking),
                                                  ),
                                                );
                                                _loadBookings();
                                              },
                                              icon: Icons.star_outline,
                                              label: 'Leave Review',
                                              backgroundColor: AppTheme.warning,
                                            ),
                                          ),
                                        ],
                                        if (booking.isCompleted && booking.hasReview)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppTheme.md,
                                              vertical: AppTheme.sm,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.success.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check_circle_outline, color: AppTheme.success, size: 16),
                                                const SizedBox(width: AppTheme.xs),
                                                Text(
                                                  'Reviewed',
                                                  style: TextStyle(
                                                    color: AppTheme.success,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
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

  Future<void> _payMock(Booking booking) async {
    final cardController = TextEditingController(text: "4242 4242 4242 4242");
    final expiryController = TextEditingController(text: "12/28");
    final cvcController = TextEditingController(text: "123");

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulated Stripe Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Amount to Pay: \$${(booking.feePerHour! * booking.durationHours).toStringAsFixed(2)}'),
            const SizedBox(height: AppTheme.md),
            TextField(
              controller: cardController,
              decoration: const InputDecoration(labelText: 'Card Number', prefixIcon: Icon(Icons.credit_card)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTheme.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryController,
                    decoration: const InputDecoration(labelText: 'Expiry Date'),
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: TextField(
                    controller: cvcController,
                    decoration: const InputDecoration(labelText: 'CVC'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('No token');
      await BookingService.payBooking(token: token, bookingId: booking.id);
      await _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Class Scheduled.'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: $e'), backgroundColor: AppTheme.danger),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
