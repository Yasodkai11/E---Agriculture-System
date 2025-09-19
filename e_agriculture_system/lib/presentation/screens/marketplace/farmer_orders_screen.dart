import 'package:e_agriculture_system/core/constants/app_dimensions.dart';
import 'package:e_agriculture_system/core/theme/app_theme.dart';
import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/marketplace_service.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});

  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService();
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
        final orders = await _marketplaceService.getOrdersBySeller(userId);
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        
        // If no orders found, show sample data for testing
        if (orders.isEmpty) {
          _loadSampleOrders();
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
        _isLoading = false;
      });
      
      // Log the error for debugging
      print('FarmerOrdersScreen Error: $e');
      
      // Load sample data on error for testing
      _loadSampleOrders();
    }
  }

  void _loadSampleOrders() {
    setState(() {
      _orders = [
        OrderModel(
          id: '1',
          buyerId: 'buyer1',
          farmerId: _marketplaceService.currentUserId ?? 'farmer1',
          farmerName: 'Your Farm',
          items: [
            OrderItem(
              productId: '1',
              productName: 'Organic Rice',
              productImage: '🌾',
              price: 185.0,
              quantity: 10,
              total: 1850.0, unitPrice: 0.0, totalPrice: 0.0,
            ),
          ],
          subtotal: 1850.0,
          tax: 185.0,
          shipping: 150.0,
          total: 2185.0,
          status: OrderStatus.pending,
          paymentStatus: PaymentStatus.pending,
          shippingAddress: '123 Main St, Colombo 03',
          contactNumber: '+94 71 123 4567',
          notes: 'Please deliver in the morning',
          orderDate: DateTime.now().subtract(const Duration(days: 1)),
          paymentDetails: {'method': 'Cash on Delivery', 'transactionId': ''},
            isRated: false, createdAt: DateTime.now(), deliveryAddress: '', updatedAt: DateTime.now(), buyerName: '',
        ),
        OrderModel(
          id: '2',
          buyerId: 'buyer2',
          farmerId: _marketplaceService.currentUserId ?? 'farmer1',
          farmerName: 'Your Farm',
          items: [
            OrderItem(
              productId: '2',
              productName: 'Fresh Vegetables',
              productImage: '🥬',
              price: 120.0,
              quantity: 5,
              total: 600.0, unitPrice: 0.0, totalPrice: 0.0,
            ),
          ],
          subtotal: 600.0,
          tax: 60.0,
          shipping: 100.0,
          total: 760.0,
          status: OrderStatus.confirmed,
          paymentStatus: PaymentStatus.completed,
          shippingAddress: '456 Oak Ave, Kandy',
          contactNumber: '+94 77 234 5678',
          notes: '',
          orderDate: DateTime.now().subtract(const Duration(days: 2)),
          paymentDetails: {'method': 'Bank Transfer', 'transactionId': 'TXN789012'},
            isRated: false, createdAt: DateTime.now(), deliveryAddress: '', updatedAt: DateTime.now(), buyerName: '',
        ),
        OrderModel(
          id: '3',
          buyerId: 'buyer3',
          farmerId: _marketplaceService.currentUserId ?? 'farmer1',
          farmerName: 'Your Farm',
          items: [
            OrderItem(
              productId: '3',
              productName: 'Ceylon Tea',
              productImage: '🍃',
              price: 450.0,
              quantity: 2,
                total: 900.0, unitPrice: 0.0, totalPrice: 0.0,
            ),
          ],
          subtotal: 900.0,
          tax: 90.0,
          shipping: 150.0,
          total: 1140.0,
          status: OrderStatus.shipped,
          paymentStatus: PaymentStatus.completed,
          shippingAddress: '789 Beach Rd, Galle',
          contactNumber: '+94 76 345 6789',
          notes: 'Handle with care',
          orderDate: DateTime.now().subtract(const Duration(days: 3)),
          trackingNumber: 'TRK345678',
          paymentDetails: {'method': 'Credit Card', 'transactionId': 'TXN345678'},
            isRated: false, createdAt: DateTime.now(), deliveryAddress: '', updatedAt: DateTime.now(), buyerName: '',
        ),
      ];
      _isLoading = false;
    });
  }

  List<OrderModel> get _filteredOrders {
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
    final pending = _orders.where((order) => order.status == OrderStatus.pending).length;
    final confirmed = _orders.where((order) => order.status == OrderStatus.confirmed).length;
    final delivered = _orders.where((order) => order.status == OrderStatus.delivered).length;

    return {
      'total': total,
      'pending': pending,
      'confirmed': confirmed,
      'delivered': delivered,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Farmer Orders',
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
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildStatsCard(stats),
                    _buildStatusFilter(),
                    Expanded(
                      child: _filteredOrders.isEmpty
                          ? _buildEmptyState()
                          : _buildOrdersList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingL),
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.primaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('Total', stats['total'].toString(), Icons.shopping_bag_outlined),
          ),
          Expanded(
            child: _buildStatItem('Pending', stats['pending'].toString(), Icons.schedule),
          ),
          Expanded(
            child: _buildStatItem('Confirmed', stats['confirmed'].toString(), Icons.check_circle_outline),
          ),
          Expanded(
            child: _buildStatItem('Delivered', stats['delivered'].toString(), Icons.local_shipping),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: AppDimensions.iconL,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontSizeXL,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: AppDimensions.fontSizeS,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
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
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      elevation: 4,
      shadowColor: _getStatusColor(order.status).withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeL,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Buyer: ${order.buyerId}',
                        style: const TextStyle(
                          color: AppTheme.textMedium,
                          fontSize: AppDimensions.fontSizeS,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(order.status),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(order.status).withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Order Date
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: AppDimensions.iconS,
                    color: AppTheme.textMedium,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    'Order Date: ${order.orderDateText}',
                    style: const TextStyle(
                      color: AppTheme.textMedium,
                      fontSize: AppDimensions.fontSizeS,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Order Items
            ...order.items.map((item) => _buildOrderItem(item)),

            const SizedBox(height: AppDimensions.spacingM),

            // Total Section
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeL,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Rs ${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppDimensions.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.spacingL),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGreen, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () => _viewOrderDetails(order),
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text(
                        'View Details',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (order.status == OrderStatus.pending)
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order, OrderStatus.confirmed),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text(
                          'Confirm',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (order.status == OrderStatus.confirmed)
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryGreen, Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order, OrderStatus.shipped),
                        icon: const Icon(Icons.local_shipping_outlined, size: 18),
                        label: const Text(
                          'Ship',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: _buildProductImage(item.productImage),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    fontSize: AppDimensions.fontSizeM,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  'Qty: ${item.quantity} x Rs ${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: AppDimensions.fontSizeS,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs ${item.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                  fontSize: AppDimensions.fontSizeM,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: AppDimensions.fontSizeXS,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageData) {
    // Check if it's a URL
    if (imageData.startsWith('http')) {
      return Image.network(
        imageData,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            color: AppTheme.primaryGreen,
            size: 24,
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
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
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
          style: const TextStyle(fontSize: 24),
        ),
      );
    }
    
    // Default fallback
    return Icon(
      Icons.image_not_supported,
      color: AppTheme.primaryGreen,
      size: 24,
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
            'Orders from buyers will appear here',
            style: TextStyle(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
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
            'Error Loading Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
              Text('Buyer ID: ${order.buyerId}'),
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

  Future<void> _updateOrderStatus(OrderModel order, OrderStatus newStatus) async {
    try {
      await _marketplaceService.updateOrderStatus(order.id, newStatus);
      
      // Reload orders to reflect changes
      await _loadOrders();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
