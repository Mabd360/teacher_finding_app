import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/teacher_profile_model.dart';
import '../utils/api_constants.dart';
import '../utils/theme.dart';
import '../components/index.dart';
import 'teacher_detail_screen.dart';

class TeacherDiscoveryScreen extends StatefulWidget {
  const TeacherDiscoveryScreen({super.key});

  @override
  State<TeacherDiscoveryScreen> createState() => _TeacherDiscoveryScreenState();
}

class _TeacherDiscoveryScreenState extends State<TeacherDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TeacherProfile> _teachers = [];
  List<TeacherProfile> _filteredTeachers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedSubject = 'All';

  // Dynamic subject list built from API data
  List<String> _subjects = ['All'];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load all teachers from the browse API endpoint
  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.browseTeachersEndpoint),
        headers: ApiConstants.jsonHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final teacherList = data['teachers'] as List<dynamic>;
        final teachers = teacherList
            .map((item) => TeacherProfile.fromJson(item as Map<String, dynamic>))
            .toList();

        // Build dynamic subject filter list
        final subjectSet = <String>{'All'};
        for (final teacher in teachers) {
          subjectSet.addAll(teacher.subjects);
        }

        if (mounted) {
          setState(() {
            _teachers = teachers;
            _filteredTeachers = teachers;
            _subjects = subjectSet.toList();
          });
        }
      } else {
        throw Exception('Failed to load teachers');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
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

  void _filterTeachers() {
    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        final matchesSearch =
            _searchController.text.isEmpty ||
            teacher.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            (teacher.bio ?? '').toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        final matchesSubject =
            _selectedSubject == 'All' ||
            teacher.subjects.any(
              (s) => s.toLowerCase() == _selectedSubject.toLowerCase(),
            );

        return matchesSearch && matchesSubject;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: ModernSearchBar(
              controller: _searchController,
              hintText: 'Search teachers by name, bio...',
              onChanged: (value) => _filterTeachers(),
              onClear: () {
                _searchController.clear();
                _filterTeachers();
              },
            ),
          ),

          // Subject Filter
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final subject = _subjects[index];
                final isSelected = _selectedSubject == subject;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.sm),
                  child: ChoiceChip(
                    label: Text(subject),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSubject = subject;
                        _filterTeachers();
                      });
                    },
                    selectedColor: isDark ? AppTheme.secondary : AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.md),

          // Teacher List
          Expanded(
            child: _isLoading
                ? Center(child: LoadingWidget(label: 'Discovering teachers...'))
                : _errorMessage != null
                    ? Center(
                        child: EmptyStateWidget(
                          icon: Icons.error_outline,
                          title: 'Unable to Load Teachers',
                          description: _errorMessage,
                          actionLabel: 'Retry',
                          onActionPressed: _loadTeachers,
                        ),
                      )
                    : _filteredTeachers.isEmpty
                        ? Center(
                            child: EmptyStateWidget(
                              icon: Icons.search_off_outlined,
                              title: 'No Teachers Found',
                              description: 'Try modifying your search query or subject filters',
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadTeachers,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(AppTheme.lg),
                              child: StaggeredAnimationList(
                                children: _filteredTeachers.map<Widget>((teacher) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: AppTheme.md),
                                    child: _buildTeacherCard(teacher),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(TeacherProfile teacher) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernCard(
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimaryToAccent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Center(
                  child: Text(
                    teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.xs),
                    // Rating display
                    if (teacher.totalReviews > 0)
                      RatingWidget(
                        rating: teacher.averageRating,
                        totalReviews: teacher.totalReviews,
                        starSize: 14,
                      )
                    else
                      Text(
                        'No reviews yet',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.md, vertical: AppTheme.sm),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.success, width: 1),
                ),
                child: Text(
                  '\$${teacher.feePerHour.toStringAsFixed(2)}/hr',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          Wrap(
            spacing: AppTheme.sm,
            runSpacing: AppTheme.sm,
            children: teacher.subjects.map((subject) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.md, vertical: AppTheme.xs),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                ),
                child: Text(
                  subject,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            teacher.bio ?? 'No bio available.',
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.lg),
          PrimaryButton(
            label: 'View Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TeacherDetailScreen(
                    teacher: teacher,
                    hasRequested: false,
                  ),
                ),
              );
            },
            fullWidth: true,
            height: 48,
          ),
        ],
      ),
    );
  }
}
