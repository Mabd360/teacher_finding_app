import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/teacher_requests_screen.dart';
import '../screens/teacher_bookings_screen.dart';
import '../screens/teacher_profile_screen.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class TeacherHomeScreen extends StatefulWidget {
  final User user;
  final String token;

  const TeacherHomeScreen({required this.user, required this.token, super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  bool _isLoggingOut = false;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final latestUser = await AuthService.getCurrentUser(widget.token);
      await TokenStorageService.saveUser(latestUser);
      if (mounted) {
        setState(() {
          _currentUser = latestUser;
        });
      }
    } catch (e) {
      debugPrint('Error checking user status: $e');
    }
  }

  bool get _isMissingVerification =>
      _currentUser.phone == null ||
      _currentUser.cnicFront == null ||
      _currentUser.cnicBack == null;

  void _showVerificationForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VerificationSheet(
        token: widget.token,
        onComplete: (updatedUser) {
          setState(() {
            _currentUser = updatedUser;
          });
          _checkVerificationStatus();
        },
      ),
    );
  }

  Widget _buildVerificationBanner() {
    if (!_isMissingVerification) {
      if (!_currentUser.isVerified) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.md),
          margin: const EdgeInsets.only(bottom: AppTheme.md),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.hourglass_empty_outlined, color: AppTheme.warning),
              SizedBox(width: AppTheme.md),
              Expanded(
                child: Text(
                  'Verification Pending: Your documents are currently under review by our administration.',
                  style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: _showVerificationForm,
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
            const SizedBox(width: AppTheme.md),
            const Expanded(
              child: Text(
                'Action Required: Please complete your verification profile with CNIC Front & Back documents to accept session bookings.',
                style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Icon(Icons.arrow_forward_ios_outlined, size: 16, color: AppTheme.danger),
          ],
        ),
      ),
    );
  }


  Future<void> _signOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      setState(() {
        _isLoggingOut = true;
      });
      await AuthService.logout();
      await TokenStorageService.clearAuthData();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Workspace'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _isLoggingOut ? null : _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FadeInPageTransition(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            _buildVerificationBanner(),
            // Welcome Header
            ProfileHeader(
              name: _currentUser.name,
              subtitle: 'Manage your profile and student interactions',
              imageUrl: null,
            ),

              const SizedBox(height: AppTheme.xl),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Account Status',
                      value: _currentUser.isVerified ? 'Verified' : (_isMissingVerification ? 'Incomplete' : 'Pending'),
                      icon: _currentUser.isVerified ? Icons.check_circle_outline : Icons.info_outline,
                      iconColor: _currentUser.isVerified ? AppTheme.success : (_isMissingVerification ? AppTheme.danger : AppTheme.warning),
                    ),
                  ),
                  const SizedBox(width: AppTheme.lg),
                  Expanded(
                    child: StatCard(
                      label: 'Role',
                      value: 'Teacher',
                      icon: Icons.school_outlined,
                      iconColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.xxl),

              // Actions
              SectionHeader(
                title: 'Quick Actions',
                subtitle: 'Workspace tools and shortcuts',
              ),
              const SizedBox(height: AppTheme.lg),

              StaggeredAnimationList(
                children: [
                  _buildActionCard(
                    icon: Icons.person_outline,
                    title: 'Manage Profile',
                    description: 'Configure pricing, subjects, and bio',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TeacherProfileScreen(token: widget.token),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.md),
                  _buildActionCard(
                    icon: Icons.message_outlined,
                    title: 'Student Requests',
                    description: 'Respond to student lesson inquiries',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TeacherRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.md),
                  _buildActionCard(
                    icon: Icons.event_note_outlined,
                    title: 'My Sessions',
                    description: 'View and track your booking calendar',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TeacherBookingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(width: AppTheme.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppTheme.xs),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
