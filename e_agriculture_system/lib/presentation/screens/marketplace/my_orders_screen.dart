import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import '../../../core/constants/app_colors.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/marketplace_service.dart';
import '../../../data/services/payment_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final PaymentService _paymentService = PaymentService();
  
  List<OrderModel> _orders = [];
  String _selectedStatus = 'All';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _marketplaceService.currentUserId;
      if (userId != null) {
        // Try to load real orders first
        final orders = await _marketplaceService.getOrdersByBuyer(userId);
        
        if (orders.isNotEmpty) {
          setState(() {
            _orders = orders;
            _isLoading = false;
          });
        } else {
          // If no real orders, try to load from payment service
          final payments = await _paymentService.getPaymentHistory();
          if (payments.isNotEmpty) {
            // Convert payments to orders for display
            final ordersFromPayments = await _convertPaymentsToOrders(payments);
            setState(() {
              _orders = ordersFromPayments;
              _isLoading = false;
            });
          } else {
            setState(() {
              _orders = [];
              _isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('MyOrdersScreen Error: $e');
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<OrderModel>> _convertPaymentsToOrders(List<dynamic> payments) async {
    // This is a temporary solution until we have proper order creation
    // In a real app, orders should be created when payments are made
    return [];
  }

  Future<void> _refreshOrders() async {
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsCard(stats),
          _buildStatusFilter(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : filteredOrders.isEmpty
                        ? _buildEmptyState()
                        : _buildOrdersList(filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Container(
      margin: ResponsiveHelper.getResponsivePadding(context),
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
      ),
      child: ResponsiveHelper.isSmallScreen(context)
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Total', stats['total'].toString(), '📦'),
                    ),
                    Expanded(
                      child: _buildStatItem('Active', stats['active'].toString(), '🔄'),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem('Delivered', stats['delivered'].toString(), '✅'),
                    ),
                    Expanded(
                      child: _buildStatItem('Cancelled', stats['cancelled'].toString(), '❌'),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total', stats['total'].toString(), '📦'),
                ),
                Expanded(
                  child: _buildStatItem('Active', stats['active'].toString(), '🔄'),
                ),
                Expanded(
                  child: _buildStatItem('Delivered', stats['delivered'].toString(), '✅'),
                ),
                Expanded(
                  child: _buildStatItem('Cancelled', stats['cancelled'].toString(), '❌'),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, String icon) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.05))),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: ResponsiveHelper.getResponsiveHeight(context, 0.06),
      margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Confirmed'),
                _buildFilterChip('Processing'),
                _buildFilterChip('Shipped'),
                _buildFilterChip('Delivered'),
                _buildFilterChip('Cancelled'),
              ],
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
          IconButton(
            onPressed: _refreshOrders,
            icon: Icon(Icons.refresh, size: ResponsiveHelper.getResponsiveIconSize(context)),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.02),
          vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context) * 2),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    return ListView.builder(
      padding: ResponsiveHelper.getResponsivePadding(context),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
        ),
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.035),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.01),
                      vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.005),
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                      border: Border.all(color: _getStatusColor(order.status)),
                    ),
                    child: Text(
                      order.statusText,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
              Text(
                'Farmer: ${order.farmerName}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
              Text(
                'Order Date: ${order.orderDateText}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                ),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
              ...order.items.map((item) => _buildOrderItem(item)),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.035),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rs ${order.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
              ResponsiveHelper.isSmallScreen(context)
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _viewOrderDetails(order),
                            icon: Icon(Icons.visibility, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                            label: Text('View Details'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                            ),
                          ),
                        ),
                        if (order.canCancel || order.canTrack) ...[
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                          Row(
                            children: [
                              if (order.canCancel)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _cancelOrder(order),
                                    icon: Icon(Icons.cancel, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                                    label: Text('Cancel'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                                    ),
                                  ),
                                ),
                              if (order.canCancel && order.canTrack)
                                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                              if (order.canTrack)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _trackOrder(order),
                                    icon: Icon(Icons.local_shipping, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                                    label: Text('Track'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _viewOrderDetails(order),
                            icon: Icon(Icons.visibility, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                            label: Text('View Details'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                        if (order.canCancel)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _cancelOrder(order),
                              icon: Icon(Icons.cancel, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                              label: Text('Cancel'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                              ),
                            ),
                          ),
                        if (order.canCancel && order.canTrack)
                          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                        if (order.canTrack)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _trackOrder(order),
                              icon: Icon(Icons.local_shipping, size: ResponsiveHelper.getResponsiveIconSize(context) * 0.7),
                              label: Text('Track'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                              ),
                            ),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 0.1),
            height: ResponsiveHelper.getResponsiveHeight(context, 0.05),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
              child: _buildProductImage(item.productImage),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity} x Rs ${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rs ${item.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to see your orders here',
            style: TextStyle(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/marketplace');
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Go to Marketplace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Test button - remove in production
          if (kDebugMode)
            OutlinedButton.icon(
              onPressed: _createTestOrder,
              icon: const Icon(Icons.bug_report),
              label: const Text('Create Test Order (Debug)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  List<OrderModel> _getFilteredOrders() {
    if (_selectedStatus == 'All') {
      return _orders;
    }
    
    return _orders.where((order) {
      switch (_selectedStatus) {
        case 'Pending':
          return order.status == OrderStatus.pending;
        case 'Confirmed':
          return order.status == OrderStatus.confirmed;
        case 'Processing':
          return order.status == OrderStatus.processing;
        case 'Shipped':
          return order.status == OrderStatus.shipped;
        case 'Delivered':
          return order.status == OrderStatus.delivered;
        case 'Cancelled':
          return order.status == OrderStatus.cancelled;
        default:
          return true;
      }
    }).toList();
  }

  Map<String, dynamic> _calculateStats() {
    final total = _orders.length;
    final active = _orders.where((order) => 
      order.status != OrderStatus.delivered && 
      order.status != OrderStatus.cancelled
    ).length;
    final delivered = _orders.where((order) => 
      order.status == OrderStatus.delivered
    ).length;
    final cancelled = _orders.where((order) => 
      order.status == OrderStatus.cancelled
    ).length;

    return {
      'total': total,
      'active': active,
      'delivered': delivered,
      'cancelled': cancelled,
    };
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Orders'),
              leading: Radio<String>(
                value: 'All',
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ...OrderStatus.values.map((status) => ListTile(
              title: Text(_getStatusText(status)),
              leading: Radio<String>(
                value: _getStatusText(status),
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  void _viewOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Farmer: ${order.farmerName}'),
              Text('Status: ${order.statusText}'),
              Text('Payment: ${order.paymentStatusText}'),
              Text('Order Date: ${order.orderDateText}'),
              if (order.deliveryDate != null)
                Text('Delivery Date: ${order.deliveryDateText}'),
              if (order.trackingNumber != null)
                Text('Tracking: ${order.trackingNumber}'),
              Text('Address: ${order.shippingAddress}'),
              Text('Contact: ${order.contactNumber}'),
              if (order.notes.isNotEmpty)
                Text('Notes: ${order.notes}'),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${item.productName} - Qty: ${item.quantity} - Rs ${item.total.toStringAsFixed(2)}'),
              )),
              const SizedBox(height: 16),
              Text('Subtotal: Rs ${order.subtotal.toStringAsFixed(2)}'),
              Text('Tax: Rs ${order.tax.toStringAsFixed(2)}'),
              Text('Shipping: Rs ${order.shipping.toStringAsFixed(2)}'),
              Text('Total: Rs ${order.total.toStringAsFixed(2)}', 
                   style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order ${order.orderNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement cancel order logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order cancelled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _trackOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ${order.orderNumber}'),
            Text('Tracking Number: ${order.trackingNumber}'),
            const SizedBox(height: 16),
            const Text('Status: Shipped'),
            const Text('Estimated Delivery: 2-3 business days'),
            const SizedBox(height: 16),
            const Text('Tracking Updates:'),
            Text('• Order shipped from ${order.farmerName}'),
            const Text('• In transit to delivery center'),
            const Text('• Out for delivery'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // New method for creating a test order
  Future<void> _createTestOrder() async {
    try {
      final userId = _marketplaceService.currentUserId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Show instructions for testing
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('How to Test Orders'),
          content: const Text(
            'To test the order management system:\n\n'
            '1. Go to Marketplace\n'
            '2. Add a product (as farmer)\n'
            '3. Place an order (as buyer)\n'
            '4. Check "My Orders" to see your order\n'
            '5. Switch to farmer account to see "Farmer Orders"\n'
            '6. Update order status as farmer\n'
            '7. Check back as buyer to see updates\n\n'
            'The system creates real orders in Firestore when payments are made.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/marketplace');
              },
              child: const Text('Go to Marketplace'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error showing test instructions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildProductImage(String imageData) {
    // Check if it's a URL
    if (imageData.startsWith('http')) {
      return Image.network(
        imageData,
        width: ResponsiveHelper.getResponsiveWidth(context, 0.1),
        height: ResponsiveHelper.getResponsiveHeight(context, 0.05),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            color: AppColors.primary,
            size: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        },
      );
    }
    
    // Check if it's an emoji or fallback
    if (imageData.length <= 4 && !imageData.startsWith('http')) {
      return Center(
        child: Text(
          imageData,
          style: TextStyle(fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.04)),
        ),
      );
    }
    
    // Default fallback
    return Icon(
      Icons.image_not_supported,
      color: AppColors.primary,
      size: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
    );
  }
}


