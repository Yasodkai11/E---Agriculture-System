import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:e_agriculture_system/data/models/sri_lankan_bank_model.dart';
import 'package:e_agriculture_system/data/models/order_model.dart';
import 'package:e_agriculture_system/presentation/screens/payment/sri_lankan_bank_payment_screen.dart';
import 'package:e_agriculture_system/presentation/widgets/payment/payment_method_selection_widget.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String productName;
  final String sellerId;
  final String productId;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.productName,
    required this.sellerId,
    required this.productId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            _buildOrderSummary(),
            const SizedBox(height: 24),
            
            // Payment method selection
            PaymentMethodSelectionWidget(
              title: 'Select Payment Method',
              amount: widget.amount,
              onPaymentMethodSelected: _onPaymentMethodSelected,
            ),
            
            const SizedBox(height: 24),
            
            // Payment method specific UI
            if (_selectedPaymentMethod != null) _buildPaymentMethodUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Order ID', widget.orderId),
            _buildSummaryRow('Product', widget.productName),
            _buildSummaryRow('Amount', 'LKR ${widget.amount.toStringAsFixed(2)}'),
            _buildSummaryRow('Status', 'Pending Payment'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodUI() {
    switch (_selectedPaymentMethod!) {
      case PaymentMethod.sriLankanBank:
        return _buildSriLankanBankUI();
      case PaymentMethod.cashOnDelivery:
        return _buildCashOnDeliveryUI();
      case PaymentMethod.mobilePayment:
        return _buildMobilePaymentUI();
      case PaymentMethod.digitalWallet:
        return _buildDigitalWalletUI();
      case PaymentMethod.creditCard:
        return _buildUnavailablePaymentUI();
      case PaymentMethod.debitCard:
        return _buildUnavailablePaymentUI();
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Widget _buildSriLankanBankUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Sri Lankan Bank Transfer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pay securely through your Sri Lankan bank account. You will be redirected to complete the bank transfer process.',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _navigateToSriLankanBankPayment,
            icon: const Icon(Icons.account_balance),
            label: const Text('Continue with Sri Lankan Bank'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCashOnDeliveryUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.money, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pay when you receive the product. No additional fees required.',
                style: TextStyle(color: Colors.green[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _processCashOnDelivery,
            icon: const Icon(Icons.money),
            label: const Text('Confirm Cash on Delivery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildMobilePaymentUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_android, color: Colors.purple[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Mobile Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pay using mobile banking apps like mCash, eZ Cash, or other mobile payment services.',
                style: TextStyle(color: Colors.purple[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _processMobilePayment,
            icon: const Icon(Icons.phone_android),
            label: const Text('Continue with Mobile Payment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalWalletUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.teal[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.teal[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Digital Wallet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pay using digital wallet services like PayHere, FriMi, or other digital payment platforms.',
                style: TextStyle(color: Colors.teal[700]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _processDigitalWallet,
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Continue with Digital Wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildUnavailablePaymentUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 48),
          const SizedBox(height: 8),
          Text(
            'Payment Method Not Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This payment method is currently not available. Please select another option.',
            style: TextStyle(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onPaymentMethodSelected(PaymentMethod method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  void _navigateToSriLankanBankPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SriLankanBankPaymentScreen(
          orderId: widget.orderId,
          amount: widget.amount,
          productName: widget.productName,
          sellerId: widget.sellerId,
        ),
      ),
    );
  }


  void _processCashOnDelivery() {
    // Implement cash on delivery processing
    _showPaymentConfirmation('Cash on Delivery', 'Payment will be collected upon delivery.');
  }


  void _processMobilePayment() {
    // Implement mobile payment processing
    _showPaymentConfirmation('Mobile Payment', 'You will be redirected to mobile payment gateway.');
  }

  void _processDigitalWallet() {
    // Implement digital wallet processing
    _showPaymentConfirmation('Digital Wallet', 'You will be redirected to digital wallet gateway.');
  }

  void _showPaymentConfirmation(String method, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$method Selected'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentError(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Text('Payment Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment processing failed. Please try again or use a different payment method.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                'Error: $error',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry payment
              if (_selectedPaymentMethod != null) {
                _retryPayment();
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _retryPayment() {
    // Reset processing state and retry
    setState(() {
      _isProcessing = false;
    });
    
    // Show retry message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying payment...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
