import 'package:flutter/material.dart';
import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:e_agriculture_system/data/models/order_model.dart';
import 'package:e_agriculture_system/data/models/saved_card_model.dart';
import 'package:e_agriculture_system/core/theme/app_theme.dart';

class EnhancedPaymentMethodScreen extends StatefulWidget {
  final OrderModel order;

  const EnhancedPaymentMethodScreen({
    super.key,
    required this.order,
  });

  @override
  State<EnhancedPaymentMethodScreen> createState() => _EnhancedPaymentMethodScreenState();
}

class _EnhancedPaymentMethodScreenState extends State<EnhancedPaymentMethodScreen> {
  PaymentMethod? _selectedPaymentMethod;
  String? _selectedCardId;

  // Sample payment methods
  final List<PaymentMethodInfo> _paymentMethods = [
    PaymentMethodInfo(
      method: PaymentMethod.cashOnDelivery,
      name: 'Cash On Delivery',
      description: 'Delivery staff to your door, you give money according to the value of the application and delivery fees.',
      icon: '💵',
      isAvailable: true,
      fee: 0.0,
    ),
    PaymentMethodInfo(
      method: PaymentMethod.sriLankanBank,
      name: 'Bank Transfer',
      description: 'eAgriculture will call you back to confirm the order. After confirmation, eAgriculture will proceed to pick up, pack, issue bill and will notify the actual bill for you to transfer. Content of transfer: Phone number of the orderer.',
      icon: '🏦',
      isAvailable: true,
      fee: 0.0,
    ),
  ];

  // Sample saved cards
  final List<SavedCard> _savedCards = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Light teal background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Method',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Method Options
            _buildPaymentMethodOptions(),
            
            const SizedBox(height: 24),
            
            // Saved Cards Section (if Bank Transfer is selected)
            if (_selectedPaymentMethod == PaymentMethod.sriLankanBank)
              _buildSavedCardsSection(),
            
            const SizedBox(height: 24),
            
            // Order Summary
            _buildOrderSummary(),
            
            const SizedBox(height: 24),
            
            // Continue Button
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._paymentMethods.map((method) => _buildPaymentMethodOption(method)),
      ],
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethodInfo method) {
    final isSelected = _selectedPaymentMethod == method.method;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.method;
            _selectedCardId = null; // Reset card selection when changing payment method
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Radio button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          color: Color(0xFF2E7D32),
                          size: 16,
                        ),
                      )
                    : null,
              ),
              
              const SizedBox(width: 16),
              
              // Payment method icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                      : Colors.grey.shade100,
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
              
              // Payment method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      method.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCardsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved Credit Card',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._savedCards.map((card) => _buildSavedCard(card)),
      ],
    );
  }

  Widget _buildSavedCard(SavedCard card) {
    final isSelected = _selectedCardId == card.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCardId = card.id;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // VISA Logo
              Container(
                width: 40,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F71),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'VISA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${card.name}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Card Number: ${card.cardNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expiry Date: ${card.expiryDate}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Change button
              TextButton(
                onPressed: () {
                  // Handle change card
                },
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
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
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSummaryRow('Subtotal', 'LKR ${widget.order.subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Charge', 'LKR ${(widget.order.total * 0.1).toStringAsFixed(2)}'),
          _buildSummaryRow('Shipping fee', 'Free'),
          
          const Divider(height: 24),
          
          _buildSummaryRow(
            'TOTAL',
            'LKR ${widget.order.total.toStringAsFixed(2)}',
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

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _selectedPaymentMethod != null ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    // Handle continue button press
    if (_selectedPaymentMethod == PaymentMethod.cashOnDelivery) {
      // Navigate to cash on delivery confirmation
      Navigator.pop(context, {
        'paymentMethod': _selectedPaymentMethod,
        'cardId': null,
      });
    } else if (_selectedPaymentMethod == PaymentMethod.sriLankanBank) {
      if (_selectedCardId != null) {
        // Navigate to bank transfer with selected card
        Navigator.pop(context, {
          'paymentMethod': _selectedPaymentMethod,
          'cardId': _selectedCardId,
        });
      } else {
        // Show card selection required
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a credit card for bank transfer'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

