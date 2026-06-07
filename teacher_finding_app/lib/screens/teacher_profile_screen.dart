/// Teacher Profile Screen
/// Allows teachers to create and update their profile
/// Form includes: subjects, fee per hour, availability, and bio
/// Sends data to backend with JWT token authentication
library;

import 'package:flutter/material.dart';
import '../models/teacher_profile_model.dart';
import '../services/teacher_api_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class TeacherProfileScreen extends StatefulWidget {
  /// JWT token from authentication
  final String token;

  /// Optional: existing profile to edit (null for new profile)
  final TeacherProfile? existingProfile;

  const TeacherProfileScreen({
    super.key,
    required this.token,
    this.existingProfile,
  });

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Loading state for submit button
  bool _isLoading = false;
  bool _isFetchingProfile = true;
  TeacherProfile? _existingProfile;

  // Text controllers for form fields
  late TextEditingController _subjectsController;
  late TextEditingController _feeController;
  late TextEditingController _availabilityController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _existingProfile = widget.existingProfile;
      _isFetchingProfile = false;
      _initializeControllers();
    } else {
      _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await TeacherApiService.getMyProfile(token: widget.token);
      if (mounted) {
        setState(() {
          _existingProfile = profile;
          _isFetchingProfile = false;
        });
        _initializeControllers();
      }
    } catch (_) {
      // Profile does not exist, safe to create a new one
      if (mounted) {
        setState(() {
          _isFetchingProfile = false;
        });
        _initializeControllers();
      }
    }
  }

  /// Initialize text controllers with existing data or empty values
  void _initializeControllers() {
    if (_existingProfile != null) {
      // Edit existing profile - pre-fill form with current data
      _subjectsController = TextEditingController(
        text: _existingProfile!.subjects.join(', '),
      );
      _feeController = TextEditingController(
        text: _existingProfile!.feePerHour.toString(),
      );
      
      // Parse availability note safely
      String availabilityText = '';
      if (_existingProfile!.availability != null) {
        if (_existingProfile!.availability is Map && _existingProfile!.availability!['note'] != null) {
          availabilityText = _existingProfile!.availability!['note'].toString();
        } else {
          availabilityText = _existingProfile!.availability.toString();
        }
      }
      
      _availabilityController = TextEditingController(
        text: availabilityText,
      );
      _bioController = TextEditingController(
        text: _existingProfile!.bio ?? '',
      );
    } else {
      // New profile - empty controllers
      _subjectsController = TextEditingController();
      _feeController = TextEditingController();
      _availabilityController = TextEditingController();
      _bioController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _subjectsController.dispose();
    _feeController.dispose();
    _availabilityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// Parse comma-separated subjects into a list
  /// Example: "Math, Physics, Chemistry" -> ["Math", "Physics", "Chemistry"]
  List<String> _parseSubjects(String input) {
    return input
        .split(',')
        .map((subject) => subject.trim())
        .where((subject) => subject.isNotEmpty)
        .toList();
  }

  /// Handle form submission - create or update profile
  Future<void> _submitProfile() async {
    // Validate form before submission
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse form inputs
      final subjects = _parseSubjects(_subjectsController.text);
      final feePerHour = double.parse(_feeController.text);
      final bio = _bioController.text.isEmpty ? null : _bioController.text;

      // Parse availability - for now accept as plain text
      // In production, use a date/time picker for better UX
      final availability = _availabilityController.text.isEmpty
          ? null
          : {'note': _availabilityController.text};

      TeacherProfile? result;

      if (_existingProfile != null) {
        // UPDATE existing profile
        result = await TeacherApiService.updateProfile(
          token: widget.token,
          subjects: subjects,
          feePerHour: feePerHour,
          availability: availability,
          bio: bio,
        );

        if (mounted) {
          setState(() {
            _existingProfile = result;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // CREATE new profile
        result = await TeacherApiService.createProfile(
          token: widget.token,
          subjects: subjects,
          feePerHour: feePerHour,
          availability: availability,
          bio: bio,
        );

        if (mounted) {
          setState(() {
            _existingProfile = result;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Profile created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Optional: Navigate back or show profile
          Navigator.of(context).pop(result);
        }
      }
    } on FormatException {
      // Invalid number format for fee
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✗ Please enter a valid fee amount'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Display error from API or network
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✗ Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingProfile != null;

    if (_isFetchingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Profile' : 'Create Profile'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: false,
          foregroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(child: LoadingWidget(label: 'Loading profile...')),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Create Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: FadeInPageTransition(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  title: isEditing ? 'Workspace settings' : 'Get Started',
                  subtitle: 'Set up your hourly rate, availability, and biography.',
                ),
                const SizedBox(height: AppTheme.xl),
                
                GlassCard(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== SUBJECTS FIELD =====
                      const Text(
                        'Subjects You Teach',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      TextFormField(
                        controller: _subjectsController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Math, Physics, Chemistry',
                          prefixIcon: Icon(Icons.school_outlined),
                          helperText: 'Enter subjects separated by commas',
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter at least one subject';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.xl),

                      // ===== FEE PER HOUR FIELD =====
                      const Text(
                        'Fee Per Hour (\$)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      TextFormField(
                        controller: _feeController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., 25.50',
                          prefixIcon: Icon(Icons.attach_money_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your hourly fee';
                          }
                          try {
                            final fee = double.parse(value);
                            if (fee < 0) {
                              return 'Fee must be a positive number';
                            }
                          } catch (e) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.xl),

                      // ===== AVAILABILITY FIELD =====
                      const Text(
                        'Availability',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      TextFormField(
                        controller: _availabilityController,
                        decoration: const InputDecoration(
                          hintText: 'e.g., Mon-Fri 9-12, Wed 14-17',
                          prefixIcon: Icon(Icons.schedule_outlined),
                          helperText: 'Enter your available teaching hours',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your availability';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.xl),

                      // ===== BIO FIELD =====
                      const Text(
                        'Bio / About You',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          hintText: 'Tell students about your experience and teaching style',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 5,
                        maxLength: 500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.xxl),

                // ===== SUBMIT BUTTON =====
                PrimaryButton(
                  label: isEditing ? 'Update Profile' : 'Create Profile',
                  onPressed: _submitProfile,
                  isLoading: _isLoading,
                  isEnabled: !_isLoading,
                  height: 56,
                  fullWidth: true,
                ),
                const SizedBox(height: AppTheme.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
