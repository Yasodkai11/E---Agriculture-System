import 'services/logger_service.dart';

/// Test the logging system's safety features
class LoggingSafetyTest {
  
  /// Test basic logging without Firebase
  static void testBasicLogging() {
    print('🧪 Testing basic logging functionality...');
    
    try {
      // Test all log levels
      logger.debug('Debug message test');
      logger.info('Info message test');
      logger.warning('Warning message test');
      logger.error('Error message test');
      
      print('✅ Basic logging test passed');
    } catch (e) {
      print('❌ Basic logging test failed: $e');
    }
  }
  
  /// Test dashboard-specific logging
  static void testDashboardLogging() {
    print('🧪 Testing dashboard-specific logging...');
    
    try {
      // Test main dashboard logging
      logger.logDashboardAction('Test dashboard action');
      
      // Test buyer dashboard logging
      logger.logBuyerDashboardAction('Test buyer dashboard action');
      
      // Test navigation logging
      logger.logNavigation('TestScreen', 'AnotherScreen');
      
      // Test user action logging
      logger.logUserAction('Test user action', screenName: 'TestScreen');
      
      print('✅ Dashboard logging test passed');
    } catch (e) {
      print('❌ Dashboard logging test failed: $e');
    }
  }
  
  /// Test performance logging
  static void testPerformanceLogging() {
    print('🧪 Testing performance logging...');
    
    try {
      final stopwatch = Stopwatch()..start();
      
      // Simulate some work
      for (int i = 0; i < 1000000; i++) {
        // Just counting
      }
      
      stopwatch.stop();
      
      // Test performance logging
      logger.logPerformance('Test operation', stopwatch.elapsed);
      
      print('✅ Performance logging test passed');
    } catch (e) {
      print('❌ Performance logging test failed: $e');
    }
  }
  
  /// Test error logging
  static void testErrorLogging() {
    print('🧪 Testing error logging...');
    
    try {
      // Test error logging with exception
      try {
        throw Exception('Test exception for logging');
      } catch (e, stackTrace) {
        logger.error(
          'Test error occurred',
          error: e,
          stackTrace: stackTrace,
          additionalData: {'test': true},
        );
      }
      
      print('✅ Error logging test passed');
    } catch (e) {
      print('❌ Error logging test failed: $e');
    }
  }
  
  /// Test data operation logging
  static void testDataOperationLogging() {
    print('🧪 Testing data operation logging...');
    
    try {
      // Test successful data operation
      logger.logDataOperation(
        'test_fetch',
        screenName: 'TestScreen',
        collection: 'test_collection',
        additionalData: {'test': true},
      );
      
      // Test failed data operation
      try {
        throw Exception('Test data operation error');
      } catch (e) {
        logger.logDataOperation(
          'test_fetch_failed',
          screenName: 'TestScreen',
          collection: 'test_collection',
          error: e,
          additionalData: {'test': true},
        );
      }
      
      print('✅ Data operation logging test passed');
    } catch (e) {
      print('❌ Data operation logging test failed: $e');
    }
  }
  
  /// Test configuration methods
  static void testConfiguration() {
    print('🧪 Testing logging configuration...');
    
    try {
      // Test configuration getters
      final consoleLogging = logger.enableConsoleLogging;
      final firestoreLogging = logger.enableFirestoreLogging;
      final debugMode = logger.enableDebugMode;
      final logLevel = logger.minimumLogLevel;
      
      print('📊 Current configuration:');
      print('  - Console logging: $consoleLogging');
      print('  - Firestore logging: $firestoreLogging');
      print('  - Debug mode: $debugMode');
      print('  - Log level: $logLevel');
      
      print('✅ Configuration test passed');
    } catch (e) {
      print('❌ Configuration test failed: $e');
    }
  }
  
  /// Run all tests
  static void runAllTests() {
    print('🚀 Starting logging safety tests...\n');
    
    testBasicLogging();
    print('');
    
    testDashboardLogging();
    print('');
    
    testPerformanceLogging();
    print('');
    
    testErrorLogging();
    print('');
    
    testDataOperationLogging();
    print('');
    
    testConfiguration();
    print('');
    
    print('🎉 All logging safety tests completed!');
  }
}

/// Run tests if this file is executed directly
void main() {
  LoggingSafetyTest.runAllTests();
}
