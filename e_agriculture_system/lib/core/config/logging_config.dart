import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

class LoggingConfig {
  // Environment-based configuration
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool _isDevelopment = !_isProduction;
  
  // Default configuration
  static const LogLevel _defaultLogLevel = LogLevel.info;
  static const bool _defaultConsoleLogging = true;
  static const bool _defaultFirestoreLogging = false;
  
  // Production overrides
  static const LogLevel _productionLogLevel = LogLevel.warning;
  static const bool _productionConsoleLogging = false;
  static const bool _productionFirestoreLogging = true;
  
  /// Initialize logging configuration based on environment
  static void initialize() {
    try {
      if (_isProduction) {
        _configureProduction();
      } else {
        _configureDevelopment();
      }
      
      // Log the configuration (only if logger is available)
      _logConfiguration();
      
    } catch (e) {
      // If logging fails during initialization, just print to console
      debugPrint('⚠️ Logging configuration initialization failed: $e');
      debugPrint('📝 Continuing with default logging configuration');
    }
  }
  
  /// Configure logging for production environment
  static void _configureProduction() {
    try {
      logger.configure(
        enableConsoleLogging: _productionConsoleLogging,
        enableFirestoreLogging: _productionFirestoreLogging,
        enableDebugMode: false,
        minimumLogLevel: _productionLogLevel,
      );
    } catch (e) {
      debugPrint('⚠️ Production logging configuration failed: $e');
      // Fall back to safe defaults
      _configureSafeDefaults();
    }
  }
  
  /// Configure logging for development environment
  static void _configureDevelopment() {
    try {
      logger.configure(
        enableConsoleLogging: _defaultConsoleLogging,
        enableFirestoreLogging: _defaultFirestoreLogging,
        enableDebugMode: _isDevelopment,
        minimumLogLevel: _defaultLogLevel,
      );
    } catch (e) {
      debugPrint('⚠️ Development logging configuration failed: $e');
      // Fall back to safe defaults
      _configureSafeDefaults();
    }
  }
  
  /// Configure safe defaults when Firebase is not available
  static void _configureSafeDefaults() {
    try {
      logger.configure(
        enableConsoleLogging: true,
        enableFirestoreLogging: false,
        enableDebugMode: _isDevelopment,
        minimumLogLevel: _defaultLogLevel,
      );
    } catch (e) {
      debugPrint('⚠️ Safe defaults configuration also failed: $e');
    }
  }
  
  /// Safely log configuration information
  static void _logConfiguration() {
    try {
      logger.info(
        'Logging configuration initialized',
        category: LogCategory.system,
        additionalData: {
          'environment': _isProduction ? 'production' : 'development',
          'logLevel': logger.minimumLogLevel.name,
          'consoleLogging': logger.enableConsoleLogging,
          'firestoreLogging': logger.enableFirestoreLogging,
          'debugMode': logger.enableDebugMode,
        },
      );
    } catch (e) {
      // If logging fails, just print to console
      debugPrint('📝 Logging configuration initialized successfully');
      debugPrint('🌍 Environment: ${_isProduction ? 'production' : 'development'}');
      debugPrint('🔧 Console logging: enabled');
      debugPrint('🔥 Firestore logging: disabled (web-safe mode)');
    }
  }
  
  /// Get current environment
  static bool get isProduction => _isProduction;
  static bool get isDevelopment => _isDevelopment;
  
  /// Manual configuration override
  static void configure({
    bool? enableConsoleLogging,
    bool? enableFirestoreLogging,
    bool? enableDebugMode,
    LogLevel? minimumLogLevel,
  }) {
    try {
      logger.configure(
        enableConsoleLogging: enableConsoleLogging,
        enableFirestoreLogging: enableFirestoreLogging,
        enableDebugMode: enableDebugMode,
        minimumLogLevel: minimumLogLevel,
      );
      
      // Log the configuration change
      _logConfigurationChange(
        enableConsoleLogging: enableConsoleLogging,
        enableFirestoreLogging: enableFirestoreLogging,
        enableDebugMode: enableDebugMode,
        minimumLogLevel: minimumLogLevel,
      );
      
    } catch (e) {
      debugPrint('⚠️ Manual logging configuration failed: $e');
    }
  }
  
  /// Safely log configuration changes
  static void _logConfigurationChange({
    bool? enableConsoleLogging,
    bool? enableFirestoreLogging,
    bool? enableDebugMode,
    LogLevel? minimumLogLevel,
  }) {
    try {
      logger.info(
        'Logging configuration manually updated',
        category: LogCategory.system,
        additionalData: {
          'enableConsoleLogging': enableConsoleLogging,
          'enableFirestoreLogging': enableFirestoreLogging,
          'enableDebugMode': enableDebugMode,
          'minimumLogLevel': minimumLogLevel?.name,
        },
      );
    } catch (e) {
      debugPrint('📝 Logging configuration updated manually');
    }
  }
  
  /// Enable debug logging temporarily
  static void enableDebugLogging() {
    try {
      if (_isProduction) {
        logger.warning(
          'Debug logging requested in production environment',
          category: LogCategory.system,
          action: 'enable_debug_logging',
        );
      }
      
      logger.configure(
        enableConsoleLogging: true,
        enableDebugMode: true,
        minimumLogLevel: LogLevel.debug,
      );
      
      _logDebugLoggingChange('enabled');
      
    } catch (e) {
      debugPrint('⚠️ Failed to enable debug logging: $e');
    }
  }
  
  /// Disable debug logging
  static void disableDebugLogging() {
    try {
      logger.configure(
        enableDebugMode: false,
        minimumLogLevel: _isProduction ? _productionLogLevel : _defaultLogLevel,
      );
      
      _logDebugLoggingChange('disabled');
      
    } catch (e) {
      debugPrint('⚠️ Failed to disable debug logging: $e');
    }
  }
  
  /// Safely log debug logging changes
  static void _logDebugLoggingChange(String action) {
    try {
      logger.info(
        'Debug logging $action',
        category: LogCategory.system,
        action: 'debug_logging_$action',
      );
    } catch (e) {
      debugPrint('📝 Debug logging $action');
    }
  }
  
  /// Enable Firestore logging
  static void enableFirestoreLogging() {
    try {
      logger.configure(enableFirestoreLogging: true);
      _logFirestoreLoggingChange('enabled');
    } catch (e) {
      debugPrint('⚠️ Failed to enable Firestore logging: $e');
    }
  }
  
  /// Disable Firestore logging
  static void disableFirestoreLogging() {
    try {
      logger.configure(enableFirestoreLogging: false);
      _logFirestoreLoggingChange('disabled');
    } catch (e) {
      debugPrint('⚠️ Failed to disable Firestore logging: $e');
    }
  }
  
  /// Safely log Firestore logging changes
  static void _logFirestoreLoggingChange(String action) {
    try {
      logger.info(
        'Firestore logging $action',
        category: LogCategory.system,
        action: 'firestore_logging_$action',
      );
    } catch (e) {
      debugPrint('📝 Firestore logging $action');
    }
  }
  
  /// Get current configuration summary
  static Map<String, dynamic> getCurrentConfig() {
    try {
      return {
        'environment': _isProduction ? 'production' : 'development',
        'logLevel': logger.minimumLogLevel.name,
        'consoleLogging': logger.enableConsoleLogging,
        'firestoreLogging': logger.enableFirestoreLogging,
        'debugMode': logger.enableDebugMode,
      };
    } catch (e) {
      // Return safe defaults if logger is not available
      return {
        'environment': _isProduction ? 'production' : 'development',
        'logLevel': 'info',
        'consoleLogging': true,
        'firestoreLogging': false,
        'debugMode': _isDevelopment,
        'status': 'fallback_config',
      };
    }
  }
  
  /// Reset to default configuration
  static void resetToDefault() {
    try {
      if (_isProduction) {
        _configureProduction();
      } else {
        _configureDevelopment();
      }
      
      _logConfigurationReset();
      
    } catch (e) {
      debugPrint('⚠️ Failed to reset logging configuration: $e');
      _configureSafeDefaults();
    }
  }
  
  /// Safely log configuration reset
  static void _logConfigurationReset() {
    try {
      logger.info(
        'Logging configuration reset to default',
        category: LogCategory.system,
        action: 'reset_configuration',
      );
    } catch (e) {
      debugPrint('📝 Logging configuration reset to default');
    }
  }
}
