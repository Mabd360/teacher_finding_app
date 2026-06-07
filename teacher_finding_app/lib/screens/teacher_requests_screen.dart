import 'package:flutter/material.dart';
import '../services/request_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';
import 'chat_screen.dart';

class TeacherRequestsScreen extends StatefulWidget {
  const TeacherRequestsScreen({super.key});

  @override
  State<TeacherRequestsScreen> createState() => _TeacherRequestsScreenState();
}

class _TeacherRequestsScreenState extends State<TeacherRequestsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<RequestItem> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication token missing');
      }

      final requests = await RequestService.getTeacherRequests(token: token);
      if (mounted) {
        setState(() {
          _requests = requests;
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

  Future<void> _updateRequestStatus(RequestItem request, String status) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenStorageService.getToken();
      if (token == null) {
        throw Exception('Authentication token missing');
      }

      await RequestService.updateRequestStatus(
        token: token,
        requestId: request.id,
        status: status,
      );
      await _loadRequests();
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.danger;
      default:
        return AppTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Incoming Requests'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: isDark ? Colors.white : AppTheme.textDarkLight,
      ),
      body: GlowBackground(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: AppTheme.danger),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _requests.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.mail_outline,
                          title: 'No requests yet',
                          description: 'Incoming student lesson requests will be shown here.',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRequests,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _requests.length,
                            itemBuilder: (context, index) {
                              final request = _requests[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppTheme.md),
                                child: ModernCard(
                                  hover: false,
                                  padding: const EdgeInsets.all(AppTheme.lg),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              request.studentName ?? 'Unknown Student',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppTheme.md,
                                              vertical: AppTheme.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(request.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                              border: Border.all(
                                                color: _statusColor(request.status).withOpacity(0.2),
                                              ),
                                            ),
                                            child: Text(
                                              request.status.toUpperCase(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                                color: _statusColor(request.status),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (request.message != null && request.message!.isNotEmpty) ...[
                                        const SizedBox(height: AppTheme.md),
                                        Text(
                                          request.message!,
                                          style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                      if (request.status == 'accepted') ...[
                                        const SizedBox(height: AppTheme.md),
                                        const Divider(),
                                        const SizedBox(height: AppTheme.sm),
                                        Row(
                                          children: [
                                            const Icon(Icons.contact_mail_outlined, size: 16, color: AppTheme.success),
                                            const SizedBox(width: AppTheme.sm),
                                            Text(
                                              'Email: ${request.studentEmail ?? "N/A"}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.xs),
                                        Row(
                                          children: [
                                            const Icon(Icons.contact_phone_outlined, size: 16, color: AppTheme.success),
                                            const SizedBox(width: AppTheme.sm),
                                            Text(
                                              'Phone: ${request.studentPhone ?? "N/A"}',
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppTheme.md),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => ChatScreen(
                                                        otherUserId: request.studentId ?? '',
                                                        otherUserName: request.studentName ?? 'Student',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                                label: const Text('Chat with Student'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.primary,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (request.status == 'pending') ...[
                                        const SizedBox(height: AppTheme.lg),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: PrimaryButton(
                                                onPressed: () => _updateRequestStatus(
                                                  request,
                                                  'accepted',
                                                ),
                                                label: 'Accept',
                                                backgroundColor: AppTheme.success,
                                              ),
                                            ),
                                            const SizedBox(width: AppTheme.md),
                                            Expanded(
                                              child: SecondaryButton(
                                                onPressed: () => _updateRequestStatus(
                                                  request,
                                                  'rejected',
                                                ),
                                                label: 'Reject',
                                                borderColor: AppTheme.danger,
                                                textColor: AppTheme.danger,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ),
    );
  }
}
