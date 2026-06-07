import 'dart:async';

import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/teacher_home_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/token_storage_service.dart';
import 'utils/theme.dart';

void main() {
  runApp(const TeacherFinderApp());
}

class TeacherFinderApp extends StatelessWidget {
  const TeacherFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Finder',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final args = settings.arguments as Map<String, dynamic>?;
          final user = args?['user'] as User?;
          final token = args?['token'] as String?;
          if (user != null && token != null) {
            return MaterialPageRoute(
              builder: (_) => HomeScreen(user: user, token: token),
            );
          }
        }
        if (settings.name == '/teacherHome') {
          final args = settings.arguments as Map<String, dynamic>?;
          final user = args?['user'] as User?;
          final token = args?['token'] as String?;
          if (user != null && token != null) {
            return MaterialPageRoute(
              builder: (_) => TeacherHomeScreen(user: user, token: token),
            );
          }
        }
        if (settings.name == '/admin') {
          final args = settings.arguments as Map<String, dynamic>?;
          final token = args?['token'] as String?;
          if (token != null) {
            return MaterialPageRoute(
              builder: (_) => AdminDashboardScreen(token: token),
            );
          }
        }
        return null;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final token = await AuthService.getToken();
    final user = await TokenStorageService.getUser();

    if (token == null || user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    String nextRoute;
    if (user.role == 'admin') {
      nextRoute = '/admin';
    } else if (user.role == 'teacher') {
      nextRoute = '/teacherHome';
    } else {
      nextRoute = '/home';
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        nextRoute,
        arguments: {'user': user, 'token': token},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0, end: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradientPrimaryToAccent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
                      boxShadow: AppTheme.shadowGlow(AppTheme.primary),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Title
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0, end: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Column(
                children: [
                  Text(
                    'Teacher Finder',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Discover Your Perfect Learning Partner',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Loading Indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
