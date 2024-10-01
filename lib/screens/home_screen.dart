import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/models/user_profile.dart';
import 'package:flutter_firebase_chat_app/services/alert_service.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/services/database_service.dart';
import 'package:flutter_firebase_chat_app/services/navigation_service.dart';
import 'package:flutter_firebase_chat_app/widgets/chat_tile.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GetIt getIt = GetIt.instance;
  late AuthService authService;
  late DatabaseService databaseService;
  late NavigationService navigationService;
  late AlertService alertService;

  @override
  void initState() {
    super.initState();
    authService = getIt.get<AuthService>();
    navigationService = getIt.get<NavigationService>();
    alertService = getIt.get<AlertService>();
    databaseService = getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Messages"),
          actions: [
            IconButton(
              onPressed: () async {
                bool result = await authService.logout();
                if (result) {
                  alertService.showToast(
                    text: "Successfully logged out!",
                    icon: Icons.check,
                  );
                  navigationService.pushReplacementNamed("/login");
                }
              },
              color: Colors.red,
              icon: const Icon(
                Icons.logout,
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: StreamBuilder(
            stream: databaseService.getUserProfiles(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Unable to load data");
              }
              if (snapshot.hasData && snapshot.data != null) {
                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    UserProfile user = users[index].data();
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: ChatTile(
                        userProfile: user,
                        onTap: () async {},
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
