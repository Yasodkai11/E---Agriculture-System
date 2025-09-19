import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

enum LogCategory {
  dashboard,
  buyerDashboard,
  authentication,
  navigation,
  dataOperation,
  userAction,
  system,
  performance,
  security,
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // Configuration
  bool _enableConsoleLogging = true;
  bool _enableFirestoreLogging = false;
  bool _enableDebugMode = kDebugMode;
  LogLevel _minimumLogLevel = LogLevel.info;

  // Firestore collection for logs (nullable for web safety)
  CollectionReference? get _logsCollection {
    try {
      return FirebaseFirestore.instance.collection('system_logs');
    } catch (e) {
      // If Firestore isn't available (e.g., on web during initialization), return null
      return null;
    }
  }

  // Getters and setters
  bool get enableConsoleLogging => _enableConsoleLogging;
  bool get enableFirestoreLogging => _enableFirestoreLogging;
  bool get enableDebugMode => _enableDebugMode;
  LogLevel get minimumLogLevel => _minimumLogLevel;

  // Configuration methods
  void configure({
    bool? enableConsoleLogging,
    bool? enableFirestoreLogging,
    bool? enableDebugMode,
    LogLevel? minimumLogLevel,
  }) {
    _enableConsoleLogging = enableConsoleLogging ?? _enableConsoleLogging;
    _enableFirestoreLogging = enableFirestoreLogging ?? _enableFirestoreLogging;
    _enableDebugMode = enableDebugMode ?? _enableDebugMode;
    _minimumLogLevel = minimumLogLevel ?? _minimumLogLevel;
  }

  // Main logging method
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.system,
    String? userId,
    String? screenName,
    String? action,
    Map<String, dynamic>? additionalData,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Check if we should log this level
    if (level.index < _minimumLogLevel.index) return;

    // Create log entry
    final logEntry = _createLogEntry(
      message: message,
      level: level,
      category: category,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: additionalData,
      error: error,
      stackTrace: stackTrace,
    );

    // Console logging
    if (_enableConsoleLogging) {
      _logToConsole(logEntry);
    }

    // Firestore logging (only for important logs and when available)
    if (_enableFirestoreLogging && level.index >= LogLevel.warning.index) {
      _logToFirestore(logEntry);
    }
  }

  // Convenience methods for different log levels
  void debug(
    String message, {
    LogCategory category = LogCategory.system,
    String? userId,
    String? screenName,
    String? action,
    Map<String, dynamic>? additionalData,
  }) {
    log(
      message,
      level: LogLevel.debug,
      category: category,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: additionalData,
    );
  }

  void info(
    String message, {
    LogCategory category = LogCategory.system,
    String? userId,
    String? screenName,
    String? action,
    Map<String, dynamic>? additionalData,
  }) {
    log(
      message,
      level: LogLevel.info,
      category: category,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: additionalData,
    );
  }

  void warning(
    String message, {
    LogCategory category = LogCategory.system,
    String? userId,
    String? screenName,
    String? action,
    Map<String, dynamic>? additionalData,
    Object? error,
  }) {
    log(
      message,
      level: LogLevel.warning,
      category: category,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: additionalData,
      error: error,
    );
  }

  void error(
    String message, {
    LogCategory category = LogCategory.system,
    String? userId,
    String? screenName,
    String? action,
    Map<String, dynamic>? additionalData,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: LogLevel.error,
      category: category,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: additionalData,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void critical(
    String message, {
    LogCategory category = LogCategory.system,
    String? userId,
    String? screenName,
    String? action,
    Map<String, dynamic>? additionalData,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      message,
      level: LogLevel.critical,
      category: category,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: additionalData,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Dashboard-specific logging methods (now integrated)
  void logDashboardAction(
    String action, {
    String? userId,
    Map<String, dynamic>? additionalData,
  }) {
    info(
      'Dashboard action: $action',
      category: LogCategory.dashboard,
      userId: userId,
      screenName: 'MainDashboard',
      action: action,
      additionalData: additionalData,
    );
  }

  void logBuyerDashboardAction(
    String action, {
    String? userId,
    Map<String, dynamic>? additionalData,
  }) {
    info(
      'Buyer dashboard action: $action',
      category: LogCategory.buyerDashboard,
      userId: userId,
      screenName: 'MainDashboard',
      action: action,
      additionalData: additionalData,
    );
  }

  // New method for integrated dashboard actions
  void logIntegratedDashboardAction(
    String action, {
    required String mode, // 'buyer' or 'farmer'
    String? userId,
    Map<String, dynamic>? additionalData,
  }) {
    final category = mode == 'buyer' ? LogCategory.buyerDashboard : LogCategory.dashboard;
    final screenName = 'MainDashboard';
    
    info(
      '${mode.capitalize()} dashboard action: $action',
      category: category,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: {
        'mode': mode,
        'dashboardType': 'integrated',
        ...?additionalData,
      },
    );
  }

  // Mode switching logging
  void logModeSwitch({
    required String fromMode,
    required String toMode,
    String? userId,
    Map<String, dynamic>? additionalData,
  }) {
    info(
      'Dashboard mode switched: $fromMode → $toMode',
      category: LogCategory.userAction,
      userId: userId,
      screenName: 'MainDashboard',
      action: 'mode_switch',
      additionalData: {
        'fromMode': fromMode,
        'toMode': toMode,
        'dashboardType': 'integrated',
        ...?additionalData,
      },
    );
  }

  void logNavigation(
    String fromScreen,
    String toScreen, {
    String? userId,
    Map<String, dynamic>? additionalData,
  }) {
    info(
      'Navigation: $fromScreen → $toScreen',
      category: LogCategory.navigation,
      userId: userId,
      screenName: fromScreen,
      action: 'navigate',
      additionalData: {
        'fromScreen': fromScreen,
        'toScreen': toScreen,
        ...?additionalData,
      },
    );
  }

  void logUserAction(
    String action, {
    String? userId,
    String? screenName,
    Map<String, dynamic>? additionalData,
  }) {
    info(
      'User action: $action',
      category: LogCategory.userAction,
      userId: userId,
      screenName: screenName,
      action: action,
      additionalData: additionalData,
    );
  }

  void logDataOperation(
    String operation, {
    String? userId,
    String? screenName,
    String? collection,
    String? documentId,
    Map<String, dynamic>? additionalData,
    Object? error,
  }) {
    final level = error != null ? LogLevel.error : LogLevel.info;
    
    log(
      'Data operation: $operation',
      level: level,
      category: LogCategory.dataOperation,
      userId: userId,
      screenName: screenName,
      action: operation,
      additionalData: {
        'collection': collection,
        'documentId': documentId,
        ...?additionalData,
      },
      error: error,
    );
  }

  // Private methods
  Map<String, dynamic> _createLogEntry({
    required String message,
    required LogLevel level,
    required LogCategory category,
    String? userId,
    String? screenName,
    String? action,
    Map<String, dynamic>? additionalData,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.name,
      'category': category.name,
      'message': message,
      'userId': userId ?? _getCurrentUserIdSafely(),
      'screenName': screenName,
      'action': action,
      'additionalData': additionalData,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
      'platform': defaultTargetPlatform.name,
      'version': '1.0.0', // You can make this configurable
    };
  }

  // Web-safe method to get current user ID
  String? _getCurrentUserIdSafely() {
    try {
      // Check if we're on web platform and Firebase is available
      if (kIsWeb) {
        // On web, check if Firebase is initialized
        if (!_isFirebaseAvailable) {
          return null;
        }
      }
      
      // Try to get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      return currentUser?.uid;
    } catch (e) {
      // If Firebase isn't ready or throws an error, return null
      return null;
    }
  }

  // Check if Firebase is available
  bool get _isFirebaseAvailable {
    try {
      // Try to access Firebase Auth instance
      final auth = FirebaseAuth.instance;
      return auth != null;
    } catch (e) {
      return false;
    }
  }

  void _logToConsole(Map<String, dynamic> logEntry) {
    final timestamp = logEntry['timestamp'];
    final level = logEntry['level'].toUpperCase();
    final category = logEntry['category'];
    final message = logEntry['message'];
    final screenName = logEntry['screenName'];
    final action = logEntry['action'];

    final logMessage = '[$timestamp] [$level] [$category] $message';
    final context = screenName != null ? ' (Screen: $screenName${action != null ? ', Action: $action' : ''})' : '';

    switch (logEntry['level']) {
      case 'debug':
        debugPrint('🐛 $logMessage$context');
        break;
      case 'info':
        debugPrint('ℹ️ $logMessage$context');
        break;
      case 'warning':
        debugPrint('⚠️ $logMessage$context');
        break;
      case 'error':
        debugPrint('❌ $logMessage$context');
        break;
      case 'critical':
        debugPrint('🚨 $logMessage$context');
        break;
      default:
        debugPrint('📝 $logMessage$context');
    }
  }

  Future<void> _logToFirestore(Map<String, dynamic> logEntry) async {
    try {
      // Check if Firestore is available before attempting to log
      final logsCollection = _logsCollection;
      if (logsCollection != null) {
        await logsCollection.add(logEntry);
      } else {
        // If Firestore isn't available, just log to console
        debugPrint('⚠️ Firestore not available, skipping Firestore logging');
      }
    } catch (e) {
      // Don't log logging errors to avoid infinite loops
      debugPrint('Failed to log to Firestore: $e');
    }
  }

  // Utility methods
  String getCurrentUserId() {
    return _getCurrentUserIdSafely() ?? 'anonymous';
  }

  void logPerformance(String operation, Duration duration, {String? screenName}) {
    if (duration.inMilliseconds > 1000) { // Log slow operations
      warning(
        'Slow operation detected: $operation took ${duration.inMilliseconds}ms',
        category: LogCategory.performance,
        screenName: screenName,
        action: operation,
        additionalData: {'durationMs': duration.inMilliseconds},
      );
    } else {
      debug(
        'Operation completed: $operation in ${duration.inMilliseconds}ms',
        category: LogCategory.performance,
        screenName: screenName,
        action: operation,
        additionalData: {'durationMs': duration.inMilliseconds},
      );
    }
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

// Global logger instance
final logger = LoggerService();
