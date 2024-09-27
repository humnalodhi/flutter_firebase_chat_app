import 'package:flutter/cupertino.dart';
import 'package:flutter_firebase_chat_app/screens/home_screen.dart';
import 'package:flutter_firebase_chat_app/screens/login_screen.dart';
import 'package:flutter_firebase_chat_app/screens/register_screen.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginScreen(),
    "/home": (context) => HomeScreen(),
    "/register": (context) => RegisterScreen(),
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}
