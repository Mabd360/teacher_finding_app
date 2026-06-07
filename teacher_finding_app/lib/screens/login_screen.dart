import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';
import '../models/auth_request_model.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loginRequest = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final authResponse = await AuthService.login(loginRequest);

      // Save token and user data
      await TokenStorageService.saveToken(authResponse.token);
      await TokenStorageService.saveUser(authResponse.user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authResponse.message),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate based on role
        final nextRoute = authResponse.user.role == 'admin'
            ? '/admin'
            : authResponse.user.isTeacher
            ? '/teacherHome'
            : '/home';
        Navigator.of(context).pushReplacementNamed(
          nextRoute,
          arguments: {'user': authResponse.user, 'token': authResponse.token},
        );
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
                    const SizedBox(height: AppTheme.xxxl),
                    _buildHeader(context),
                    const SizedBox(height: AppTheme.xxxl),

                    // Inputs Card
                    GlassCard(
                      padding: const EdgeInsets.all(AppTheme.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Field
                          _buildEmailField(context),
                          const SizedBox(height: AppTheme.lg),

                          // Password Field
                          _buildPasswordField(context),
                          const SizedBox(height: AppTheme.sm),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextPrimaryButton(
                              label: 'Forgot password?',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password recovery coming soon'),
                                  ),
                                );
                              },
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppTheme.xl),

                          // Login Button
                          PrimaryButton(
                            label: 'Sign In',
                            onPressed: _login,
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

                    // Divider
                    _buildDivider(context),
                    const SizedBox(height: AppTheme.xl),

                    // Register Link
                    _buildRegisterLink(context),
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
            Icons.school_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppTheme.xl),
        Text(
          'Teacher Finder',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppTheme.md),
        Text(
          'Find and connect with qualified teachers',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email Address',
        prefixIcon: const Icon(Icons.email_outlined),
        hintText: 'you@example.com',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outlined),
        hintText: '••••••••',
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: textColor.withOpacity(0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
          child: Text(
            'New to Teacher Finder?',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Expanded(
          child: Divider(
            color: textColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextPrimaryButton(
          label: 'Sign up',
          onPressed: () {
            Navigator.of(context).pushNamed('/register');
          },
          fontSize: 14,
        ),
      ],
    );
  }
}
