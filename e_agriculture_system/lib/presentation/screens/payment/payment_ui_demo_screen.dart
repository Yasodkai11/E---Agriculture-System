import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:e_agriculture_system/data/models/order_model.dart';
import 'package:e_agriculture_system/data/models/saved_card_model.dart';
import 'package:e_agriculture_system/presentation/screens/payment/enhanced_payment_method_screen.dart';
import 'package:e_agriculture_system/presentation/screens/payment/credit_card_selection_screen.dart';

class PaymentUIDemoScreen extends StatefulWidget {
  const PaymentUIDemoScreen({super.key});

  @override
  State<PaymentUIDemoScreen> createState() => _PaymentUIDemoScreenState();
}

class _PaymentUIDemoScreenState extends State<PaymentUIDemoScreen> {
  // Sample order for demonstration
  final OrderModel _sampleOrder = OrderModel(
    id: 'ORD-001',
    farmerId: 'farmer-001',
    farmerName: 'John Doe',
    buyerId: 'buyer-001',
    buyerName: 'Jane Smith',
    items: [
      OrderItem(
        productId: 'prod-001',
        productName: 'Fresh Tomatoes',
        quantity: 5,
        unitPrice: 150.0,
        totalPrice: 750.0,
        productImage: '',
        price: 150.0,
        total: 750.0,
      ),
    ],
    subtotal: 750.0,
    tax: 112.5,
    shipping: 0.0,
    total: 862.5,
    status: OrderStatus.pending,
    paymentStatus: PaymentStatus.pending,
    shippingAddress: '123 Main Street, Colombo',
    contactNumber: '+94 77 123 4567',
    notes: 'Please deliver in the morning',
    orderDate: DateTime.now(),
    paymentDetails: {},
    isRated: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deliveryAddress: '123 Main Street, Colombo',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8),
      appBar: AppBar(
        title: const Text('Payment UI Demo'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.payment,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Enhanced Payment UI Demo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Experience modern payment selection with visual card display',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Demo Options
            _buildDemoOption(
              title: 'Payment Method Selection',
              description: 'Choose between Cash on Delivery and Bank Transfer with modern UI',
              icon: Icons.payment,
              onTap: () => _navigateToPaymentMethodSelection(),
            ),

            const SizedBox(height: 16),

            _buildDemoOption(
              title: 'Credit Card Selection',
              description: 'Visual credit card display with swipe-to-select functionality',
              icon: Icons.credit_card,
              onTap: () => _navigateToCreditCardSelection(),
            ),

            const SizedBox(height: 24),

            // Features List
            _buildFeaturesList(),

            const SizedBox(height: 24),

            // Order Summary Preview
            _buildOrderSummaryPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoOption({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2E7D32),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'Modern radio button selection with checkmarks',
      'Visual credit card display with gradient design',
      'Order summary with proper styling',
      'Responsive design for all screen sizes',
      'Smooth animations and transitions',
      'Clean and intuitive user interface',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sample Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', 'LKR ${_sampleOrder.subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Charge', 'LKR ${(_sampleOrder.total * 0.1).toStringAsFixed(2)}'),
          _buildSummaryRow('Shipping fee', 'Free'),
          const Divider(height: 24),
          _buildSummaryRow(
            'TOTAL',
            'LKR ${_sampleOrder.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
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
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFF2E7D32) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPaymentMethodSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedPaymentMethodScreen(order: _sampleOrder),
      ),
    );

    if (result != null) {
      _showResultDialog('Payment Method Selection', result.toString());
    }
  }

  Future<void> _navigateToCreditCardSelection() async {
    // Sample saved cards
    final savedCards = [
      SavedCard(
        id: '1',
        name: 'Arianal John',
        cardNumber: '1234 5678 9100 2***',
        expiryDate: '12/22',
        type: 'VISA',
      ),
      SavedCard(
        id: '2',
        name: 'Alice O\' Donell',
        cardNumber: '3213 9921 0307 1245',
        expiryDate: '09/22',
        type: 'VISA',
        cvc: '298',
      ),
    ];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreditCardSelectionScreen(savedCards: savedCards),
      ),
    );

    if (result != null) {
      _showResultDialog('Credit Card Selection', 'Selected Card ID: $result');
    }
  }

  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

