import 'package:flutter/material.dart';
import '../models/teacher_profile_model.dart';
import '../services/booking_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class BookingScreen extends StatefulWidget {
  final TeacherProfile teacher;
  final String requestId;

  const BookingScreen({
    super.key,
    required this.teacher,
    required this.requestId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  double _duration = 1.0;
  String? _selectedSubject;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.teacher.subjects.isNotEmpty) {
      _selectedSubject = widget.teacher.subjects.first;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('Authentication token missing');

      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await BookingService.createBooking(
        token: token,
        requestId: widget.requestId,
        subject: _selectedSubject!,
        scheduledDate: scheduledDateTime.toIso8601String(),
        durationHours: _duration,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session booked successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cost = widget.teacher.feePerHour * _duration;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Book Session'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: isDark ? Colors.white : AppTheme.textDarkLight,
      ),
      body: GlowBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teacher info header
                GlassCard(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientPrimaryToAccent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          boxShadow: AppTheme.shadowMedium,
                        ),
                        child: Center(
                          child: Text(
                            widget.teacher.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.teacher.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppTheme.xs),
                            Text(
                              '\$${widget.teacher.feePerHour.toStringAsFixed(2)} / hour',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.xl),

                // Subject picker
                Text(
                  'Subject',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.sm),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSubject,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.book_outlined, color: AppTheme.primary),
                  ),
                  items: widget.teacher.subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSubject = val),
                ),
                const SizedBox(height: AppTheme.lg),

                // Date & Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppTheme.sm),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.lg,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                                border: Border.all(
                                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, color: AppTheme.primary, size: 20),
                                  const SizedBox(width: AppTheme.md),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppTheme.sm),
                          InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.lg,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                                border: Border.all(
                                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_outlined, color: AppTheme.secondary, size: 20),
                                  const SizedBox(width: AppTheme.md),
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.lg),

                // Duration slider
                Text(
                  'Duration (hours)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.md, vertical: AppTheme.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                    border: Border.all(
                      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppTheme.primary,
                            thumbColor: AppTheme.primary,
                            overlayColor: AppTheme.primary.withOpacity(0.12),
                          ),
                          child: Slider(
                            value: _duration,
                            min: 0.5,
                            max: 4.0,
                            divisions: 7,
                            label: '${_duration}h',
                            onChanged: (val) => setState(() => _duration = val),
                          ),
                        ),
                      ),
                      Text(
                        '${_duration}h',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.lg),

                // Notes
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.sm),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Any specific topics or requests...',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.xl),

                // Cost summary
                GlassCard(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Cost',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '\$${cost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.xl),

                // Submit button
                PrimaryButton(
                  label: 'Book Session',
                  onPressed: _submitBooking,
                  isLoading: _isSubmitting,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
