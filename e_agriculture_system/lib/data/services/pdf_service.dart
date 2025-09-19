import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/payment_model.dart';
import '../models/order_model.dart';

class PDFService {
  static const String _appName = 'E-Agriculture System';
  static const String _companyName = 'E-Agriculture System';
  static const String _companyAddress = 'Sri Lanka';
  static const String _companyPhone = '+94 XX XXX XXXX';
  static const String _companyEmail = 'support@eagriculture.lk';

  /// Generate and save PDF payment slip
  static Future<String?> generatePaymentSlipPDF({
    required PaymentModel payment,
    OrderModel? order,
    bool saveToDevice = true,
  }) async {
    try {
      final pdf = await _createPaymentSlipPDF(payment, order);
      
      if (saveToDevice) {
        return await _savePDFToDevice(pdf, payment);
      } else {
        return null; // Just return the PDF bytes for sharing
      }
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// Print PDF payment slip
  static Future<void> printPaymentSlip({
    required PaymentModel payment,
    OrderModel? order,
  }) async {
    try {
      final pdf = await _createPaymentSlipPDF(payment, order);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: 'Payment_Slip_${payment.id}',
      );
    } catch (e) {
      throw Exception('Failed to print PDF: $e');
    }
  }

  /// Share PDF payment slip
  static Future<void> sharePaymentSlip({
    required PaymentModel payment,
    OrderModel? order,
  }) async {
    try {
      final pdf = await _createPaymentSlipPDF(payment, order);
      await Printing.sharePdf(
        bytes: pdf,
        filename: 'Payment_Slip_${payment.id}.pdf',
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Create the PDF document
  static Future<Uint8List> _createPaymentSlipPDF(
    PaymentModel payment,
    OrderModel? order,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
            // Header
            _buildHeader(payment),
              pw.SizedBox(height: 24),
              
              // Payment Details
              _buildPaymentDetails(payment),
              pw.SizedBox(height: 16),
              
              // Order Details (if available)
              if (order != null) ...[
                _buildOrderDetails(order),
                pw.SizedBox(height: 16),
              ],
              
              // Payment Status
              _buildPaymentStatus(payment),
              pw.SizedBox(height: 24),
              
              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Build PDF header
  static pw.Widget _buildHeader(PaymentModel payment) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            _appName,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Payment Receipt',
            style: pw.TextStyle(
              fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _companyName,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _companyAddress,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Phone: $_companyPhone',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    'Email: $_companyEmail',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Receipt Date:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _formatDate(payment.createdAt),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build payment details section
  static pw.Widget _buildPaymentDetails(PaymentModel payment) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Payment Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildDetailRow('Transaction ID:', payment.transactionId ?? payment.id),
          _buildDetailRow('Payment ID:', payment.id),
          _buildDetailRow('Amount:', 'LKR ${payment.amount.toStringAsFixed(2)}'),
          _buildDetailRow('Payment Method:', _getPaymentMethodName(payment.paymentMethod)),
          _buildDetailRow('Status:', _getPaymentStatusText(payment.status)),
          _buildDetailRow('Payment Gateway:', payment.paymentGateway ?? 'Unknown'),
          _buildDetailRow('Created At:', _formatDateTime(payment.createdAt)),
          if (payment.updatedAt != null)
            _buildDetailRow('Updated At:', _formatDateTime(payment.updatedAt!)),
          
          if (payment.paymentDetails != null && payment.paymentDetails!.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),
            pw.Text(
              'Additional Details',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            ...payment.paymentDetails!.entries.map(
              (entry) => _buildDetailRow(
                _formatKey(entry.key),
                entry.value.toString(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build order details section
  static pw.Widget _buildOrderDetails(OrderModel order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Order Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildDetailRow('Order ID:', order.id),
          _buildDetailRow('Order Date:', _formatDate(order.orderDate)),
          _buildDetailRow('Subtotal:', 'LKR ${order.subtotal.toStringAsFixed(2)}'),
          _buildDetailRow('Tax (15%):', 'LKR ${order.tax.toStringAsFixed(2)}'),
          _buildDetailRow('Shipping:', 'LKR ${order.shipping.toStringAsFixed(2)}'),
          pw.Divider(color: PdfColors.grey300),
          _buildDetailRow('Total Amount:', 'LKR ${order.total.toStringAsFixed(2)}', isBold: true),
          
          if (order.shippingAddress.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),
            _buildDetailRow('Delivery Address:', order.shippingAddress),
          ],
          
          if (order.notes.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 12),
            _buildDetailRow('Notes:', order.notes),
          ],
        ],
      ),
    );
  }

  /// Build payment status section
  static pw.Widget _buildPaymentStatus(PaymentModel payment) {
    PdfColor statusColor;
    String statusText = _getPaymentStatusText(payment.status);
    
    switch (payment.status) {
      case PaymentStatus.completed:
        statusColor = PdfColors.green;
        break;
      case PaymentStatus.processing:
        statusColor = PdfColors.orange;
        break;
      case PaymentStatus.failed:
        statusColor = PdfColors.red;
        break;
      case PaymentStatus.cancelled:
        statusColor = PdfColors.grey;
        break;
      default:
        statusColor = PdfColors.blue;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: statusColor),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: statusColor,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Payment Status',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  statusText,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  pw.SizedBox(height: 8),
                  pw.Text(
                    payment.notes!,
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build PDF footer
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for using E-Agriculture System!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'This is an official payment receipt. Please keep this document for your records.',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 12),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on ${_formatDateTime(DateTime.now())}',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build detail row for PDF
  static pw.Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.normal,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            ': ',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Save PDF to device
  static Future<String> _savePDFToDevice(Uint8List pdf, PaymentModel payment) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Payment_Slip_${payment.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdf);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save PDF to device: $e');
    }
  }

  /// Helper methods
  static String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
      case PaymentMethod.sriLankanBank:
        return 'Sri Lankan Bank';
      case PaymentMethod.mobilePayment:
        return 'Mobile Payment';
      case PaymentMethod.digitalWallet:
        return 'Digital Wallet';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  static String _formatKey(String key) {
    return key.split(RegExp(r'(?=[A-Z])')).join(' ').toLowerCase().split(' ').map(
      (word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word,
    ).join(' ');
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
