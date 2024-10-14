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
import 'package:flutter_firebase_chat_app/services/storage_service.dart';
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
  late StorageService storageService;

  @override
  void initState() {
    super.initState();
    authService = getIt.get<AuthService>();
    databaseService = getIt.get<DatabaseService>();
    mediaService = getIt.get<MediaService>();
    storageService = getIt.get<StorageService>();
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
                    if (file != null) {
                      String chatId = generateChatID(
                        uid1: currentUser!.id,
                        uid2: otherUser!.id,
                      );

                      String? downloadURL =
                          await storageService.uploadImageToChat(
                        file: file,
                        chatId: chatId,
                      );
                      if (downloadURL != null) {
                        ChatMessage chatMessage = ChatMessage(
                          user: currentUser!,
                          createdAt: DateTime.now(),
                          medias: [
                            ChatMedia(
                              url: downloadURL,
                              fileName: "",
                              type: MediaType.image,
                            )
                          ],
                        );
                        sendMessage(chatMessage);
                      }
                    }
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
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
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
    } else {
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
  }

  List<ChatMessage> generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            createdAt: m.sentAt!.toDate(),
            medias: [
              ChatMedia(
                url: m.content!,
                fileName: "",
                type: MediaType.image,
              ),
            ]);
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(
        a.createdAt,
      );
    });
    return chatMessages;
  }
}
