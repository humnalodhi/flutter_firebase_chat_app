import 'package:flutter_firebase_chat_app/services/alert_service.dart';
import 'package:flutter_firebase_chat_app/services/auth_service.dart';
import 'package:flutter_firebase_chat_app/services/database_service.dart';
import 'package:flutter_firebase_chat_app/services/media_service.dart';
import 'package:flutter_firebase_chat_app/services/navigation_service.dart';
import 'package:flutter_firebase_chat_app/services/storage_service.dart';
import 'package:get_it/get_it.dart';

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );
  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );
  getIt.registerSingleton<AlertService>(
    AlertService(),
  );
  getIt.registerSingleton<MediaService>(
    MediaService(),
  );
  getIt.registerSingleton<StorageService>(
    StorageService(),
  );
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
}
