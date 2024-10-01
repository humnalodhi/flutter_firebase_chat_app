import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/models/user_profile.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
  });

  final UserProfile userProfile;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          userProfile.pfpUrl!,
        ),
      ),
      title: Text(userProfile.name!),
    );
  }
}
