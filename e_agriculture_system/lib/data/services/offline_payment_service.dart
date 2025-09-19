import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/payment_model.dart' show PaymentMethod, PaymentModel, PaymentMethodInfo, PaymentStatus;
import '../models/order_model.dart' show OrderModel, OrderStatus, OrderItem;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class OfflinePaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _paymentsCollection => _firestore.collection('payments');
  CollectionReference get _ordersCollection => _firestore.collection('orders');

  // Get available payment methods (optimized for Sri Lanka)
  List<PaymentMethodInfo> getAvailablePaymentMethods() {
    return [
      PaymentMethodInfo(
        method: PaymentMethod.cashOnDelivery,
        name: 'Cash on Delivery',
        description: 'Pay when you receive the product',
        icon: '💰',
        isAvailable: true,
        fee: 0.0,
        feeDescription: 'No additional fees',
      ),
      PaymentMethodInfo(
        method: PaymentMethod.sriLankanBank,
        name: 'Bank Transfer',
        description: 'Transfer to our bank account',
        icon: '🏛️',
        isAvailable: true,
        fee: 0.0,
        feeDescription: 'No additional fees',
      ),
      PaymentMethodInfo(
        method: PaymentMethod.mobilePayment,
        name: 'Mobile Banking',
        description: 'Pay via mCash, eZ Cash, or other mobile banking',
        icon: '📱',
        isAvailable: true,
        fee: 25.0,
        feeDescription: 'Mobile payment fee: LKR 25',
      ),
      PaymentMethodInfo(
        method: PaymentMethod.digitalWallet,
        name: 'Digital Wallet',
        description: 'Pay via digital wallet services',
        icon: '💳',
        isAvailable: true,
        fee: 15.0,
        feeDescription: 'Digital wallet fee: LKR 15',
      ),
    ];
  }

  // Create payment without Firebase functions
  Future<PaymentModel> createPayment({
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

      // Calculate total amount including fees
      final totalAmount = (order.total ?? 0.0) + (paymentMethodInfo.fee ?? 0.0);

      final payment = PaymentModel(
        id: paymentId,
        orderId: order.id,
        buyerId: order.buyerId,
        sellerId: order.farmerId,
        productId: order.items.isNotEmpty ? order.items.first.productId : '',
        productName: order.items.isNotEmpty ? order.items.first.productName : '',
        amount: totalAmount,
        currency: 'LKR',
        paymentMethod: paymentMethod,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        paymentGateway: _getPaymentGateway(paymentMethod),
        paymentDetails: paymentDetails,
        bankName: paymentDetails?['bankName'],
        accountNumber: paymentDetails?['accountNumber'],
        branchCode: paymentDetails?['branchCode'],
        referenceNumber: paymentDetails?['referenceNumber'],
        notes: paymentDetails?['notes'],
      );

      // Save payment to Firestore
      await _paymentsCollection.doc(paymentId).set(payment.toMap());

      // Update order status
      await _updateOrderStatus(order.id, OrderStatus.pending);

      return payment;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Process payment (simplified without external APIs)
  Future<PaymentModel> processPayment({
    required String paymentId,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final paymentDoc = await _paymentsCollection.doc(paymentId).get();
      if (!paymentDoc.exists) {
        throw Exception('Payment not found');
      }

      final payment = PaymentModel.fromMap(paymentDoc.data() as Map<String, dynamic>);
      
      // Simulate payment processing based on method
      PaymentStatus newStatus;
      String? transactionId;
      
      switch (payment.paymentMethod) {
        case PaymentMethod.cashOnDelivery:
          newStatus = PaymentStatus.pending; // Will be confirmed on delivery
          break;
        case PaymentMethod.sriLankanBank:
          newStatus = PaymentStatus.pending; // Requires manual verification
          transactionId = 'BANK_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case PaymentMethod.mobilePayment:
          newStatus = PaymentStatus.completed; // Simulate successful mobile payment
          transactionId = 'MOBILE_${DateTime.now().millisecondsSinceEpoch}';
          break;
        case PaymentMethod.digitalWallet:
          newStatus = PaymentStatus.completed; // Simulate successful wallet payment
          transactionId = 'WALLET_${DateTime.now().millisecondsSinceEpoch}';
          break;
        default:
          newStatus = PaymentStatus.pending;
      }

      // Update payment
      final updatedPayment = payment.copyWith(
        status: newStatus,
        transactionId: transactionId,
        updatedAt: DateTime.now(),
        paymentDetails: {...payment.paymentDetails ?? {}, ...paymentDetails},
      );

      await _paymentsCollection.doc(paymentId).update(updatedPayment.toMap());

      // Update order status if payment is completed
      if (newStatus == PaymentStatus.completed) {
        await _updateOrderStatus(payment.orderId, OrderStatus.confirmed);
      }

      return updatedPayment;
    } catch (e) {
      throw Exception('Failed to process payment: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _paymentsCollection.doc(paymentId).get();
      if (doc.exists && doc.data() != null) {
        return PaymentModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Generate payment slip PDF
  Future<Uint8List> generatePaymentSlipPDF(PaymentModel payment, OrderModel? order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildPDFHeader(),
              pw.SizedBox(height: 20),
              
              // Payment Details
              _buildPDFPaymentDetails(payment),
              pw.SizedBox(height: 20),
              
              // Order Details
              if (order != null) ...[
                _buildPDFOrderDetails(order),
                pw.SizedBox(height: 20),
              ],
              
              // Payment Summary
              _buildPDFPaymentSummary(payment, order),
              pw.SizedBox(height: 30),
              
              // Footer
              _buildPDFFooter(),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  // Download payment slip
  Future<String> downloadPaymentSlip(PaymentModel payment, OrderModel? order) async {
    try {
      final pdfBytes = await generatePaymentSlipPDF(payment, order);
      
      if (kIsWeb) {
        // For web platform
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'Payment_Slip_${payment.id}',
        );
        return 'PDF opened in new tab';
      } else {
        // For mobile/desktop platforms
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/payment_slip_${payment.id}.pdf');
        
        await file.writeAsBytes(pdfBytes);
        return file.path;
      }
    } catch (e) {
      throw Exception('Failed to download payment slip: $e');
    }
  }

  // Share payment slip
  Future<void> sharePaymentSlip(PaymentModel payment, OrderModel? order) async {
    try {
      final pdfBytes = await generatePaymentSlipPDF(payment, order);
      
      if (kIsWeb) {
        // For web platform
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: 'payment_slip_${payment.id}.pdf',
        );
      } else {
        // For mobile/desktop platforms
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/payment_slip_${payment.id}.pdf');
        
        await file.writeAsBytes(pdfBytes);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Payment Slip - ${payment.id}',
        );
      }
    } catch (e) {
      throw Exception('Failed to share payment slip: $e');
    }
  }

  // Helper methods
  String _getPaymentGateway(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.sriLankanBank:
        return 'Sri Lankan Bank Transfer';
      case PaymentMethod.mobilePayment:
        return 'Mobile Banking';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      default:
        return 'Unknown';
    }
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // PDF Building Methods
  pw.Widget _buildPDFHeader() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.green,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'E-Agriculture System',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Payment Receipt',
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on: ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFPaymentDetails(PaymentModel payment) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Payment Details',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildPDFDetailRow('Payment ID', payment.id),
        _buildPDFDetailRow('Order ID', payment.orderId),
        _buildPDFDetailRow('Transaction ID', payment.transactionId ?? 'N/A'),
        _buildPDFDetailRow('Status', payment.status.name.toUpperCase()),
        _buildPDFDetailRow('Payment Method', _getPaymentMethodDisplayName(payment.paymentMethod)),
        _buildPDFDetailRow('Payment Gateway', payment.paymentGateway ?? 'N/A'),
        if (payment.bankName != null)
          _buildPDFDetailRow('Bank', payment.bankName!),
        if (payment.accountNumber != null)
          _buildPDFDetailRow('Account Number', payment.accountNumber!),
        if (payment.branchCode != null)
          _buildPDFDetailRow('Branch Code', payment.branchCode!),
        if (payment.referenceNumber != null)
          _buildPDFDetailRow('Reference Number', payment.referenceNumber!),
        _buildPDFDetailRow('Date', _formatDate(payment.createdAt)),
        if (payment.updatedAt != null)
          _buildPDFDetailRow('Last Updated', _formatDate(payment.updatedAt!)),
      ],
    );
  }

  pw.Widget _buildPDFOrderDetails(OrderModel order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Order Details',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildPDFDetailRow('Farmer', order.farmerName),
        _buildPDFDetailRow('Order Status', order.status.name.toUpperCase()),
        _buildPDFDetailRow('Order Date', _formatDate(order.orderDate)),
        if (order.deliveryDate != null)
          _buildPDFDetailRow('Delivery Date', _formatDate(order.deliveryDate!)),
        if (order.trackingNumber != null)
          _buildPDFDetailRow('Tracking Number', order.trackingNumber!),
        _buildPDFDetailRow('Shipping Address', order.shippingAddress),
        _buildPDFDetailRow('Contact Number', order.contactNumber),
        if (order.notes.isNotEmpty)
          _buildPDFDetailRow('Notes', order.notes),
      ],
    );
  }

  pw.Widget _buildPDFPaymentSummary(PaymentModel payment, OrderModel? order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Payment Summary',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green,
          ),
        ),
        pw.SizedBox(height: 10),
        if (order != null) ...[
          _buildPDFDetailRow('Subtotal', '${payment.currency} ${order.subtotal.toStringAsFixed(2)}'),
          _buildPDFDetailRow('Tax (15%)', '${payment.currency} ${order.tax.toStringAsFixed(2)}'),
          _buildPDFDetailRow('Shipping', '${payment.currency} ${order.shipping.toStringAsFixed(2)}'),
          pw.Divider(),
        ],
        _buildPDFDetailRow(
          'Total Amount',
          '${payment.currency} ${payment.amount.toStringAsFixed(2)}',
          isTotal: true,
        ),
      ],
    );
  }

  pw.Widget _buildPDFFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        'Thank you for your business!\nThis is an automated receipt generated by E-Agriculture System.\n\nFor support, contact: support@eagriculture.lk',
        style: pw.TextStyle(
          fontSize: 12,
          color: PdfColors.grey700,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildPDFDetailRow(String label, String value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.mobilePayment:
        return 'Mobile Payment';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.sriLankanBank:
        return 'Sri Lankan Bank Transfer';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}






