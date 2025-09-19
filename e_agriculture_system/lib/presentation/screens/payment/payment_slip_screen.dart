import 'package:e_agriculture_system/data/models/order_model.dart';
import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:e_agriculture_system/data/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class PaymentSlipScreen extends StatefulWidget {
  final String paymentId;
  final String? orderId;

  const PaymentSlipScreen({
    super.key,
    required this.paymentId,
    this.orderId,
  });

  @override
  State<PaymentSlipScreen> createState() => _PaymentSlipScreenState();
}

class _PaymentSlipScreenState extends State<PaymentSlipScreen> {
  final PaymentService _paymentService = PaymentService();
  PaymentModel? _payment;
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
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
      appBar: AppBar(
        title: const Text('Payment Slip'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_payment != null)
            IconButton(
              onPressed: _downloadPDF,
              icon: const Icon(Icons.download),
              tooltip: 'Download PDF',
            ),
          if (_payment != null)
            IconButton(
              onPressed: _sharePDF,
              icon: const Icon(Icons.share),
              tooltip: 'Share PDF',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text('Loading payment details...'),
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
                backgroundColor: Colors.green,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentDetailsCard(),
          const SizedBox(height: 20),
          _buildOrderDetailsCard(),
          const SizedBox(height: 20),
          _buildPaymentSummaryCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Payment ID', _payment!.id),
            _buildDetailRow('Order ID', _payment!.orderId),
            _buildDetailRow('Transaction ID', _payment!.transactionId ?? 'N/A'),
            _buildDetailRow('Status', _payment!.status.name.toUpperCase()),
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
    if (_order == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Farmer', _order!.farmerName),
            _buildDetailRow('Order Status', _order!.status.name.toUpperCase()),
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
          child: ElevatedButton.icon(
            onPressed: _downloadPDF,
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _sharePDF,
            icon: const Icon(Icons.share),
            label: const Text('Share PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Back to Dashboard'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green : Colors.grey,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? Colors.green : Colors.black,
              ),
              textAlign: TextAlign.end,
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
        return 'Sri Lankan Bank';
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadPDF() async {
    try {
      final pdf = await _generatePDF();
      
      if (kIsWeb) {
        // For web platform, use printing package to open PDF in new tab
        await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => await pdf.save(),
          name: 'Payment_Slip_${_payment!.id}',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF opened in new tab'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For mobile/desktop platforms
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/payment_slip_${_payment!.id}.pdf');
        
        await file.writeAsBytes(await pdf.save());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved to: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
      final pdf = await _generatePDF();
      
      if (kIsWeb) {
        // For web platform, use printing package to open in new tab
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
          name: 'payment_slip_${_payment!.id}.pdf',
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF opened in new tab for sharing'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For mobile/desktop platforms
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/payment_slip_${_payment!.id}.pdf');
        
        await file.writeAsBytes(await pdf.save());
        
        if (mounted) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Payment Slip - ${_payment!.id}',
          );
        }
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

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
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
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Payment Details
              pw.Text(
                'Payment Details',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                ),
              ),
              pw.SizedBox(height: 10),
              
              _buildPDFDetailRow('Payment ID', _payment!.id),
              _buildPDFDetailRow('Order ID', _payment!.orderId),
              _buildPDFDetailRow('Transaction ID', _payment!.transactionId ?? 'N/A'),
              _buildPDFDetailRow('Status', _payment!.status.name.toUpperCase()),
              _buildPDFDetailRow('Payment Method', _getPaymentMethodDisplayName(_payment!.paymentMethod)),
              _buildPDFDetailRow('Payment Gateway', _payment!.paymentGateway ?? 'N/A'),
              if (_payment!.bankName != null)
                _buildPDFDetailRow('Bank', _payment!.bankName!),
              if (_payment!.accountNumber != null)
                _buildPDFDetailRow('Account Number', _payment!.accountNumber!),
              if (_payment!.branchCode != null)
                _buildPDFDetailRow('Branch Code', _payment!.branchCode!),
              if (_payment!.referenceNumber != null)
                _buildPDFDetailRow('Reference Number', _payment!.referenceNumber!),
              _buildPDFDetailRow('Date', _formatDate(_payment!.createdAt)),
              
              if (_order != null) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Order Details',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
                pw.SizedBox(height: 10),
                
                _buildPDFDetailRow('Farmer', _order!.farmerName),
                _buildPDFDetailRow('Order Status', _order!.status.name.toUpperCase()),
                _buildPDFDetailRow('Order Date', _formatDate(_order!.orderDate)),
                if (_order!.deliveryDate != null)
                  _buildPDFDetailRow('Delivery Date', _formatDate(_order!.deliveryDate!)),
                if (_order!.trackingNumber != null)
                  _buildPDFDetailRow('Tracking Number', _order!.trackingNumber!),
                _buildPDFDetailRow('Shipping Address', _order!.shippingAddress),
                _buildPDFDetailRow('Contact Number', _order!.contactNumber),
              ],
              
              pw.SizedBox(height: 20),
              
              // Payment Summary
              pw.Text(
                'Payment Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green,
                ),
              ),
              pw.SizedBox(height: 10),
              
              if (_order != null) ...[
                _buildPDFDetailRow('Subtotal', '${_payment!.currency} ${_order!.subtotal.toStringAsFixed(2)}'),
                _buildPDFDetailRow('Tax (15%)', '${_payment!.currency} ${_order!.tax.toStringAsFixed(2)}'),
                _buildPDFDetailRow('Shipping', '${_payment!.currency} ${_order!.shipping.toStringAsFixed(2)}'),
                pw.Divider(),
              ],
              
              _buildPDFDetailRow(
                'Total Amount',
                '${_payment!.currency} ${_payment!.amount.toStringAsFixed(2)}',
                isTotal: true,
              ),
              
              pw.SizedBox(height: 30),
              
              // Footer
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'Thank you for your business!\nThis is an automated receipt generated by E-Agriculture System.',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
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
}
