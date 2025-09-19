import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:e_agriculture_system/data/services/payment_service.dart';
import 'package:flutter/material.dart';

class PaymentMethodSelectionWidget extends StatefulWidget {
  final Function(PaymentMethod) onPaymentMethodSelected;
  final String? title;
  final double? amount;

  const PaymentMethodSelectionWidget({
    super.key,
    required this.onPaymentMethodSelected,
    this.title,
    this.amount,
  });

  @override
  State<PaymentMethodSelectionWidget> createState() => _PaymentMethodSelectionWidgetState();
}

class _PaymentMethodSelectionWidgetState extends State<PaymentMethodSelectionWidget> {
  final PaymentService _paymentService = PaymentService();
  List<PaymentMethodInfo> _availableMethods = [];
  PaymentMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() {
    setState(() {
      _availableMethods = _paymentService.getAvailablePaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Payment methods grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _availableMethods.length,
          itemBuilder: (context, index) {
            final method = _availableMethods[index];
            final isSelected = _selectedMethod == method.method;
            final isAvailable = method.isAvailable;
            
            return GestureDetector(
              onTap: isAvailable ? () {
                setState(() {
                  _selectedMethod = method.method;
                });
                widget.onPaymentMethodSelected(method.method);
              } : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isAvailable 
                      ? (isSelected ? Colors.green.withOpacity(0.1) : Colors.white)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.green 
                        : (isAvailable ? Colors.grey[300]! : Colors.grey[200]!),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Text(
                        method.icon,
                        style: TextStyle(
                          fontSize: 32,
                          color: isAvailable 
                              ? (isSelected ? Colors.green : Colors.grey[700])
                              : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Method name
                      Text(
                        method.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isAvailable 
                              ? (isSelected ? Colors.green : Colors.grey[800])
                              : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Description
                      Text(
                        method.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: isAvailable 
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Fee information
                      if (method.fee != null && method.fee! > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Fee: LKR ${method.fee!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      
                      // Not available indicator
                      if (!isAvailable) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Not Available',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      
                      // Selected indicator
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Payment summary if amount is provided
        if (widget.amount != null && _selectedMethod != null) ...[
          const SizedBox(height: 16),
          _buildPaymentSummary(),
        ],
      ],
    );
  }

  Widget _buildPaymentSummary() {
    final selectedMethodInfo = _availableMethods.firstWhere(
      (method) => method.method == _selectedMethod,
    );
    
    final fee = selectedMethodInfo.fee ?? 0.0;
    final total = widget.amount! + fee;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),
          
          _buildSummaryRow('Subtotal', 'LKR ${widget.amount!.toStringAsFixed(2)}'),
          if (fee > 0)
            _buildSummaryRow('${selectedMethodInfo.name} Fee', 'LKR ${fee.toStringAsFixed(2)}'),
          const Divider(),
          _buildSummaryRow(
            'Total Amount', 
            'LKR ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green[800] : Colors.grey[700],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
              color: isTotal ? Colors.green[800] : Colors.grey[800],
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
