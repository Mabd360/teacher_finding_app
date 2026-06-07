import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/review_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class ReviewScreen extends StatefulWidget {
  final Booking booking;

  const ReviewScreen({super.key, required this.booking});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('Authentication token missing');

      await ReviewService.submitReview(
        token: token,
        sessionId: widget.booking.id,
        rating: _rating,
        comment: _commentController.text.isEmpty ? null : _commentController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted! Thank you.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
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
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Leave a Review'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTheme.md),
              // Teacher profile header card
              GlassCard(
                padding: const EdgeInsets.all(AppTheme.xl),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientPrimaryToAccent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: AppTheme.shadowMedium,
                      ),
                      child: Center(
                        child: Text(
                          (widget.booking.teacherName ?? 'T')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      widget.booking.teacherName ?? 'Teacher',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Text(
                      widget.booking.subject,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                    Text(
                      '${widget.booking.scheduledDate.day}/${widget.booking.scheduledDate.month}/${widget.booking.scheduledDate.year} · ${widget.booking.durationHours}h',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.xl),

              // Rating selection card
              ModernCard(
                hover: false,
                padding: const EdgeInsets.all(AppTheme.xl),
                child: Column(
                  children: [
                    Text(
                      'How was your session?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final isSelected = starIndex <= _rating;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = starIndex;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: AnimatedScale(
                              scale: isSelected ? 1.15 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              child: Icon(
                                isSelected ? Icons.star : Icons.star_border_outlined,
                                size: 44,
                                color: isSelected ? AppTheme.warning : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      _rating == 0
                          ? 'Tap a star'
                          : _rating <= 2
                              ? 'Could be better'
                              : _rating == 3
                                  ? 'Good'
                                  : _rating == 4
                                      ? 'Very good!'
                                      : 'Excellent!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.lg),

              // Comments input field
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  hintText: 'Share your experience with this teacher...',
                  prefixIcon: Icon(Icons.rate_review_outlined),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: AppTheme.xl),

              // Submit button
              PrimaryButton(
                label: 'Submit Review',
                onPressed: _submitReview,
                isLoading: _isSubmitting,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
