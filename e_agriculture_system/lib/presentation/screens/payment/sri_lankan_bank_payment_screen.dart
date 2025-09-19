import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:e_agriculture_system/data/models/sri_lankan_bank_model.dart';
import 'package:e_agriculture_system/data/services/payment_service.dart';
import 'package:e_agriculture_system/presentation/widgets/payment/bank_selection_widget.dart';
import 'package:flutter/material.dart';

class SriLankanBankPaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String productName;
  final String sellerId;

  const SriLankanBankPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.productName,
    required this.sellerId,
  });

  @override
  State<SriLankanBankPaymentScreen> createState() => _SriLankanBankPaymentScreenState();
}

class _SriLankanBankPaymentScreenState extends State<SriLankanBankPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  SriLankanBank? _selectedBank;
  BankAccount? _selectedAccount;
  final TextEditingController _referenceNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _referenceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sri Lankan Bank Payment'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment summary
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            
            // Bank selection
            BankSelectionWidget(
              selectedBank: _selectedBank,
              onBankSelected: (bank) {
                setState(() {
                  _selectedBank = bank;
                  _selectedAccount = null; // Reset account when bank changes
                });
              },
              title: 'Select Bank',
            ),
            
            const SizedBox(height: 24),
            
            // Bank account form
            if (_selectedBank != null) ...[
              BankAccountFormWidget(
                selectedBank: _selectedBank,
                onAccountSelected: (account) {
                  setState(() {
                    _selectedAccount = account;
                  });
                },
                title: 'Bank Account Details',
              ),
              
              const SizedBox(height: 24),
              
              // Reference number
              TextFormField(
                controller: _referenceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Reference Number (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter transaction reference number',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add any additional notes',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Bank transfer instructions
              if (_selectedBank != null) _buildBankTransferInstructions(),
              
              const SizedBox(height: 24),
              
              // Process payment button
              _buildProcessPaymentButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Summary',
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
            _buildSummaryRow('Payment Method', 'Sri Lankan Bank Transfer'),
            _buildSummaryRow('Status', 'Pending'),
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

  Widget _buildBankTransferInstructions() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Bank Transfer Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Please transfer the payment amount to the following account:',
              style: TextStyle(color: Colors.blue[700]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionRow('Bank', _selectedBank!.name),
                  _buildInstructionRow('Account Name', 'E-Agriculture System'),
                  _buildInstructionRow('Account Number', '1234567890'),
                  _buildInstructionRow('Branch', 'Colombo Main Branch'),
                  _buildInstructionRow('Amount', 'LKR ${widget.amount.toStringAsFixed(2)}'),
                  _buildInstructionRow('Reference', 'Order-${widget.orderId}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'After making the transfer, please click "Confirm Payment" and upload the receipt.',
              style: TextStyle(
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedAccount != null && !_isProcessing
            ? _processPayment
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  Text('Processing...'),
                ],
              )
            : const Text(
                'Confirm Payment',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a bank account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create payment record
      final payment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderId: widget.orderId,
        buyerId: '', // This should be the current user ID
        sellerId: widget.sellerId,
        productId: '', // This should be the product ID
        productName: widget.productName,
        amount: widget.amount,
        currency: 'LKR',
        paymentMethod: PaymentMethod.sriLankanBank,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        paymentGateway: 'Sri Lankan Bank Transfer',
        bankId: _selectedBank!.id,
        bankName: _selectedBank!.name,
        accountNumber: _selectedAccount!.accountNumber,
        branchCode: _selectedAccount!.branchCode,
        referenceNumber: _referenceNumberController.text.isNotEmpty
            ? _referenceNumberController.text
            : 'Order-${widget.orderId}',
        notes: _notesController.text,
      );

      // Save payment to Firestore
      await _paymentService.createPayment(payment);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment initiated successfully! Please complete the bank transfer.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back or to payment slip
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process payment: $e'),
            backgroundColor: Colors.red,
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
}
