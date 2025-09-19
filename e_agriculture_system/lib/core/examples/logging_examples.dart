import '../services/logger_service.dart';

/// Example usage of the logging system across different parts of the application
class LoggingExamples {
  
  /// Example 1: Authentication logging
  static void logAuthenticationExample() {
    // User login
    logger.info(
      'User login attempt',
      category: LogCategory.authentication,
      action: 'login_attempt',
      additionalData: {'method': 'email_password'},
    );

    // Login success
    logger.info(
      'User login successful',
      category: LogCategory.authentication,
      action: 'login_success',
      additionalData: {'method': 'email_password', 'timestamp': DateTime.now().toIso8601String()},
    );

    // Login failure
    logger.warning(
      'User login failed',
      category: LogCategory.authentication,
      action: 'login_failed',
      additionalData: {'method': 'email_password', 'reason': 'invalid_credentials'},
    );
  }

  /// Example 2: Data operation logging
  static void logDataOperationExample() {
    // Fetching data
    logger.logDataOperation(
      'fetch_products',
      screenName: 'BuyerProducts',
      collection: 'products',
      additionalData: {'filter': 'category:vegetables', 'limit': 20},
    );

    // Creating data
    logger.logDataOperation(
      'create_order',
      screenName: 'BuyerOrders',
      collection: 'orders',
      additionalData: {'productCount': 3, 'totalAmount': 150.00},
    );

    // Data operation error
    try {
      // Simulate error
      throw Exception('Network timeout');
    } catch (e) {
      logger.logDataOperation(
        'fetch_user_profile',
        screenName: 'BuyerProfile',
        collection: 'users',
        error: e,
        additionalData: {'operation': 'fetch_profile', 'retryCount': 2},
      );
    }
  }

  /// Example 3: Performance logging
  static void logPerformanceExample() async {
    // API call performance
    final stopwatch = Stopwatch()..start();
    
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 2500));
    
    stopwatch.stop();
    logger.logPerformance(
      'API call to products service',
      stopwatch.elapsed,
      screenName: 'BuyerProducts',
    );

    // Database query performance
    final dbStopwatch = Stopwatch()..start();
    
    // Simulate database query
    await Future.delayed(Duration(milliseconds: 800));
    
    dbStopwatch.stop();
    logger.logPerformance(
      'Database query for user orders',
      dbStopwatch.elapsed,
      screenName: 'BuyerOrders',
    );
  }

  /// Example 4: User action logging
  static void logUserActionExample() {
    // Product interaction
    logger.logUserAction(
      'Product viewed',
      screenName: 'BuyerProducts',
      additionalData: {
        'productId': 'prod_123',
        'productName': 'Fresh Tomatoes',
        'category': 'vegetables',
        'viewDuration': '15s',
      },
    );

    // Search action
    logger.logUserAction(
      'Product search performed',
      screenName: 'BuyerProducts',
      additionalData: {
        'searchQuery': 'organic vegetables',
        'resultsCount': 25,
        'searchTime': '2.3s',
        'filtersApplied': ['organic', 'vegetables', 'price_range'],
      },
    );

    // Cart action
    logger.logUserAction(
      'Product added to cart',
      screenName: 'BuyerProducts',
      additionalData: {
        'productId': 'prod_123',
        'quantity': 2,
        'unit': 'kg',
        'price': 25.00,
      },
    );
  }

  /// Example 5: Navigation logging
  static void logNavigationExample() {
    // Screen navigation
    logger.logNavigation(
      'BuyerProducts',
      'ProductDetail',
      additionalData: {
        'productId': 'prod_123',
        'navigationMethod': 'card_tap',
        'previousScreen': 'BuyerProducts',
      },
    );

    // Tab navigation
    logger.logNavigation(
      'BuyerDashboard',
      'BuyerOrders',
      additionalData: {
        'navigationMethod': 'bottom_nav',
        'tabIndex': 2,
        'previousTab': 0,
      },
    );

    // Deep link navigation
    logger.logNavigation(
      'AppLaunch',
      'BuyerDashboard',
      additionalData: {
        'navigationMethod': 'deep_link',
        'deepLink': 'buyer://dashboard',
        'source': 'notification',
      },
    );
  }

  /// Example 6: Error logging with context
  static void logErrorExample() {
    // Network error
    try {
      // Simulate network error
      throw Exception('Connection timeout');
    } catch (e, stackTrace) {
      logger.error(
        'Network request failed',
        category: LogCategory.dataOperation,
        screenName: 'BuyerProducts',
        action: 'fetch_products',
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'endpoint': '/api/products',
          'retryCount': 3,
          'timeout': 30000,
          'userAgent': 'Flutter/3.0.0',
        },
      );
    }

    // Validation error
    try {
      // Simulate validation error
      throw Exception('Invalid email format');
    } catch (e) {
      logger.warning(
        'Form validation failed',
        category: LogCategory.userAction,
        screenName: 'BuyerAuth',
        action: 'form_validation',
        error: e,
        additionalData: {
          'field': 'email',
          'value': 'invalid-email',
          'validationRule': 'email_format',
        },
      );
    }
  }

  /// Example 7: Security logging
  static void logSecurityExample() {
    // Failed authentication attempt
    logger.warning(
      'Multiple failed login attempts detected',
      category: LogCategory.security,
      action: 'failed_login_attempts',
      additionalData: {
        'email': 'user@example.com',
        'attemptCount': 5,
        'timeWindow': '15 minutes',
        'ipAddress': '192.168.1.100',
        'userAgent': 'Flutter/3.0.0',
      },
    );

    // Suspicious activity
    logger.warning(
      'Unusual access pattern detected',
      category: LogCategory.security,
      action: 'suspicious_activity',
      additionalData: {
        'userId': 'user_123',
        'activity': 'multiple_login_attempts',
        'locations': ['New York', 'London', 'Tokyo'],
        'timeSpan': '2 hours',
        'riskLevel': 'medium',
      },
    );
  }

  /// Example 8: Dashboard-specific logging
  static void logDashboardSpecificExample() {
    // Main dashboard actions
    logger.logDashboardAction(
      'Weather card expanded',
      additionalData: {
        'cardType': 'weather',
        'action': 'expand',
        'weatherData': {
          'temperature': '28°C',
          'condition': 'sunny',
          'humidity': '65%',
        },
      },
    );

    // Buyer dashboard actions
    logger.logBuyerDashboardAction(
      'Quick stats accessed',
      additionalData: {
        'statType': 'total_orders',
        'statValue': '12',
        'accessMethod': 'card_tap',
      },
    );

    // Marketplace feature usage
    logger.logBuyerDashboardAction(
      'Marketplace feature accessed',
      additionalData: {
        'feature': 'browse_products',
        'accessMethod': 'feature_card',
        'userPreference': 'frequently_used',
      },
    );
  }

  /// Example 9: Batch logging operations
  static void logBatchOperationsExample() {
    // Log multiple related actions
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    logger.info(
      'User session started',
      category: LogCategory.userAction,
      additionalData: {
        'sessionId': sessionId,
        'startTime': DateTime.now().toIso8601String(),
        'deviceInfo': {
          'platform': 'android',
          'version': '13',
          'appVersion': '1.0.0',
        },
      },
    );

    // Log session activities
    logger.logUserAction(
      'Dashboard loaded',
      additionalData: {'sessionId': sessionId, 'loadTime': '1.2s'},
    );

    logger.logUserAction(
      'Products browsed',
      additionalData: {'sessionId': sessionId, 'productsViewed': 15},
    );

    // Log session end
    logger.info(
      'User session ended',
      category: LogCategory.userAction,
      additionalData: {
        'sessionId': sessionId,
        'endTime': DateTime.now().toIso8601String(),
        'duration': '25 minutes',
        'totalActions': 23,
      },
    );
  }

  /// Example 10: Conditional logging based on environment
  static void logConditionalExample() {
    // Development-only logging
    if (logger.enableDebugMode) {
      logger.debug(
        'Detailed debug information',
        category: LogCategory.system,
        additionalData: {
          'debugLevel': 'detailed',
          'component': 'product_service',
          'method': 'fetchProducts',
          'parameters': {'category': 'all', 'limit': 50},
        },
      );
    }

    // Production-only logging
    if (!logger.enableDebugMode) {
      logger.info(
        'Production mode active',
        category: LogCategory.system,
        additionalData: {
          'mode': 'production',
          'loggingLevel': 'warning_and_above',
          'firestoreLogging': logger.enableFirestoreLogging,
        },
      );
    }
  }
}

/// Usage examples
void main() {
  // Run all examples
  LoggingExamples.logAuthenticationExample();
  LoggingExamples.logDataOperationExample();
  LoggingExamples.logPerformanceExample();
  LoggingExamples.logUserActionExample();
  LoggingExamples.logNavigationExample();
  LoggingExamples.logErrorExample();
  LoggingExamples.logSecurityExample();
  LoggingExamples.logDashboardSpecificExample();
  LoggingExamples.logBatchOperationsExample();
  LoggingExamples.logConditionalExample();
}
