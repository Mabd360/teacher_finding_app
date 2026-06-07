import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/auth_request_model.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_cnicFrontImage == null || _cnicBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both CNIC Front and Back pictures for authentication'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final frontBytes = await _cnicFrontImage!.readAsBytes();
      final frontBase64 = base64Encode(frontBytes);

      final backBytes = await _cnicBackImage!.readAsBytes();
      final backBase64 = base64Encode(backBytes);

      final registerRequest = RegisterRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        cnicFront: frontBase64,
        cnicBack: backBase64,
      );

      await AuthService.register(registerRequest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful. Please sign in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: GlowBackground(
        child: SafeArea(
          child: FadeInPageTransition(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.xl,
                vertical: AppTheme.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(context),
                    const SizedBox(height: AppTheme.xxxl),

                    // Inputs Card
                    GlassCard(
                      padding: const EdgeInsets.all(AppTheme.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name Field
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outlined),
                              hintText: 'John Doe',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.lg),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: 'you@example.com',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.lg),

                          // Phone Field
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              hintText: '+92 300 1234567',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length < 7) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.lg),

                          // Role Selection
                          _buildRoleSelector(context),
                          const SizedBox(height: AppTheme.lg),

                          // CNIC Pictures Field
                          ModernCard(
                            padding: const EdgeInsets.all(AppTheme.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CNIC Front Verification Picture',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: AppTheme.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _cnicFrontImage == null
                                          ? Text(
                                              'No CNIC Front picture selected',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : Text(
                                              'Selected: ${_cnicFrontImage!.name}',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: AppTheme.success,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final XFile? image = await _picker.pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 50,
                                        );
                                        if (image != null) {
                                          setState(() {
                                            _cnicFrontImage = image;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.image_outlined),
                                      label: Text(_cnicFrontImage == null ? 'Browse' : 'Change'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                                        foregroundColor: AppTheme.primary,
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.lg),
                                Text(
                                  'CNIC Back Verification Picture',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: AppTheme.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _cnicBackImage == null
                                          ? Text(
                                              'No CNIC Back picture selected',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : Text(
                                              'Selected: ${_cnicBackImage!.name}',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: AppTheme.success,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final XFile? image = await _picker.pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 50,
                                        );
                                        if (image != null) {
                                          setState(() {
                                            _cnicBackImage = image;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.image_outlined),
                                      label: Text(_cnicBackImage == null ? 'Browse' : 'Change'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                                        foregroundColor: AppTheme.primary,
                                        elevation: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.lg),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              hintText: '••••••••',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.lg),

                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              hintText: '••••••••',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.xl),

                          // Register Button
                          PrimaryButton(
                            label: 'Create Account',
                            onPressed: _register,
                            isLoading: _isLoading,
                            isEnabled: !_isLoading,
                            height: 56,
                            fullWidth: true,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.xl),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextPrimaryButton(
                          label: 'Sign in',
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/login');
                          },
                          fontSize: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.gradientPrimaryToAccent,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppTheme.shadowGlow(AppTheme.primary),
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.xl),
        Text(
          'Join Teacher Finder',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppTheme.md),
        Text(
          'Create your account and start learning',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ModernCard(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'I am a...',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppTheme.md),
          Row(
            children: [
              Expanded(
                child: _buildRoleOption(
                  context,
                  value: 'student',
                  label: 'Student',
                  icon: Icons.school_outlined,
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: _buildRoleOption(
                  context,
                  value: 'teacher',
                  label: 'Teacher',
                  icon: Icons.person_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedRole == value;
    final bgColor = isSelected
        ? AppTheme.primary.withOpacity(0.2)
        : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);
    final borderColor = isSelected ? AppTheme.primary : Colors.transparent;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : null,
              size: 32,
            ),
            const SizedBox(height: AppTheme.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color:
                        isSelected ? AppTheme.primary : null,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
