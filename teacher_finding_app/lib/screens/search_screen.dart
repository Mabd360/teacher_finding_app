import 'dart:async';

import 'package:flutter/material.dart';
import '../models/teacher_profile_model.dart';
import '../services/request_service.dart';
import '../services/search_api_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';
import 'teacher_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _maxFeeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _debounceTimer;
  bool _isLoading = false;
  List<TeacherProfile> _teachers = [];
  String? _errorMessage;
  final Set<String> _requestedTeacherIds = {};

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _subjectController.dispose();
    _maxFeeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadRequestedTeacherIds();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_subjectController.text.trim().isNotEmpty) {
        _searchTeachers();
      } else {
        setState(() {
          _teachers = [];
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _loadRequestedTeacherIds() async {
    try {
      final token = await TokenStorageService.getToken();
      if (token == null) return;
      final requests = await RequestService.getStudentRequests(token: token);
      if (mounted) {
        setState(() {
          _requestedTeacherIds.addAll(
            requests
                .where((request) => request.teacherId != null)
                .map((request) => request.teacherId!),
          );
        });
      }
    } catch (_) {
      // Ignore; request status is optional.
    }
  }

  Future<void> _searchTeachers() async {
    if (_subjectController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Enter a subject to search';
        _teachers = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _teachers = [];
    });

    try {
      final subject = _subjectController.text.trim();
      final maxFee = _maxFeeController.text.isEmpty
          ? null
          : double.tryParse(_maxFeeController.text);

      final results = await SearchApiService.searchTeachers(
        subject: subject,
        maxFee: maxFee,
      );

      if (mounted) {
        setState(() {
          _teachers = results;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Teachers'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: GlowBackground(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: GlassCard(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _subjectController,
                        onChanged: (_) => _onSearchChanged(),
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          hintText: 'e.g. Math, Physics',
                          prefixIcon: Icon(Icons.search_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a subject to search';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppTheme.md),
                      TextFormField(
                        controller: _maxFeeController,
                        onChanged: (_) => _onSearchChanged(),
                        decoration: const InputDecoration(
                          labelText: 'Max fee',
                          hintText: 'Optional maximum hourly fee',
                          prefixIcon: Icon(Icons.attach_money_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed < 0) {
                            return 'Enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.lg),
                      PrimaryButton(
                        label: 'Search',
                        onPressed: _searchTeachers,
                        isLoading: _isLoading,
                        isEnabled: !_isLoading,
                        height: 48,
                        fullWidth: true,
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        'Results update automatically while you type.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.lg),
              if (_isLoading)
                Expanded(
                  child: Center(child: LoadingWidget(label: 'Searching teachers...')),
                )
              else if (_errorMessage != null)
                Expanded(
                  child: Center(
                    child: EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Search Error',
                      description: _errorMessage,
                    ),
                  ),
                )
              else if (_teachers.isEmpty)
                const Expanded(
                  child: Center(
                    child: EmptyStateWidget(
                      icon: Icons.search_outlined,
                      title: 'Find Teachers',
                      description: 'Search for teachers by subject or fee limit to see matching results.',
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: StaggeredAnimationList(
                      children: _teachers.map<Widget>((teacher) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.md),
                          child: _buildTeacherCard(teacher),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Text(
                      teacher.subjects.join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppTheme.md),
                    if (_requestedTeacherIds.contains(teacher.userId))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.md, vertical: AppTheme.xs),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: AppTheme.primary, width: 1),
                        ),
                        child: const Text(
                          'Request sent',
                          style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.md, vertical: AppTheme.xs),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(color: AppTheme.success, width: 1),
                        ),
                        child: const Text(
                          'Available to request',
                          style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Text(
                '\$${teacher.feePerHour.toStringAsFixed(2)} / hr',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.lg),
          PrimaryButton(
            label: 'View Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TeacherDetailScreen(
                    teacher: teacher,
                    hasRequested: _requestedTeacherIds.contains(
                      teacher.userId,
                    ),
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
