import 'package:flutter/material.dart';
import '../models/teacher_profile_model.dart';
import '../models/review_model.dart';
import '../services/request_service.dart';
import '../services/review_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class TeacherDetailScreen extends StatefulWidget {
  final TeacherProfile teacher;
  final bool hasRequested;

  const TeacherDetailScreen({
    super.key,
    required this.teacher,
    required this.hasRequested,
  });

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  bool _isLoading = false;
  List<Review> _reviews = [];
  double _averageRating = 0;
  int _totalReviews = 0;
  bool _reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final data = await ReviewService.getTeacherReviews(
        teacherId: widget.teacher.userId,
      );
      if (mounted) {
        setState(() {
          _reviews = data['reviews'] as List<Review>;
          _averageRating = (data['average_rating'] as num).toDouble();
          _totalReviews = (data['total_reviews'] as num).toInt();
          _reviewsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _reviewsLoading = false;
        });
      }
    }
  }

  Future<void> _sendRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication token missing');
      }

      await RequestService.sendRequest(
        token: token,
        teacherId: widget.teacher.userId,
        message: 'I am interested in your teaching services.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request sent to ${widget.teacher.name}!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
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

  String _renderAvailability() {
    final availability = widget.teacher.availability;
    if (availability == null) {
      return 'Availability details not available';
    }

    if (availability is Map<String, dynamic>) {
      if (availability['days'] is List) {
        final days = List<String>.from(availability['days']);
        return days.join(', ');
      }
      if (availability['note'] != null) {
        return availability['note'].toString();
      }
      return availability.toString();
    }

    if (availability is List) {
      return availability
          .map((item) {
            if (item is Map<String, dynamic>) {
              if (item['day'] != null && item['slots'] is List) {
                return '${item['day']}: ${(item['slots'] as List).join(', ')}';
              }
              if (item['note'] != null) {
                return item['note'].toString();
              }
            }
            return item.toString();
          })
          .join('\n');
    }

    return availability.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Teacher Profile'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header profile card
              GlassCard(
                padding: const EdgeInsets.all(AppTheme.xl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientPrimaryToAccent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: AppTheme.shadowMedium,
                      ),
                      child: Center(
                        child: Text(
                          widget.teacher.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Text(
                            widget.teacher.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                          const SizedBox(height: AppTheme.sm),
                          RatingWidget(
                            rating: _averageRating,
                            totalReviews: _totalReviews,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.lg),

              // Info grid (Fee per hour & availability)
              Row(
                children: [
                  Expanded(
                    child: ModernCard(
                      hover: false,
                      padding: const EdgeInsets.all(AppTheme.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.monetization_on_outlined, color: AppTheme.primary, size: 28),
                          const SizedBox(height: AppTheme.sm),
                          Text(
                            'Fee per hour',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Text(
                            '\$${widget.teacher.feePerHour.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.md),
                  Expanded(
                    child: ModernCard(
                      hover: false,
                      padding: const EdgeInsets.all(AppTheme.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_today_outlined, color: AppTheme.secondary, size: 28),
                          const SizedBox(height: AppTheme.sm),
                          Text(
                            'Availability',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Text(
                            widget.teacher.availability != null ? 'Flexible' : 'Not Set',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.lg),

              // Availability details
              ModernCard(
                hover: false,
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teaching Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      _renderAvailability(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.lg),

              // Subjects
              ModernCard(
                hover: false,
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subjects taught',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    Wrap(
                      spacing: AppTheme.sm,
                      runSpacing: AppTheme.sm,
                      children: widget.teacher.subjects.map((subject) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.md,
                            vertical: AppTheme.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.lg),

              // Bio
              ModernCard(
                hover: false,
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biography',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      widget.teacher.bio ?? 'No biography details provided.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.xl),

              // Action button or Request status
              if (widget.hasRequested)
                Container(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(
                      color: AppTheme.success.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppTheme.success, size: 24),
                      const SizedBox(width: AppTheme.md),
                      Expanded(
                        child: Text(
                          'You have already requested this teacher. Check My Requests for updates.',
                          style: TextStyle(
                            color: isDark ? Colors.green.shade300 : Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                PrimaryButton(
                  label: 'Send Request',
                  onPressed: _sendRequest,
                  isLoading: _isLoading,
                  fullWidth: true,
                ),
              const SizedBox(height: AppTheme.xxl),

              // Reviews section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Student Reviews',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_totalReviews > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.md,
                        vertical: AppTheme.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        '$_averageRating ★ · $_totalReviews reviews',
                        style: TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.md),
              if (_reviewsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppTheme.xxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.xxl),
                  child: Center(
                    child: Text(
                      'No reviews yet for this teacher.',
                      style: TextStyle(
                        color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                      ),
                    ),
                  ),
                )
              else
                ...(_reviews.take(5).map((review) => _buildReviewCard(review))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ModernCard(
      hover: false,
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  (review.studentName ?? 'S')[0].toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.studentName ?? 'Student',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (review.subject != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        review.subject!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: AppTheme.warning,
                )),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.md),
            Text(
              review.comment!,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
