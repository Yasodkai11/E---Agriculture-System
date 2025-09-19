import 'package:e_agriculture_system/firebase_options.dart';
import 'package:e_agriculture_system/core/services/firebase_config_helper.dart';
import 'package:e_agriculture_system/core/config/logging_config.dart';
import 'package:e_agriculture_system/data/services/unified_image_storage_service.dart';
import 'package:e_agriculture_system/data/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable overflow indicators
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(color: Colors.transparent, child: const SizedBox.shrink());
  };

  try {
    // Initialize Firebase with default options first
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize our Firebase helper
    print('🔧 Initializing Firebase helper...');
    await FirebaseConfigHelper.initialize();

    // Initialize logging configuration AFTER Firebase is ready
    print('📝 Initializing logging configuration...');
    LoggingConfig.initialize();

    // Initialize unified image storage system
    print('🖼️ Initializing unified image storage system...');
    final storage = UnifiedImageStorageService();
    // Storage type is automatically detected based on platform
    print(
      '✅ Storage system initialized with ${storage.storageType.name.toUpperCase()} Storage',
    );

    // Initialize notification service
    print('🔔 Initializing notification service...');
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('✅ Notification service initialized successfully');

    print('✅ All systems initialized successfully!');
  } catch (e, stackTrace) {
    print('❌ Initialization failed: $e');
    print('📚 Stack trace: $stackTrace');

    // Even if Firebase fails, try to initialize logging with safe defaults
    try {
      print('📝 Attempting to initialize logging with safe defaults...');
      LoggingConfig.initialize();
    } catch (loggingError) {
      print('⚠️ Logging initialization also failed: $loggingError');
    }

    // Continue with the app - don't crash
    print('🚀 Continuing with app startup...');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}