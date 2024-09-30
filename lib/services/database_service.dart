import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat_app/models/user_profile.dart';

class DatabaseService {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  CollectionReference? userCollection;

  DatabaseService() {
    setUpCollectionReferences();
  }

  void setUpCollectionReferences() {
    userCollection =
        firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await userCollection?.doc(userProfile.uid).set(userProfile);
  }
}
