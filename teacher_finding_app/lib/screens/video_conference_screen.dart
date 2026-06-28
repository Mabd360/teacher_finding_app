import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import '../utils/api_constants.dart';
import '../services/token_storage_service.dart';
import '../utils/theme.dart';

class VideoConferenceScreen extends StatefulWidget {
  final String bookingId;
  final String userId;
  final String userName;

  const VideoConferenceScreen({
    super.key,
    required this.bookingId,
    required this.userId,
    required this.userName,
  });

  @override
  State<VideoConferenceScreen> createState() => _VideoConferenceScreenState();
}

class _VideoConferenceScreenState extends State<VideoConferenceScreen> {
  String? _zegoToken;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _fetchZegoToken();
    }
  }

  Future<void> _fetchZegoToken() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authToken = await TokenStorageService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/zego/token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'userId': widget.userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _zegoToken = data['token'];
          _isLoading = false;
        });
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['error'] ?? 'Failed to generate access token';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: Failed to connect to server';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sanitize conferenceID and userID to only contain alphanumeric characters and underscores
    final sanitizedConferenceId = widget.bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final sanitizedUserId = widget.userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final displayName = widget.userName.isNotEmpty ? widget.userName : 'User_$sanitizedUserId';

    if (kIsWeb && _isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: AppTheme.md),
              Text(
                'Securing call connection...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (kIsWeb && _errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: AppTheme.md),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.lg),
                ElevatedButton(
                  onPressed: _fetchZegoToken,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: ApiConstants.zegoAppId,
        appSign: kIsWeb ? (_zegoToken ?? '') : ApiConstants.zegoAppSign,
        conferenceID: sanitizedConferenceId,
        userID: sanitizedUserId,
        userName: displayName,
        config: ZegoUIKitPrebuiltVideoConferenceConfig()
          ..turnOnCameraWhenJoining = true
          ..turnOnMicrophoneWhenJoining = true
          ..useSpeakerWhenJoining = true
          ..layout = ZegoLayout.gallery()
          ..topMenuBarConfig = ZegoTopMenuBarConfig(
            buttons: [
              ZegoMenuBarButtonName.showMemberListButton,
              ZegoMenuBarButtonName.toggleMicrophoneButton,
              ZegoMenuBarButtonName.toggleCameraButton,
              ZegoMenuBarButtonName.switchCameraButton,
            ],
          )
          ..bottomMenuBarConfig = ZegoBottomMenuBarConfig(
            buttons: [
              ZegoMenuBarButtonName.toggleMicrophoneButton,
              ZegoMenuBarButtonName.toggleCameraButton,
              ZegoMenuBarButtonName.switchCameraButton,
              ZegoMenuBarButtonName.toggleScreenSharingButton,
              ZegoMenuBarButtonName.leaveButton,
              ZegoMenuBarButtonName.chatButton,
            ],
          ),
      ),
    );
  }
}
