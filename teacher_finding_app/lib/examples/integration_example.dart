/// Example: How to use TeacherProfileScreen in your app
/// This demonstrates integration with navigation and authentication
library;

import 'package:flutter/material.dart';
import '../screens/teacher_profile_screen.dart';

/// Example usage in a StatelessWidget or StatefulWidget
/// You would typically navigate to this from a menu or dashboard

class TeacherDashboard extends StatelessWidget {
  /// JWT token from authentication (obtained from login)
  final String jwtToken;

  const TeacherDashboard({super.key, required this.jwtToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Teacher!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to profile creation screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TeacherProfileScreen(
                      token: jwtToken,
                      existingProfile: null, // null = create new profile
                    ),
                  ),
                );
              },
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example: Navigation from Login Screen
/// After successful login, store the token and navigate to TeacherProfileScreen

class NavigationExample {
  /// Called after successful authentication
  static void navigateAfterLogin(
    BuildContext context,
    String jwtToken,
    String userRole,
  ) {
    if (userRole == 'teacher') {
      // Navigate to teacher profile screen for teachers
      Navigator.of(
        context,
      ).pushReplacementNamed('/teacher-profile', arguments: jwtToken);
    } else if (userRole == 'student') {
      // Navigate to student dashboard for students
      Navigator.of(
        context,
      ).pushReplacementNamed('/student-dashboard', arguments: jwtToken);
    }
  }
}
