import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/services/payment_service.dart';

class PaymentMonitor {
  static final PaymentMonitor _instance = PaymentMonitor._internal();
  factory PaymentMonitor() => _instance;
  PaymentMonitor._internal();

  final PaymentService _paymentService = PaymentService();
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  // Start monitoring payments
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    // Monitor every 5 minutes
    _monitoringTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _performMonitoring();
    });
    
    if (kDebugMode) {
      print('Payment monitoring started');
    }
  }

  // Stop monitoring payments
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
    
    if (kDebugMode) {
      print('Payment monitoring stopped');
    }
  }

  // Perform the actual monitoring
  Future<void> _performMonitoring() async {
    try {
      await _paymentService.monitorPendingPayments();
      await _paymentService.cleanupStalePendingPayments();
      
      if (kDebugMode) {
        print('Payment monitoring completed at ${DateTime.now()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Payment monitoring error: $e');
      }
    }
  }

  // Get current monitoring status
  bool get isMonitoring => _isMonitoring;

  // Manually trigger monitoring
  Future<void> triggerMonitoring() async {
    await _performMonitoring();
  }

  // Get payment status summary
  Future<Map<String, dynamic>> getPaymentStatusSummary() async {
    return await _paymentService.getPaymentStatusSummary();
  }

  // Dispose resources
  void dispose() {
    stopMonitoring();
  }
}
