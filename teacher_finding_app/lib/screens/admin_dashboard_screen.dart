import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../services/token_storage_service.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';
import '../utils/api_constants.dart';


class AdminDashboardScreen extends StatefulWidget {
  final String token;

  const AdminDashboardScreen({super.key, required this.token});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String? _error;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await AdminService.getDashboardStats(widget.token);
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: LoadingWidget(label: 'Loading dashboard...'))
          : _error != null
          ? FadeInPageTransition(
              child: Center(
                child: EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Unable to Load Dashboard',
                  description: _error,
                  actionLabel: 'Retry',
                  onActionPressed: _loadDashboard,
                  iconColor: AppTheme.danger,
                ),
              ),
            )
          : FadeInPageTransition(child: _buildTabbedContent()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: 'Teachers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            label: 'Verify',
          ),
        ],
      ),
    );
  }

  Widget _buildTabbedContent() {
    switch (_currentTab) {
      case 0:
        return _buildDashboard();
      case 1:
        return const AdminTeachersScreen();
      case 2:
        return const AdminStudentsScreen();
      case 3:
        return const AdminPaymentsScreen();
      case 4:
        return AdminVerificationScreen(token: widget.token);
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    if (_stats == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          SectionHeader(
            title: 'Platform Overview',
            subtitle: 'Real-time statistics and insights',
          ),
          const SizedBox(height: AppTheme.xl),

          // Key Metrics - 2 Column Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Teachers',
                  value: '${_stats!['total_teachers'] ?? 0}',
                  icon: Icons.school_outlined,
                  iconColor: AppTheme.info,
                  backgroundColor: null,
                  trend: '+${(_stats!['teachers_this_month'] ?? 0)}',
                  trendColor: AppTheme.success,
                ),
              ),
              const SizedBox(width: AppTheme.lg),
              Expanded(
                child: StatCard(
                  label: 'Total Students',
                  value: '${_stats!['total_students'] ?? 0}',
                  icon: Icons.group_outlined,
                  iconColor: AppTheme.secondary,
                  backgroundColor: null,
                  trend: '+${(_stats!['students_this_month'] ?? 0)}',
                  trendColor: AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.lg),

          // Activity Metrics
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Requests',
                  value: '${_stats!['total_requests'] ?? 0}',
                  icon: Icons.mail_outline_outlined,
                  iconColor: AppTheme.warning,
                  backgroundColor: null,
                  trend: '${_stats!['pending_requests'] ?? 0} pending',
                  trendColor: AppTheme.warning,
                ),
              ),
              const SizedBox(width: AppTheme.lg),
              Expanded(
                child: StatCard(
                  label: 'Platform Revenue',
                  value: _formatCurrency(_stats!['total_revenue']),
                  icon: Icons.trending_up_outlined,
                  iconColor: AppTheme.success,
                  backgroundColor: null,
                  trend: 'This period',
                  trendColor: AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.xxl),

          // Financial Summary
          SectionHeader(title: 'Financial Summary'),
          const SizedBox(height: AppTheme.lg),
          ModernCard(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Column(
              children: [
                _buildFinancialRow(
                  'Total Revenue',
                  _formatCurrency(_stats!['total_revenue']),
                  AppTheme.success,
                ),
                Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  height: AppTheme.xl,
                ),
                _buildFinancialRow(
                  'Pending Payments',
                  _formatCurrency(_stats!['pending_payments']),
                  AppTheme.warning,
                ),
                Divider(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  height: AppTheme.xl,
                ),
                _buildFinancialRow('System Commission', '15%', AppTheme.info),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '\$0.00';
    try {
      final num numValue = value is num
          ? value
          : double.parse(value.toString());
      return '\$${numValue.toStringAsFixed(2)}';
    } catch (e) {
      return '\$0.00';
    }
  }
}

// ============================================================================
// ADMIN TEACHERS SCREEN
// ============================================================================

class AdminTeachersScreen extends StatefulWidget {
  const AdminTeachersScreen({super.key});

  @override
  State<AdminTeachersScreen> createState() => _AdminTeachersScreenState();
}

class _AdminTeachersScreenState extends State<AdminTeachersScreen> {
  bool _isLoading = true;
  List<dynamic> _teachers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('No auth token');
      final teachers = await AdminService.getTeachers(token);
      setState(() {
        _teachers = teachers;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: LoadingWidget(label: 'Loading teachers...'))
        : _error != null
        ? Center(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error Loading Teachers',
              description: _error,
            ),
          )
        : _teachers.isEmpty
        ? Center(
            child: EmptyStateWidget(
              icon: Icons.school_outlined,
              title: 'No Teachers Yet',
              description: 'Teachers will appear here once they register',
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: StaggeredAnimationList(
              children: _teachers.map<Widget>((teacher) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.md),
                  child: ModernCard(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppTheme.gradientPrimaryToAccent,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMd,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (teacher['name'] as String).isNotEmpty
                                      ? (teacher['name'] as String)[0]
                                            .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
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
                                    teacher['name'] ?? 'Unknown',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppTheme.xs),
                                  Text(
                                    teacher['email'] ?? 'No email',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.lg),
                        Divider(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.2),
                        ),
                        const SizedBox(height: AppTheme.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTeacherStat(
                              'Fee/Hour',
                              '\$${teacher['fee_per_hour'] ?? '0'}/h',
                              AppTheme.success,
                            ),
                            _buildTeacherStat(
                              'Total Requests',
                              '${teacher['total_requests'] ?? 0}',
                              AppTheme.info,
                            ),
                            _buildTeacherStat(
                              'Accepted',
                              '${teacher['accepted_requests'] ?? 0}',
                              AppTheme.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
  }

  Widget _buildTeacherStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: AppTheme.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ADMIN STUDENTS SCREEN
// ============================================================================

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  bool _isLoading = true;
  List<dynamic> _students = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('No auth token');
      final students = await AdminService.getStudents(token);
      setState(() {
        _students = students;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: LoadingWidget(label: 'Loading students...'))
        : _error != null
        ? Center(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error Loading Students',
              description: _error,
            ),
          )
        : _students.isEmpty
        ? Center(
            child: EmptyStateWidget(
              icon: Icons.group_outlined,
              title: 'No Students Yet',
              description: 'Students will appear here once they register',
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: StaggeredAnimationList(
              children: _students.map<Widget>((student) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.md),
                  child: ModernCard(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradientPrimaryToSecondary,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Center(
                            child: Text(
                              (student['name'] as String).isNotEmpty
                                  ? (student['name'] as String)[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
                                student['name'] ?? 'Unknown',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.xs),
                              Text(
                                student['email'] ?? 'No email',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${student['total_spent'] ?? '0.00'}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                             const SizedBox(height: AppTheme.xs),
                            Text(
                              '\$${student['total_spent'] ?? '0.00'}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: AppTheme.xs),
                            Text(
                              '${student['total_requests'] ?? 0} reqs',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
  }
}

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  bool _isLoading = true;
  List<dynamic> _payments = [];
  String? _error;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) throw Exception('No auth token');
      final payments = await AdminService.getPayments(
        token,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );
      setState(() {
        _payments = payments;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmPayment(String paymentId) async {
    try {
      final token = await TokenStorageService.getToken();
      if (token == null) return;
      await AdminService.confirmPayment(token, paymentId);
      await _loadPayments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment confirmed!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInPageTransition(
      child: Column(
        children: [
          // Filter Header
          Padding(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: ModernCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.lg,
                vertical: AppTheme.md,
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Filter by Status',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? 'all';
                  });
                  _loadPayments();
                },
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Payments')),
                  DropdownMenuItem(value: 'paid', child: Text('Paid')),
                  DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(child: LoadingWidget(label: 'Loading payments...'))
                : _error != null
                ? Center(
                    child: EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Error Loading Payments',
                      description: _error,
                    ),
                  )
                : _payments.isEmpty
                ? Center(
                    child: EmptyStateWidget(
                      icon: Icons.payment_outlined,
                      title: 'No Payments',
                      description: 'No payments found for the selected status',
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.lg,
                      vertical: AppTheme.md,
                    ),
                    child: StaggeredAnimationList(
                      children: _payments.map<Widget>((payment) {
                        final isPaid = payment['status'] == 'paid';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.md),
                          child: ModernCard(
                            padding: const EdgeInsets.all(AppTheme.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment['student_name'] ??
                                                'Unknown Student',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: AppTheme.xs),
                                          Text(
                                            'From: ${payment['teacher_name'] ?? 'Unknown Teacher'}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.md,
                                        vertical: AppTheme.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPaid
                                            ? AppTheme.success.withOpacity(0.15)
                                            : AppTheme.warning.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusMd,
                                        ),
                                        border: Border.all(
                                          color: isPaid
                                              ? AppTheme.success
                                              : AppTheme.warning,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        payment['status'].toString().toUpperCase(),
                                        style: TextStyle(
                                          color: isPaid
                                              ? AppTheme.success
                                              : AppTheme.warning,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.lg),
                                Divider(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.2),
                                ),
                                const SizedBox(height: AppTheme.lg),

                                // Amount
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Amount',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '\$${payment['amount']}',
                                      style: Theme.of(context).textTheme.titleMedium
                                          ?.copyWith(
                                            color: AppTheme.success,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),

                                // Action Button
                                if (!isPaid)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: AppTheme.lg,
                                    ),
                                    child: PrimaryButton(
                                      label: 'Confirm Payment',
                                      onPressed: () =>
                                          _confirmPayment(payment['id']),
                                      fullWidth: true,
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class AdminVerificationScreen extends StatefulWidget {
  final String token;
  const AdminVerificationScreen({super.key, required this.token});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  bool _isLoading = true;
  List<dynamic> _unverifiedUsers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUnverified();
  }

  Future<void> _loadUnverified() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final users = await AdminService.getUnverifiedUsers(widget.token);
      setState(() {
        _unverifiedUsers = users;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyUser(String userId) async {
    try {
      await AdminService.verifyUser(widget.token, userId);
      await _loadUnverified();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User verified successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(String userId) async {
    try {
      await AdminService.rejectUser(widget.token, userId);
      await _loadUnverified();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User registration rejected and deleted.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejection failed: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: LoadingWidget(label: 'Loading queue...'))
        : _error != null
            ? Center(child: EmptyStateWidget(icon: Icons.error_outline, title: 'Error Loading Queue', description: _error))
            : _unverifiedUsers.isEmpty
                ? const Center(
                    child: EmptyStateWidget(
                      icon: Icons.verified_user_outlined,
                      title: 'All Caught Up!',
                      description: 'No users are currently pending verification.',
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.lg),
                    itemCount: _unverifiedUsers.length,
                    itemBuilder: (context, index) {
                      final user = _unverifiedUsers[index];
                      final cnicFrontUrl = user['cnic_front'] != null
                          ? (user['cnic_front'].toString().startsWith('data:image/')
                              ? user['cnic_front'].toString()
                              : '${ApiConstants.baseUrl}${user['cnic_front']}')
                          : null;
                      final cnicBackUrl = user['cnic_back'] != null
                          ? (user['cnic_back'].toString().startsWith('data:image/')
                              ? user['cnic_back'].toString()
                              : '${ApiConstants.baseUrl}${user['cnic_back']}')
                          : null;
                      
                      final bool isIncomplete = user['phone'] == null || user['cnic_front'] == null || user['cnic_back'] == null;
                      
                      String subjectsText = 'None';
                      if (user['subjects'] != null) {
                        if (user['subjects'] is List) {
                          subjectsText = (user['subjects'] as List).join(', ');
                        } else {
                          // Try parsing if string
                          try {
                            final parsed = json.decode(user['subjects']);
                            if (parsed is List) {
                              subjectsText = parsed.join(', ');
                            } else {
                              subjectsText = user['subjects'].toString();
                            }
                          } catch (_) {
                            subjectsText = user['subjects'].toString().replaceAll('[', '').replaceAll(']', '').replaceAll('"', '');
                          }
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.md),
                        child: ModernCard(
                          padding: const EdgeInsets.all(AppTheme.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: user['role'] == 'teacher'
                                        ? AppTheme.primary.withOpacity(0.1)
                                        : AppTheme.secondary.withOpacity(0.1),
                                    child: Icon(
                                      user['role'] == 'teacher'
                                          ? Icons.school
                                          : Icons.person,
                                      color: user['role'] == 'teacher'
                                          ? AppTheme.primary
                                          : AppTheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['name'] ?? 'Unknown',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          '${user['role'].toString().toUpperCase()} • ${user['email']}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                        if (user['phone'] != null)
                                          Text(
                                            'Phone: ${user['phone']}',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (user['role'] == 'teacher') ...[
                                const SizedBox(height: AppTheme.md),
                                Container(
                                  padding: const EdgeInsets.all(AppTheme.md),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Teacher Details:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Subjects: $subjectsText',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Fee/Hour: \$${user['fee_per_hour'] ?? '0'}/hr',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      if (user['bio'] != null && user['bio'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Bio: ${user['bio']}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              if (isIncomplete) ...[
                                const SizedBox(height: AppTheme.md),
                                Container(
                                  padding: const EdgeInsets.all(AppTheme.md),
                                  decoration: BoxDecoration(
                                    color: AppTheme.danger.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.warning_amber_rounded, color: AppTheme.danger),
                                      SizedBox(width: AppTheme.sm),
                                      Expanded(
                                        child: Text(
                                          'Incomplete Profile: User has not uploaded all required verification details.',
                                          style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (cnicFrontUrl != null || cnicBackUrl != null) ...[
                                const SizedBox(height: AppTheme.md),
                                Text(
                                  'CNIC Documents (Front & Back):',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                                const SizedBox(height: AppTheme.xs),
                                Row(
                                  children: [
                                    if (cnicFrontUrl != null)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Front', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            const SizedBox(height: 4),
                                            Container(
                                              height: 150,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                                color: Colors.black12,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                                child: cnicFrontUrl != null && cnicFrontUrl.startsWith('data:image/')
                                                    ? Image.memory(
                                                        base64Decode(cnicFrontUrl.split('base64,').last),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.broken_image_outlined,
                                                              size: 36,
                                                              color: Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Image.network(
                                                        cnicFrontUrl ?? '',
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.broken_image_outlined,
                                                              size: 36,
                                                              color: Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (cnicFrontUrl != null && cnicBackUrl != null)
                                      const SizedBox(width: AppTheme.md),
                                    if (cnicBackUrl != null)
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Back', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            const SizedBox(height: 4),
                                            Container(
                                              height: 150,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                                color: Colors.black12,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                                child: cnicBackUrl != null && cnicBackUrl.startsWith('data:image/')
                                                    ? Image.memory(
                                                        base64Decode(cnicBackUrl.split('base64,').last),
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.broken_image_outlined,
                                                              size: 36,
                                                              color: Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Image.network(
                                                        cnicBackUrl ?? '',
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.broken_image_outlined,
                                                              size: 36,
                                                              color: Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: AppTheme.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryButton(
                                      onPressed: () => _verifyUser(user['id']),
                                      isEnabled: !isIncomplete,
                                      label: 'Approve & Verify',
                                      backgroundColor: AppTheme.success,
                                    ),

                                  ),
                                  const SizedBox(width: AppTheme.md),
                                  Expanded(
                                    child: PrimaryButton(
                                      onPressed: () => _rejectUser(user['id']),
                                      label: 'Reject & Disapprove',
                                      backgroundColor: AppTheme.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
  }
}
