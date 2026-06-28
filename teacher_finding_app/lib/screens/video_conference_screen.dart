import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import '../utils/api_constants.dart';

class VideoConferenceScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Sanitize conferenceID and userID to only contain alphanumeric characters and underscores
    final sanitizedConferenceId =
        bookingId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final sanitizedUserId =
        userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final displayName =
        userName.isNotEmpty ? userName : 'User_$sanitizedUserId';

    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: ApiConstants.zegoAppId,
        // appSign is the same for all platforms (mobile & web).
        // The backend-generated Zego token is a different concept
        // and is NOT required for appSign-mode authentication.
        appSign: ApiConstants.zegoAppSign,
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
