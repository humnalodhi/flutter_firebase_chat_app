import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/models/user_profile.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:get_it/get_it.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.userProfile,
  });

  final UserProfile userProfile;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GetIt getIt = GetIt.instance;
  ChatUser? currentUser, otherUser;
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = getIt.get<AuthService>();
    currentUser = ChatUser(
      id: authService.user!.uid,
    );
    otherUser = ChatUser(
      id: widget.userProfile.uid!,
      firstName: widget.userProfile.name,
      profileImage: widget.userProfile.pfpUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.userProfile.name!,
        ),
      ),
      body: DashChat(
        messageOptions: const MessageOptions(
          showOtherUsersAvatar: true,
          showTime: true,
        ),
        currentUser: currentUser!,
        inputOptions: const InputOptions(
          alwaysShowSend: true,
        ),
        onSend: (message) {},
        messages: [],
      ),
    );
  }
}
