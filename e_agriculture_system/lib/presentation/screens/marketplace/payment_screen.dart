import 'package:e_agriculture_system/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:e_agriculture_system/l10n/app_localizations.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/payment_service.dart';
import '../../widgets/common/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final ProductModel product;
  final int quantity;
  final String deliveryAddress;

  const PaymentScreen({
    super.key,
    required this.product,
    required this.quantity,
    required this.deliveryAddress,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  OrderModel? _order;
  Map<String, TextEditingController> _paymentControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _paymentControllers = {
      'bankName': TextEditingController(),
      'accountNumber': TextEditingController(),
      'phoneNumber': TextEditingController(),
      'walletId': TextEditingController(),
      'reference': TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (var controller in _paymentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalAmount = widget.product.price * widget.quantity;
    final shippingCost = _calculateShippingCost(totalAmount);
    final taxAmount = _calculateTax(totalAmount);
    final finalAmount = totalAmount + shippingCost + taxAmount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.payment),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildOrderSummaryCard(l10n, totalAmount, shippingCost, taxAmount, finalAmount),
            
            const SizedBox(height: 24),
            
            // Payment Methods
            _buildPaymentMethodsSection(l10n),
            
            const SizedBox(height: 24),
            
            // Payment Details Form
            if (_selectedPaymentMethod != null && _selectedPaymentMethod != PaymentMethod.cashOnDelivery)
              _buildPaymentDetailsForm(l10n),
            
            const SizedBox(height: 32),
            
            // Pay Button
            _buildPayButton(l10n, finalAmount),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(
    AppLocalizations l10n,
    double totalAmount,
    double shippingCost,
    double taxAmount,
    double finalAmount,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.orderSummary,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Product Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                          child: widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty
            ? Image.network(
                widget.product.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.quantity} x LKR ${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Price Breakdown
            _buildPriceRow(l10n.subtotal, totalAmount),
            _buildPriceRow(l10n.shipping, shippingCost),
            _buildPriceRow(l10n.tax, taxAmount),
            const Divider(),
            _buildPriceRow(
              l10n.total,
              finalAmount,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'LKR ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection(AppLocalizations l10n) {
    final paymentMethods = _paymentService.getAvailablePaymentMethods();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectPaymentMethod,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...paymentMethods.where((method) => method.isAvailable).map((method) {
          return _buildPaymentMethodCard(l10n, method);
        }),
      ],
    );
  }

  Widget _buildPaymentMethodCard(AppLocalizations l10n, PaymentMethodInfo method) {
    final isSelected = _selectedPaymentMethod == method.method;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      method.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (method.fee != null && method.fee! > 0)
                      Text(
                        method.feeDescription ?? 'Fee: LKR ${method.fee!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Radio<PaymentMethod>(
                value: method.method,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsForm(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.paymentDetails,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_selectedPaymentMethod == PaymentMethod.bankTransfer) ...[
              _buildTextField(
                controller: _paymentControllers['bankName']!,
                label: l10n.bankName,
                hint: 'Enter bank name',
                icon: Icons.account_balance,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _paymentControllers['accountNumber']!,
                label: l10n.accountNumber,
                hint: 'Enter account number',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _paymentControllers['reference']!,
                label: l10n.reference,
                hint: 'Enter reference number',
                icon: Icons.receipt,
              ),
            ] else if (_selectedPaymentMethod == PaymentMethod.mobilePayment) ...[
              _buildTextField(
                controller: _paymentControllers['phoneNumber']!,
                label: l10n.phoneNumber,
                hint: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _paymentControllers['reference']!,
                label: l10n.reference,
                hint: 'Enter reference number',
                icon: Icons.receipt,
              ),
            ] else if (_selectedPaymentMethod == PaymentMethod.digitalWallet) ...[
              _buildTextField(
                controller: _paymentControllers['walletId']!,
                label: l10n.walletId,
                hint: 'Enter wallet ID',
                icon: Icons.wallet,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _paymentControllers['reference']!,
                label: l10n.reference,
                hint: 'Enter reference number',
                icon: Icons.receipt,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildPayButton(AppLocalizations l10n, double finalAmount) {
    return CustomButton(
      text: _isProcessing 
          ? l10n.processing 
          : '${l10n.payNow} LKR ${finalAmount.toStringAsFixed(2)}',
      onPressed: _selectedPaymentMethod == null || _isProcessing 
          ? null 
          : _processPayment,
      isLoading: _isProcessing,
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create order first
      _order = await _paymentService.createOrder(
        product: widget.product,
        quantity: widget.quantity,
        deliveryAddress: widget.deliveryAddress,
      );

      // Prepare payment details
      Map<String, dynamic>? paymentDetails;
      if (_selectedPaymentMethod != PaymentMethod.cashOnDelivery) {
        paymentDetails = _getPaymentDetails();
      }

      // Process payment
      final payment = await _paymentService.processPayment(
        order: _order!,
        paymentMethod: _selectedPaymentMethod!,
        paymentDetails: paymentDetails,
      );

      // Show success dialog
      if (mounted) {
        _showPaymentSuccessDialog(payment);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Payment failed';
        
        // Provide more specific error messages based on the error
        if (e.toString().contains('PaymentStatus.pending')) {
          errorMessage = 'Payment is pending. Please wait for confirmation or contact support.';
        } else if (e.toString().contains('User not authenticated')) {
          errorMessage = 'Please log in to complete your payment.';
        } else if (e.toString().contains('Payment processing failed')) {
          errorMessage = 'Payment processing failed. Please try again or use a different payment method.';
        } else if (e.toString().contains('Payment method not supported')) {
          errorMessage = 'Selected payment method is not supported. Please choose another option.';
        } else {
          errorMessage = 'Payment failed: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Clear the error and allow retry
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _processPayment();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Map<String, dynamic> _getPaymentDetails() {
    final details = <String, dynamic>{};
    
    switch (_selectedPaymentMethod) {
      case PaymentMethod.sriLankanBank:
        details['bankName'] = _paymentControllers['bankName']!.text;
        details['accountNumber'] = _paymentControllers['accountNumber']!.text;
        details['reference'] = _paymentControllers['reference']!.text;
        break;
      case PaymentMethod.mobilePayment:
        details['phoneNumber'] = _paymentControllers['phoneNumber']!.text;
        details['reference'] = _paymentControllers['reference']!.text;
        break;
      case PaymentMethod.digitalWallet:
        details['walletId'] = _paymentControllers['walletId']!.text;
        details['reference'] = _paymentControllers['reference']!.text;
        break;
      case PaymentMethod.cashOnDelivery:
        details['paymentMethod'] = 'Cash on Delivery';
        break;
      case PaymentMethod.creditCard:
        details['cardNumber'] = _paymentControllers['cardNumber']?.text ?? '';
        details['reference'] = _paymentControllers['reference']!.text;
        break;
      case PaymentMethod.debitCard:
        details['cardNumber'] = _paymentControllers['cardNumber']?.text ?? '';
        details['reference'] = _paymentControllers['reference']!.text;
        break;
      case null:
        // Handle null payment method - return empty details
        break;
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
    
    return details;
  }

  void _showPaymentSuccessDialog(PaymentModel payment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${payment.orderId}'),
            Text('Transaction ID: ${payment.transactionId}'),
            Text('Amount: LKR ${payment.amount.toStringAsFixed(2)}'),
            Text('Payment Method: ${_getPaymentMethodName(payment.paymentMethod)}'),
            const SizedBox(height: 16),
            const Text(
              'Your order has been confirmed and will be processed soon.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to marketplace
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushNamed(
                context,
                '/payment-slip',
                arguments: {
                  'paymentId': payment.id,
                  'orderId': payment.orderId,
                },
              );
            },
            child: const Text('View Receipt'),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.mobilePayment:
        return 'Mobile Payment';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.sriLankanBank:
        return 'Sri Lankan Bank';
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  double _calculateShippingCost(double amount) {
    if (amount >= 5000) return 0;
    if (amount >= 2000) return 200;
    return 300;
  }

  double _calculateTax(double amount) {
    return amount * 0.15; // 15% VAT
  }
}
