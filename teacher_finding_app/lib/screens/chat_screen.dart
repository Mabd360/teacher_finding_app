import 'dart:async';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';
import '../components/index.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<MessageItem> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = true;
  String? _myUserId;
  String? _token;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadAuthAndMessages();
    // Start polling every 2.5 seconds
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      _fetchMessagesSilent();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthAndMessages() async {
    try {
      final token = await TokenStorageService.getToken();
      final user = await TokenStorageService.getUser();
      if (token == null || user == null) {
        throw Exception('User is not authenticated');
      }

      setState(() {
        _token = token;
        _myUserId = user.id;
      });

      await _fetchMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading chat: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _fetchMessages() async {
    if (_token == null) return;
    try {
      final messages = await ChatService.getMessages(
        token: _token!,
        otherUserId: widget.otherUserId,
      );
      setState(() {
        _messages.clear();
        _messages.addAll(messages);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMessagesSilent() async {
    if (_token == null) return;
    try {
      final messages = await ChatService.getMessages(
        token: _token!,
        otherUserId: widget.otherUserId,
      );
      
      // Only refresh UI if there are new messages to prevent stutter
      if (messages.length != _messages.length) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _token == null) return;

    _messageController.clear();

    try {
      final newMessage = await ChatService.sendMessage(
        token: _token!,
        receiverId: widget.otherUserId,
        message: text,
      );

      setState(() {
        _messages.add(newMessage);
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(widget.otherUserName),
        elevation: 0.5,
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.textDarkLight,
      ),
      body: GlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? Center(
                            child: EmptyStateWidget(
                              icon: Icons.chat_bubble_outline,
                              title: 'Say Hello!',
                              description: 'Start your conversation with ${widget.otherUserName}',
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppTheme.lg),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isMe = msg.senderId == _myUserId;

                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: AppTheme.md),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.lg,
                                    vertical: AppTheme.md,
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppTheme.primary
                                        : (isDark ? AppTheme.surfaceDark : Colors.white),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(AppTheme.radiusMd),
                                      topRight: const Radius.circular(AppTheme.radiusMd),
                                      bottomLeft: isMe
                                          ? const Radius.circular(AppTheme.radiusMd)
                                          : Radius.zero,
                                      bottomRight: isMe
                                          ? Radius.zero
                                          : const Radius.circular(AppTheme.radiusMd),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    msg.message,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : (isDark ? Colors.white : Colors.black87),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              // Input Bar
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? AppTheme.bgDark : Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.lg,
                            vertical: AppTheme.md,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onFieldSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    FloatingActionButton(
                      onPressed: _sendMessage,
                      mini: true,
                      backgroundColor: AppTheme.primary,
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
