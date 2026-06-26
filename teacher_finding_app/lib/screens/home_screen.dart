import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/token_storage_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../components/index.dart' hide GlassCard;
import '../components/glass_widgets.dart';
import 'search_screen.dart';
import 'student_requests_screen.dart';
import 'student_bookings_screen.dart';
import 'teacher_requests_screen.dart';
import 'teacher_bookings_screen.dart';
import 'teacher_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final String token;

  const HomeScreen({super.key, required this.user, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late User _currentUser;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _checkVerificationStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screens = _buildScreens();
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final latestUser = await AuthService.getCurrentUser(widget.token);
      await TokenStorageService.saveUser(latestUser);
      if (mounted) {
        setState(() {
          _currentUser = latestUser;
          _screens = _buildScreens();
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
            _screens = _buildScreens();
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
                'Action Required: Please complete your verification profile with CNIC Front & Back documents to book classes.',
                style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Icon(Icons.arrow_forward_ios_outlined, size: 16, color: AppTheme.danger),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    if (_currentUser.isTeacher) {
      return [
        _buildTeacherHome(),
        TeacherProfileScreen(token: widget.token),
        _buildProfileScreen(),
      ];
    } else {
      return [_buildStudentHome(), const SearchScreen(), _buildProfileScreen()];
    }
  }

  Widget _buildTeacherHome() {
    return FadeInPageTransition(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVerificationBanner(),
            // Welcome Header
            ProfileHeader(
              name: _currentUser.name,
              subtitle: 'Teacher Dashboard',
              imageUrl: null,
              backgroundColor: null,
            ),

            const SizedBox(height: AppTheme.xl),

            // Quick Actions
            SectionHeader(
              title: 'Quick Actions',
              subtitle: 'Manage your teaching profile and sessions',
            ),
            const SizedBox(height: AppTheme.lg),
            _buildActionCard(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              description: 'Update your teaching details',
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            const SizedBox(height: AppTheme.md),
            _buildActionCard(
              icon: Icons.calendar_month_outlined,
              title: 'View Schedule',
              description: 'Manage your availability',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Schedule feature coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppTheme.md),
            _buildActionCard(
              icon: Icons.mail_outline,
              title: 'Student Requests',
              description: 'View and respond to inquiries',
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
              icon: Icons.event_outlined,
              title: 'My Sessions',
              description: 'View your teaching sessions',
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
      ),
    );
  }

  Widget _buildStudentHome() {
    return FadeInPageTransition(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildVerificationBanner(),
            // Welcome Header
            ProfileHeader(
              name: _currentUser.name,
              subtitle: 'Find your perfect teacher',
              imageUrl: null,
              backgroundColor: null,
            ),

            const SizedBox(height: AppTheme.xl),

            // Quick Actions
            SectionHeader(
              title: 'Explore',
              subtitle: 'What would you like to do today?',
            ),
            const SizedBox(height: AppTheme.lg),
            _buildActionCard(
              icon: Icons.search_outlined,
              title: 'Find Teachers',
              description: 'Browse qualified teachers',
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            const SizedBox(height: AppTheme.md),
            _buildActionCard(
              icon: Icons.calendar_today_outlined,
              title: 'My Bookings',
              description: 'View your scheduled sessions',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StudentBookingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppTheme.md),
            _buildActionCard(
              icon: Icons.mark_email_unread_outlined,
              title: 'My Requests',
              description: 'Track your lesson requests',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StudentRequestsScreen(),
                  ),
                );
              },
            ),
          ],
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

  Widget _buildProfileScreen() {
    return FadeInPageTransition(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppTheme.xl),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimaryToAccent,
                borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
                boxShadow: AppTheme.shadowLarge,
              ),
              child: Center(
                child: Text(
                  _currentUser.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.xl),

            // User Info
            Text(
              _currentUser.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.md),
            Text(
              _currentUser.email,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.lg),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.lg,
                vertical: AppTheme.md,
              ),
              decoration: BoxDecoration(
                color: _currentUser.isTeacher
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: _currentUser.isTeacher
                      ? AppTheme.success
                      : AppTheme.info,
                ),
              ),
              child: Text(
                _currentUser.role.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _currentUser.isTeacher
                      ? AppTheme.success
                      : AppTheme.info,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.xxxl),

            // Account Settings Section
            SectionHeader(
              title: 'Account Settings',
              subtitle: 'Manage your account preferences',
            ),
            const SizedBox(height: AppTheme.lg),
            ModernCard(
              padding: const EdgeInsets.all(AppTheme.lg),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.person_outline,
                    label: 'Edit Profile',
                    onTap: () {
                      if (_currentUser.isTeacher) {
                        setState(() {
                          _currentIndex = 1;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Student profile editing is managed via verification. Basic info editing coming soon!'),
                          ),
                        );
                      }
                    },
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    height: 1,
                    thickness: 1,
                  ),
                  _buildSettingItem(
                    icon: Icons.security_outlined,
                    label: 'Security Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Security settings coming soon'),
                        ),
                      );
                    },
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    height: 1,
                    thickness: 1,
                  ),
                  _buildSettingItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification settings coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.xxxl),

            // Logout Button
            SecondaryButton(
              label: 'Logout',
              onPressed: _logout,
              icon: Icons.logout_outlined,
              fullWidth: true,
            ),
            const SizedBox(height: AppTheme.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: AppTheme.lg),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 16,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
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
      await TokenStorageService.clearAuthData();
      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    if (_currentUser.isTeacher) {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Profile'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ];
    } else {
      return [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Find Teachers',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ];
    }
  }


  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Teacher Finder'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: ResponsiveCenter(
        maxWidth: 800,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0x9A0A0B14), // Glass background for navigation bar
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _buildNavItems(),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
