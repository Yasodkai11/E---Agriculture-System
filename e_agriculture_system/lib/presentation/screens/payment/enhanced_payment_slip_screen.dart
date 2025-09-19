import 'package:flutter/material.dart';
import 'package:e_agriculture_system/data/models/order_model.dart';
import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:e_agriculture_system/data/services/offline_payment_service.dart';
import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/routes/app_routes.dart';

class EnhancedPaymentSlipScreen extends StatefulWidget {
  final String paymentId;
  final String? orderId;

  const EnhancedPaymentSlipScreen({
    super.key,
    required this.paymentId,
    this.orderId,
  });

  @override
  State<EnhancedPaymentSlipScreen> createState() => _EnhancedPaymentSlipScreenState();
}

class _EnhancedPaymentSlipScreenState extends State<EnhancedPaymentSlipScreen>
    with TickerProviderStateMixin {
  final OfflinePaymentService _paymentService = OfflinePaymentService();
  
  PaymentModel? _payment;
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPaymentData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load payment data
      final payment = await _paymentService.getPaymentById(widget.paymentId);
      
      // Load order data if orderId is provided
      OrderModel? order;
      if (widget.orderId != null) {
        order = await _paymentService.getOrderById(widget.orderId!);
      }

      setState(() {
        _payment = payment;
        _order = order;
        _isLoading = false;
      });

      if (payment == null) {
        setState(() {
          _error = 'Payment not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load payment data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment Slip'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_payment != null) ...[
            IconButton(
              onPressed: _downloadPDF,
              icon: const Icon(Icons.download),
              tooltip: 'Download PDF',
            ),
            IconButton(
              onPressed: _sharePDF,
              icon: const Icon(Icons.share),
              tooltip: 'Share PDF',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryGreen),
            const SizedBox(height: 16),
            const Text('Loading payment details...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPaymentData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_payment == null) {
      return const Center(
        child: Text('Payment not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildHeader(),
          ),

          const SizedBox(height: 24),

          // Payment Details
          SlideTransition(
            position: _slideAnimation,
            child: _buildPaymentDetailsCard(),
          ),

          const SizedBox(height: 20),

          // Order Details
          if (_order != null) ...[
            SlideTransition(
              position: _slideAnimation,
              child: _buildOrderDetailsCard(),
            ),
            const SizedBox(height: 20),
          ],

          // Payment Summary
          SlideTransition(
            position: _slideAnimation,
            child: _buildPaymentSummaryCard(),
          ),

          const SizedBox(height: 30),

          // Action Buttons
          SlideTransition(
            position: _slideAnimation,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Payment Receipt',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generated on ${_formatDate(DateTime.now())}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Payment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Payment ID', _payment!.id),
            _buildDetailRow('Order ID', _payment!.orderId),
            _buildDetailRow('Transaction ID', _payment!.transactionId ?? 'N/A'),
            _buildDetailRow('Status', _getStatusChip(_payment!.status)),
            _buildDetailRow('Payment Method', _getPaymentMethodDisplayName(_payment!.paymentMethod)),
            _buildDetailRow('Payment Gateway', _payment!.paymentGateway ?? 'N/A'),
            if (_payment!.bankName != null)
              _buildDetailRow('Bank', _payment!.bankName!),
            if (_payment!.accountNumber != null)
              _buildDetailRow('Account Number', _payment!.accountNumber!),
            if (_payment!.branchCode != null)
              _buildDetailRow('Branch Code', _payment!.branchCode!),
            if (_payment!.referenceNumber != null)
              _buildDetailRow('Reference Number', _payment!.referenceNumber!),
            _buildDetailRow('Date', _formatDate(_payment!.createdAt)),
            if (_payment!.updatedAt != null)
              _buildDetailRow('Last Updated', _formatDate(_payment!.updatedAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Farmer', _order!.farmerName),
            _buildDetailRow('Order Status', _getStatusChip(_order!.status)),
            _buildDetailRow('Order Date', _formatDate(_order!.orderDate)),
            if (_order!.deliveryDate != null)
              _buildDetailRow('Delivery Date', _formatDate(_order!.deliveryDate!)),
            if (_order!.trackingNumber != null)
              _buildDetailRow('Tracking Number', _order!.trackingNumber!),
            _buildDetailRow('Shipping Address', _order!.shippingAddress),
            _buildDetailRow('Contact Number', _order!.contactNumber),
            if (_order!.notes.isNotEmpty)
              _buildDetailRow('Notes', _order!.notes),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_order != null) ...[
              _buildDetailRow('Subtotal', '${_payment!.currency} ${_order!.subtotal.toStringAsFixed(2)}'),
              _buildDetailRow('Tax (15%)', '${_payment!.currency} ${_order!.tax.toStringAsFixed(2)}'),
              _buildDetailRow('Shipping', '${_payment!.currency} ${_order!.shipping.toStringAsFixed(2)}'),
              const Divider(),
            ],
            _buildDetailRow(
              'Total Amount',
              '${_payment!.currency} ${_payment!.amount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _downloadPDF,
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _sharePDF,
            icon: const Icon(Icons.share),
            label: const Text('Share PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, 
              AppRoutes.dashboard, 
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Dashboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppTheme.primaryGreen : AppTheme.textMedium,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Flexible(
            child: value is Widget 
                ? value 
                : Text(
                    value.toString(),
                    style: TextStyle(
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
                      fontSize: isTotal ? 16 : 14,
                      color: isTotal ? AppTheme.primaryGreen : AppTheme.textDark,
                    ),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusChip(dynamic status) {
    Color color;
    String text;
    
    if (status is PaymentStatus) {
      switch (status) {
        case PaymentStatus.completed:
          color = Colors.green;
          text = 'COMPLETED';
          break;
        case PaymentStatus.pending:
          color = Colors.orange;
          text = 'PENDING';
          break;
        case PaymentStatus.failed:
          color = Colors.red;
          text = 'FAILED';
          break;
        case PaymentStatus.processing:
          color = Colors.blue;
          text = 'PROCESSING';
          break;
        case PaymentStatus.cancelled:
          // TODO: Handle this case.
          throw UnimplementedError();
        case PaymentStatus.refunded:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    } else if (status is OrderStatus) {
      switch (status) {
        case OrderStatus.pending:
          color = Colors.orange;
          text = 'PENDING';
          break;
        case OrderStatus.confirmed:
          color = Colors.green;
          text = 'CONFIRMED';
          break;
        case OrderStatus.shipped:
          color = Colors.blue;
          text = 'SHIPPED';
          break;
        case OrderStatus.delivered:
          color = Colors.green;
          text = 'DELIVERED';
          break;
        case OrderStatus.cancelled:
          color = Colors.red;
          text = 'CANCELLED';
          break;
        case OrderStatus.processing:
          // TODO: Handle this case.
          throw UnimplementedError();
        case OrderStatus.refunded:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    } else {
      color = Colors.grey;
      text = status.toString().toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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

  Future<void> _downloadPDF() async {
    try {
      final result = await _paymentService.downloadPaymentSlip(_payment!, _order);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePDF() async {
    try {
      await _paymentService.sharePaymentSlip(_payment!, _order);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF shared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}






