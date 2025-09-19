import 'package:flutter/material.dart';
import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:e_agriculture_system/data/models/order_model.dart';
import 'package:e_agriculture_system/data/services/offline_payment_service.dart';
import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/routes/app_routes.dart';
import 'package:e_agriculture_system/presentation/screens/payment/enhanced_payment_method_screen.dart';

class EnhancedPaymentScreen extends StatefulWidget {
  final OrderModel order;

  const EnhancedPaymentScreen({
    super.key,
    required this.order,
  });

  @override
  State<EnhancedPaymentScreen> createState() => _EnhancedPaymentScreenState();
}

class _EnhancedPaymentScreenState extends State<EnhancedPaymentScreen>
    with TickerProviderStateMixin {
  final OfflinePaymentService _paymentService = OfflinePaymentService();
  
  PaymentMethod? _selectedPaymentMethod;
  Map<String, dynamic> _paymentDetails = {};
  bool _isProcessing = false;
  PaymentModel? _createdPayment;

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header with gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryGreen, AppTheme.accentGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Icon(
                        Icons.payment,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Complete Your Payment',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Order #${widget.order.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Order Summary
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildOrderSummary(),
                  ),

                  const SizedBox(height: 24),

                  // Payment Methods
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildPaymentMethods(),
                  ),

                  const SizedBox(height: 16),

                  // Enhanced Payment Method Button
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildEnhancedPaymentMethodButton(),
                  ),

                  const SizedBox(height: 24),

                  // Payment Details Form
                  if (_selectedPaymentMethod != null)
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildPaymentDetailsForm(),
                    ),

                  const SizedBox(height: 24),

                  // Process Payment Button
                  if (_selectedPaymentMethod != null)
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildProcessPaymentButton(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
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
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Farmer', widget.order.farmerName),
            _buildSummaryRow('Product', widget.order.items.isNotEmpty 
                ? widget.order.items.first.productName 
                : 'Multiple items'),
            _buildSummaryRow('Quantity', '${widget.order.items.length} item(s)'),
            _buildSummaryRow('Subtotal', 'LKR ${widget.order.subtotal.toStringAsFixed(2)}'),
            _buildSummaryRow('Tax (15%)', 'LKR ${widget.order.tax.toStringAsFixed(2)}'),
            _buildSummaryRow('Shipping', 'LKR ${widget.order.shipping.toStringAsFixed(2)}'),
            const Divider(),
            _buildSummaryRow(
              'Total Amount',
              'LKR ${widget.order.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final availableMethods = _paymentService.getAvailablePaymentMethods();

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
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...availableMethods.map((method) => _buildPaymentMethodOption(method)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethodInfo method) {
    final isSelected = _selectedPaymentMethod == method.method;
    final isAvailable = method.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAvailable ? () => _selectPaymentMethod(method.method) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryGreen
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    method.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected 
                            ? AppTheme.primaryGreen
                            : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected 
                            ? AppTheme.primaryGreen
                            : AppTheme.textMedium,
                      ),
                    ),
                    if (method.fee! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        method.feeDescription ?? 'No description available',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 24,
                )
              else if (!isAvailable)
                Icon(
                  Icons.block,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsForm() {
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
                Icon(Icons.info_outline, color: AppTheme.primaryGreen),
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
            _buildPaymentDetailsFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsFields() {
    switch (_selectedPaymentMethod!) {
      case PaymentMethod.sriLankanBank:
        return _buildBankTransferFields();
      case PaymentMethod.mobilePayment:
        return _buildMobilePaymentFields();
      case PaymentMethod.digitalWallet:
        return _buildDigitalWalletFields();
      case PaymentMethod.cashOnDelivery:
        return _buildCashOnDeliveryInfo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBankTransferFields() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Bank Name',
            hintText: 'e.g., Commercial Bank of Ceylon',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance),
          ),
          onChanged: (value) => _paymentDetails['bankName'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Account Number',
            hintText: 'Enter account number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          onChanged: (value) => _paymentDetails['accountNumber'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Branch Code',
            hintText: 'Enter branch code',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          onChanged: (value) => _paymentDetails['branchCode'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Reference Number',
            hintText: 'Enter transaction reference',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.receipt),
          ),
          onChanged: (value) => _paymentDetails['referenceNumber'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Add any additional notes',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
          ),
          maxLines: 3,
          onChanged: (value) => _paymentDetails['notes'] = value,
        ),
      ],
    );
  }

  Widget _buildMobilePaymentFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Mobile Payment Service',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android),
          ),
          items: const [
            DropdownMenuItem(value: 'mcash', child: Text('mCash')),
            DropdownMenuItem(value: 'ezcash', child: Text('eZ Cash')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) => _paymentDetails['service'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            hintText: 'Enter your mobile number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          onChanged: (value) => _paymentDetails['mobileNumber'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Transaction ID',
            hintText: 'Enter transaction ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.receipt),
          ),
          onChanged: (value) => _paymentDetails['transactionId'] = value,
        ),
      ],
    );
  }

  Widget _buildDigitalWalletFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Digital Wallet',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          items: const [
            DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
            DropdownMenuItem(value: 'skrill', child: Text('Skrill')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: (value) => _paymentDetails['wallet'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Wallet Email/ID',
            hintText: 'Enter wallet email or ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          onChanged: (value) => _paymentDetails['walletId'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Transaction ID',
            hintText: 'Enter transaction ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.receipt),
          ),
          onChanged: (value) => _paymentDetails['transactionId'] = value,
        ),
      ],
    );
  }

  Widget _buildCashOnDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
          const SizedBox(height: 12),
          Text(
            'Cash on Delivery',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will pay when you receive the product. No additional information required.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPaymentMethodButton() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _navigateToPaymentMethodSelection,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.accentGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.enhanced_encryption,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enhanced Payment Selection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Choose from modern payment options with visual card selection',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...', style: TextStyle(fontSize: 16)),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 24),
                  SizedBox(width: 8),
                  Text('Process Payment', style: TextStyle(fontSize: 16)),
                ],
              ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isTotal ? AppTheme.primaryGreen : AppTheme.textDark,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _selectPaymentMethod(PaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = method;
      _paymentDetails = {};
    });
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create payment
      final payment = await _paymentService.createPayment(
        order: widget.order,
        paymentMethod: _selectedPaymentMethod!,
        paymentDetails: _paymentDetails,
      );

      // Process payment
      final processedPayment = await _paymentService.processPayment(
        paymentId: payment.id,
        paymentDetails: _paymentDetails,
      );

      setState(() {
        _createdPayment = processedPayment;
        _isProcessing = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment ${processedPayment.status.name} successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Slip',
              textColor: Colors.white,
              onPressed: () => _navigateToPaymentSlip(processedPayment),
            ),
          ),
        );

        // Navigate to payment slip
        _navigateToPaymentSlip(processedPayment);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToPaymentSlip(PaymentModel payment) {
    Navigator.pushNamed(
      context,
      AppRoutes.paymentSlip,
      arguments: {
        'paymentId': payment.id,
        'orderId': widget.order.id,
      },
    );
  }

  Future<void> _navigateToPaymentMethodSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedPaymentMethodScreen(order: widget.order),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedPaymentMethod = result['paymentMethod'];
        if (result['cardId'] != null) {
          _paymentDetails['cardId'] = result['cardId'];
        }
      });
    }
  }
}






