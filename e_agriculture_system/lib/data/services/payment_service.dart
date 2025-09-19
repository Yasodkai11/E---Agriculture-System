import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_model.dart' show PaymentMethod, PaymentModel, PaymentMethodInfo, PaymentStatus;
import '../models/product_model.dart';
import '../models/order_model.dart' show OrderModel, OrderStatus, OrderItem;

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _paymentsCollection => _firestore.collection('payments');
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _productsCollection => _firestore.collection('products');

  // Get available payment methods
  List<PaymentMethodInfo> getAvailablePaymentMethods() {
    return [
      PaymentMethodInfo(
        method: PaymentMethod.cashOnDelivery,
        name: 'Cash on Delivery',
        description: 'Pay when you receive the product',
        icon: '💰',
        isAvailable: true,
      ),
      PaymentMethodInfo(
        method: PaymentMethod.sriLankanBank,
        name: 'Sri Lankan Bank',
        description: 'Pay via Sri Lankan banks',
        icon: '🏛️',
        isAvailable: true,
        fee: 25.0,
        feeDescription: 'Sri Lankan bank fee: LKR 25',
      ),
      PaymentMethodInfo(
        method: PaymentMethod.mobilePayment,
        name: 'Mobile Payment',
        description: 'Pay via mobile banking (mCash, eZ Cash)',
        icon: '📱',
        isAvailable: true,
        fee: 25.0,
        feeDescription: 'Mobile payment fee: LKR 25',
      ),
      PaymentMethodInfo(
        method: PaymentMethod.digitalWallet,
        name: 'Digital Wallet',
        description: 'Pay via digital wallet',
        icon: '💳',
        isAvailable: true,
        fee: 15.0,
        feeDescription: 'Digital wallet fee: LKR 15',
      ),
      PaymentMethodInfo(
        method: PaymentMethod.creditCard,
        name: 'Credit Card',
        description: 'Pay with credit card',
        icon: '💳',
        isAvailable: false, // Not available in Sri Lanka for now
        fee: 100.0,
        feeDescription: 'Credit card fee: LKR 100',
      ),
      PaymentMethodInfo(
        method: PaymentMethod.debitCard,
        name: 'Debit Card',
        description: 'Pay with debit card',
        icon: '💳',
        isAvailable: false, // Not available in Sri Lanka for now
        fee: 75.0,
        feeDescription: 'Debit card fee: LKR 75',
      ),
    ];
  }

  // Create a new order
  Future<OrderModel> createOrder({
    required ProductModel product,
    required int quantity,
    required String deliveryAddress,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderId = _ordersCollection.doc().id;
      final unitPrice = product.price;
      final totalAmount = unitPrice * quantity;
      final shippingCost = _calculateShippingCost(totalAmount);
      final taxAmount = _calculateTax(totalAmount);
      final finalAmount = totalAmount + shippingCost + taxAmount;

      // Create OrderItem for the product
      final orderItem = OrderItem(
        productId: product.id,
        productName: product.name,
        productImage: product.imageUrl ?? '📦', // Use null-safe access
        price: unitPrice,
        quantity: quantity,
        total: totalAmount, unitPrice: 0.0, totalPrice: 0.0,
      );

      final order = OrderModel(
        id: orderId,
        buyerId: user.uid,
        farmerId: product.sellerId, // Use farmerId instead of sellerId
        farmerName: product.sellerName ?? 'Unknown Farmer',
        items: [orderItem], // Use items list instead of individual fields
        subtotal: totalAmount,
        tax: taxAmount,
        shipping: shippingCost,
        total: finalAmount,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        shippingAddress: deliveryAddress,
        contactNumber: '', // Will be filled by buyer
        notes: notes ?? '',
        orderDate: DateTime.now(),
        paymentDetails: {'method': 'Pending', 'transactionId': ''},
        isRated: false, createdAt: DateTime.now(), deliveryAddress: '', updatedAt: DateTime.now(), buyerName: '',
      );

      await _ordersCollection.doc(orderId).set(order.toMap());
      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Process payment
  Future<PaymentModel> processPayment({
    required OrderModel order,
    required PaymentMethod paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final paymentId = _paymentsCollection.doc().id;
      final paymentMethodInfo = getAvailablePaymentMethods()
          .firstWhere((method) => method.method == paymentMethod);

      final payment = PaymentModel(
        id: paymentId,
        orderId: order.id,
        buyerId: order.buyerId,
        sellerId: order.farmerId, // Use farmerId from order
        productId: order.items.isNotEmpty ? order.items.first.productId : '',
        productName: order.items.isNotEmpty ? order.items.first.productName : '',
        amount: order.total, // Use total instead of finalAmount
        paymentMethod: paymentMethod,
        status: PaymentStatus.processing, // Start with processing instead of pending
        createdAt: DateTime.now(),
        paymentGateway: _getPaymentGateway(paymentMethod),
        paymentDetails: paymentDetails,
      );

      // Save payment to Firestore
      await _paymentsCollection.doc(paymentId).set(payment.toMap());

      // Process payment based on method
      PaymentModel processedPayment;
      try {
        switch (paymentMethod) {
          case PaymentMethod.cashOnDelivery:
            processedPayment = await _processCashOnDelivery(payment);
            break;
          case PaymentMethod.sriLankanBank:
            processedPayment = await _processSriLankanBank(payment, paymentDetails);
            break;
          case PaymentMethod.mobilePayment:
            processedPayment = await _processMobilePayment(payment, paymentDetails);
            break;
          case PaymentMethod.digitalWallet:
            processedPayment = await _processDigitalWallet(payment, paymentDetails);
            break;
          default:
            throw Exception('Payment method not supported');
        }

        // Update order status if payment is successful
        if (processedPayment.status == PaymentStatus.completed) {
          await _updateOrderStatus(order.id, OrderStatus.confirmed);
        }

        return processedPayment;
      } catch (processingError) {
        // If payment processing fails, update payment status to failed
        final failedPayment = payment.copyWith(
          status: PaymentStatus.failed,
          updatedAt: DateTime.now(),
          failureReason: processingError.toString(),
          notes: 'Payment processing failed: $processingError',
        );

        await _paymentsCollection.doc(paymentId).update(failedPayment.toMap());
        
        // Update order status to reflect payment failure
        await _updateOrderStatus(order.id, OrderStatus.pending);
        
        throw Exception('Payment processing failed: $processingError');
      }
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // Process Cash on Delivery
  Future<PaymentModel> _processCashOnDelivery(PaymentModel payment) async {
    // For COD, we just mark it as completed since no actual payment processing is needed
    final updatedPayment = payment.copyWith(
      status: PaymentStatus.completed,
      updatedAt: DateTime.now(),
      transactionId: 'COD-${payment.id}',
      notes: 'Payment will be collected on delivery',
    );

    await _paymentsCollection.doc(payment.id).update(updatedPayment.toMap());
    return updatedPayment;
  }


  // Process Mobile Payment
  Future<PaymentModel> _processMobilePayment(
    PaymentModel payment,
    Map<String, dynamic>? details,
  ) async {
    // Simulate mobile payment processing
    await Future.delayed(const Duration(seconds: 3));

    final updatedPayment = payment.copyWith(
      status: PaymentStatus.completed,
      updatedAt: DateTime.now(),
      transactionId: 'MP-${DateTime.now().millisecondsSinceEpoch}',
      paymentDetails: {
        ...?details,
        'provider': details?['provider'] ?? 'mCash',
        'phoneNumber': details?['phoneNumber'] ?? '****1234',
        'reference': details?['reference'] ?? 'MP-${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    await _paymentsCollection.doc(payment.id).update(updatedPayment.toMap());
    return updatedPayment;
  }

  // Process Digital Wallet
  Future<PaymentModel> _processDigitalWallet(
    PaymentModel payment,
    Map<String, dynamic>? details,
  ) async {
    // Simulate digital wallet processing
    await Future.delayed(const Duration(seconds: 2));

    final updatedPayment = payment.copyWith(
      status: PaymentStatus.completed,
      updatedAt: DateTime.now(),
      transactionId: 'DW-${DateTime.now().millisecondsSinceEpoch}',
      paymentDetails: {
        ...?details,
        'walletProvider': details?['walletProvider'] ?? 'PayHere',
        'walletId': details?['walletId'] ?? '****1234',
        'reference': details?['reference'] ?? 'DW-${DateTime.now().millisecondsSinceEpoch}',
      },
    );

    await _paymentsCollection.doc(payment.id).update(updatedPayment.toMap());
    return updatedPayment;
  }

  // Process Sri Lankan Bank Transfer
  Future<PaymentModel> _processSriLankanBank(
    PaymentModel payment,
    Map<String, dynamic>? details,
  ) async {
    // For Sri Lankan bank transfers, we typically start with pending status
    // and wait for manual confirmation or bank notification
    await Future.delayed(const Duration(seconds: 1));

    final updatedPayment = payment.copyWith(
      status: PaymentStatus.pending, // Keep as pending until bank confirms
      updatedAt: DateTime.now(),
      transactionId: payment.transactionId ?? 'SLB-${DateTime.now().millisecondsSinceEpoch}',
      paymentDetails: {
        ...?details,
        'bankName': payment.bankName ?? details?['bankName'],
        'accountNumber': payment.accountNumber ?? details?['accountNumber'],
        'branchCode': payment.branchCode ?? details?['branchCode'],
        'referenceNumber': payment.referenceNumber ?? details?['referenceNumber'],
        'transferInstructions': 'Please complete the bank transfer using the provided instructions',
      },
    );

    await _paymentsCollection.doc(payment.id).update(updatedPayment.toMap());
    return updatedPayment;
  }

  // Create a payment record directly
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      await _paymentsCollection.doc(payment.id).set(payment.toMap());
      return payment;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Get payment gateway name
  String _getPaymentGateway(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'COD';
      case PaymentMethod.sriLankanBank:
        return 'Sri Lankan Bank Transfer';
      case PaymentMethod.mobilePayment:
        return 'Mobile Payment';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.creditCard:
        return 'Credit Card Gateway';
      case PaymentMethod.debitCard:
        return 'Debit Card Gateway';
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // Calculate shipping cost
  double _calculateShippingCost(double amount) {
    if (amount >= 5000) return 0; // Free shipping for orders above LKR 5000
    if (amount >= 2000) return 200; // LKR 200 for orders above LKR 2000
    return 300; // LKR 300 for orders below LKR 2000
  }

  // Calculate tax (VAT)
  double _calculateTax(double amount) {
    return amount * 0.15; // 15% VAT
  }

  // Update order status
  Future<void> _updateOrderStatus(String orderId, OrderStatus status) async {
    await _ordersCollection.doc(orderId).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Get user's payment history
  Future<List<PaymentModel>> getPaymentHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final querySnapshot = await _paymentsCollection
          .where('buyerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  // Get user's orders
  Future<List<OrderModel>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final querySnapshot = await _ordersCollection
          .where('buyerId', isEqualTo: user.uid)
          .orderBy('orderDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ensure ID is included
            return OrderModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure ID is included
        return OrderModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (doc.exists) {
        return PaymentModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _updateOrderStatus(orderId, OrderStatus.cancelled);
      
      // Also update payment status if exists
      final paymentsQuery = await _paymentsCollection
          .where('orderId', isEqualTo: orderId)
          .get();
      
      for (final doc in paymentsQuery.docs) {
        await doc.reference.update({
          'status': PaymentStatus.cancelled.name,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Get pending payments that need attention
  Future<List<PaymentModel>> getPendingPayments() async {
    try {
      final query = await _paymentsCollection
          .where('status', isEqualTo: PaymentStatus.pending.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => PaymentModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending payments: $e');
    }
  }

  // Retry a failed payment
  Future<PaymentModel> retryPayment(String paymentId) async {
    try {
      final payment = await getPaymentById(paymentId);
      if (payment == null) {
        throw Exception('Payment not found');
      }

      if (payment.status != PaymentStatus.failed) {
        throw Exception('Only failed payments can be retried');
      }

      // Update payment status to processing
      final processingPayment = payment.copyWith(
        status: PaymentStatus.processing,
        updatedAt: DateTime.now(),
        failureReason: null,
        notes: 'Retrying payment...',
      );

      await _paymentsCollection.doc(paymentId).update(processingPayment.toMap());

      // Process payment again based on method
      PaymentModel retriedPayment;
      switch (payment.paymentMethod) {
        case PaymentMethod.cashOnDelivery:
          retriedPayment = await _processCashOnDelivery(processingPayment);
          break;
        case PaymentMethod.sriLankanBank:
          retriedPayment = await _processSriLankanBank(processingPayment, payment.paymentDetails);
          break;
        case PaymentMethod.mobilePayment:
          retriedPayment = await _processMobilePayment(processingPayment, payment.paymentDetails);
          break;
        case PaymentMethod.digitalWallet:
          retriedPayment = await _processDigitalWallet(processingPayment, payment.paymentDetails);
          break;
        default:
          throw Exception('Payment method not supported for retry');
      }

      // Update order status if retry is successful
      if (retriedPayment.status == PaymentStatus.completed) {
        await _updateOrderStatus(payment.orderId, OrderStatus.confirmed);
      }

      return retriedPayment;
    } catch (e) {
      // If retry fails, update payment status back to failed
      final payment = await getPaymentById(paymentId);
      if (payment != null) {
        final failedPayment = payment.copyWith(
          status: PaymentStatus.failed,
          updatedAt: DateTime.now(),
          failureReason: e.toString(),
          notes: 'Retry failed: $e',
        );
        await _paymentsCollection.doc(paymentId).update(failedPayment.toMap());
      }
      throw Exception('Failed to retry payment: $e');
    }
  }

  // Clean up stale pending payments (older than 24 hours)
  Future<void> cleanupStalePendingPayments() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
      final query = await _paymentsCollection
          .where('status', isEqualTo: PaymentStatus.pending.name)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffTime))
          .get();

      for (final doc in query.docs) {
        await doc.reference.update({
          'status': PaymentStatus.failed.name,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
          'failureReason': 'Payment expired - no action taken within 24 hours',
          'notes': 'Automatically marked as failed due to inactivity',
        });
      }
    } catch (e) {
      // Log error but don't throw - this is a cleanup operation
      print('Warning: Failed to cleanup stale pending payments: $e');
    }
  }

  // Get payment statistics
  Future<Map<String, int>> getPaymentStatistics() async {
    try {
      final stats = <String, int>{};
      
      for (final status in PaymentStatus.values) {
        final query = await _paymentsCollection
            .where('status', isEqualTo: status.name)
            .get();
        stats[status.name] = query.docs.length;
      }
      
      return stats;
    } catch (e) {
      throw Exception('Failed to get payment statistics: $e');
    }
  }

  // Monitor and handle stuck pending payments
  Future<void> monitorPendingPayments() async {
    try {
      // Get all pending payments
      final pendingPayments = await getPendingPayments();
      
      for (final payment in pendingPayments) {
        final timeSinceCreation = DateTime.now().difference(payment.createdAt);
        
        // If payment has been pending for more than 30 minutes, mark as failed
        if (timeSinceCreation.inMinutes > 30) {
          final failedPayment = payment.copyWith(
            status: PaymentStatus.failed,
            updatedAt: DateTime.now(),
            failureReason: 'Payment stuck in pending status for too long',
            notes: 'Automatically marked as failed after 30 minutes of inactivity',
          );
          
          await _paymentsCollection.doc(payment.id).update(failedPayment.toMap());
          
          // Update order status to reflect payment failure
          await _updateOrderStatus(payment.orderId, OrderStatus.pending);
          
          print('Marked stuck payment ${payment.id} as failed');
        }
      }
    } catch (e) {
      print('Warning: Failed to monitor pending payments: $e');
    }
  }

  // Get payment status summary for dashboard
  Future<Map<String, dynamic>> getPaymentStatusSummary() async {
    try {
      final stats = await getPaymentStatistics();
      final pendingPayments = await getPendingPayments();
      
      return {
        'statistics': stats,
        'pendingCount': pendingPayments.length,
        'needsAttention': pendingPayments.where((p) {
          final timeSinceCreation = DateTime.now().difference(p.createdAt);
          return timeSinceCreation.inMinutes > 15; // Payments pending for more than 15 minutes
        }).length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get payment status summary: $e');
    }
  }
}
