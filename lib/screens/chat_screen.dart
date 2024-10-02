import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/models/chat.dart';
import 'package:flutter_firebase_chat_app/models/message.dart';
import 'package:flutter_firebase_chat_app/models/user_profile.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/services/database_service.dart';
import 'package:flutter_firebase_chat_app/services/media_service.dart';
import 'package:flutter_firebase_chat_app/utils/utils.dart';
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
  late DatabaseService databaseService;
  late MediaService mediaService;

  @override
  void initState() {
    super.initState();
    authService = getIt.get<AuthService>();
    databaseService = getIt.get<DatabaseService>();
    mediaService = getIt.get<MediaService>();
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
      body: StreamBuilder(
        stream: databaseService.getChatData(
          currentUser!.id,
          otherUser!.id,
        ),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data();
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = generateChatMessagesList(
              chat.messages!,
            );
          }
          return DashChat(
            messageOptions: const MessageOptions(
              showOtherUsersAvatar: true,
              showTime: true,
            ),
            currentUser: currentUser!,
            inputOptions: InputOptions(
              alwaysShowSend: true,
              trailing: [
                IconButton(
                  onPressed: () async {
                    File? file = await mediaService.getImageFromGallery();
                  },
                  icon: const Icon(
                    Icons.image,
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            onSend: sendMessage,
            messages: messages,
          );
        },
      ),
    );
  }

  Future<void> sendMessage(ChatMessage chatMessage) async {
    Message message = Message(
      senderID: currentUser!.id,
      content: chatMessage.text,
      messageType: MessageType.Text,
      sentAt: Timestamp.fromDate(
        chatMessage.createdAt,
      ),
    );
    await databaseService.sendChatMessage(
      currentUser!.id,
      otherUser!.id,
      message,
    );
  }

  List<ChatMessage> generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      return ChatMessage(
        user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
        text: m.content!,
        createdAt: m.sentAt!.toDate(),
      );
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(
        a.createdAt,
      );
    });
    return chatMessages;
  }
}
