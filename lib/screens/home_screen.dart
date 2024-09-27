import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/services/alert_service.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GetIt getIt = GetIt.instance;
  late AuthService authService;
  late NavigationService navigationService;
  late AlertService alertService;

  @override
  void initState() {
    super.initState();
    authService = getIt.get<AuthService>();
    navigationService = getIt.get<NavigationService>();
    alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
