import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_app/models/chat.dart';
import 'package:flutter_firebase_chat_app/models/user_profile.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/utils/utils.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final GetIt getIt = GetIt.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  late AuthService authService;
  CollectionReference? usersCollection;
  CollectionReference? chatsCollection;

  DatabaseService() {
    setUpCollectionReferences();
    authService = getIt.get<AuthService>();
  }

  void setUpCollectionReferences() {
    usersCollection =
        firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );

    chatsCollection = firebaseFirestore.collection('chats').withConverter<Chat>(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return usersCollection
        ?.where(
          "uid",
          isNotEqualTo: authService.user!.uid,
        )
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

// Future<bool> checkChatExists(String uid1, String uid2) async {
//   String chatID = generateChatID(uid1: uid1, uid2: uid2);
// }
}
