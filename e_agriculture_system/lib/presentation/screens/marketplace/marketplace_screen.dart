import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../data/services/marketplace_service.dart';
import '../../../data/models/product_model.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/payment_service.dart';
import '../../../data/models/payment_model.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _marketplaceService.getAllProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    try {
      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (shouldDelete == true) {
        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        try {
          // Call the actual delete service
          await _marketplaceService.deleteProduct(product.id);
          
          // Remove from local lists
          setState(() {
            _products.removeWhere((p) => p.id == product.id);
            _filteredProducts.removeWhere((p) => p.id == product.id);
          });

          // Close loading dialog
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Product "${product.name}" deleted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Close loading dialog
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete product: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterProducts() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredProducts = _products.where((product) {
        bool matchesSearch = product.name.toLowerCase().contains(searchQuery) ||
                           product.description.toLowerCase().contains(searchQuery) ||
                           product.sellerName.toLowerCase().contains(searchQuery);
        
        bool matchesCategory = _selectedCategory == 'all' || 
                             product.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _testBuyingFunctionality(ProductModel product) {
    // Show a dialog with product information and buying options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${product.name}'),
            Text('Price: Rs. ${product.price.toStringAsFixed(2)}'),
            Text('Quantity Available: ${product.quantity} ${product.unit}'),
            Text('Seller: ${product.sellerName}'),
            const SizedBox(height: 16),
            const Text('Buying Options:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildBuyingOption('Quick Buy', 'Buy directly with default settings', () {
              Navigator.pop(context);
              _quickBuy(product);
            }),
            const SizedBox(height: 8),
            _buildBuyingOption('Custom Order', 'Customize quantity and delivery', () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.productDetail,
                arguments: product,
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyingOption(String title, String description, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryGreen),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickBuy(ProductModel product) async {
    try {
      final paymentService = PaymentService();
      
      // Create order
      final order = await paymentService.createOrder(
        product: product,
        quantity: 1,
        deliveryAddress: 'Default Address', // In real app, get from user profile
      );

      // Process payment (Cash on Delivery)
      final payment = await paymentService.processPayment(
        order: order,
        paymentMethod: PaymentMethod.cashOnDelivery,
      );

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed successfully! Order ID: ${order.id}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh products to show updated quantities
      _loadProducts();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSampleData() async {
    try {
      await _marketplaceService.createSampleProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample products created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadProducts(); // Reload the products list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create sample data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build different app bar actions based on user role
  Widget _buildAppBarActions(AuthProvider authProvider) {
    if (authProvider.isFarmer) {
      // Farmer actions: Add product, manage products, sample data
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.myProducts);
            },
            tooltip: 'My Products',
          ),
          IconButton(
            icon: const Icon(Icons.data_usage),
            onPressed: () => _createSampleData(),
            tooltip: 'Add Sample Data',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addProduct);
            },
            tooltip: 'Add Product',
          ),
        ],
      );
    } else if (authProvider.isBuyer) {
      // Buyer actions: My orders, favorites, cart
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.myOrders);
            },
            tooltip: 'My Orders',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.favorites);
            },
            tooltip: 'Favorites',
          ),
        ],
      );
    }
    
    // Default actions for other user types
    return const SizedBox.shrink();
  }

  // Build different floating action button based on user role
  Widget? _buildFloatingActionButton(AuthProvider authProvider) {
    if (authProvider.isFarmer) {
      // Farmers can add products
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addProduct);
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      );
    } else if (authProvider.isBuyer) {
      // Buyers can view their orders
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.myOrders);
        },
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        tooltip: 'My Orders',
        child: const Icon(Icons.shopping_cart),
      );
    }
    
    return null;
  }

  // Build different welcome message based on user role
  Widget _buildWelcomeMessage(AuthProvider authProvider) {
    if (authProvider.isFarmer) {
      return Container(
        padding: ResponsiveHelper.getResponsivePadding(context),
        margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.store,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Farmer Marketplace',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Text(
                    'Manage your products and view orders from buyers',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (authProvider.isBuyer) {
      return Container(
        padding: ResponsiveHelper.getResponsivePadding(context),
        margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.shopping_basket,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buyer Marketplace',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  Text(
                    'Browse fresh products from local farmers',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              authProvider.isFarmer 
                ? 'Farmer Marketplace' 
                : authProvider.isBuyer 
                  ? 'Buyer Marketplace'
                  : 'Marketplace'
            ),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [_buildAppBarActions(authProvider)],
          ),
          body: Column(
            children: [
              // Role-based welcome message
              _buildWelcomeMessage(authProvider),
              
              // Search and Filter Section
              Container(
                padding: ResponsiveHelper.getResponsivePadding(context),
                color: Colors.grey.shade50,
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: authProvider.isBuyer 
                          ? 'Search products to buy...' 
                          : 'Search your products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => _filterProducts(),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
                    
                    // Category Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('all', 'All'),
                          ..._marketplaceService.getProductCategories().map(
                            (category) => _buildCategoryChip(
                              category,
                              category[0].toUpperCase() + category.substring(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Products List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _buildErrorWidget()
                        : _filteredProducts.isEmpty
                            ? _buildEmptyWidget(authProvider)
                            : _buildProductsList(authProvider),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(authProvider),
        );
      },
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: ResponsiveHelper.getCompactSpacing(context, 0.008)),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
          _filterProducts();
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryGreen,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildProductsList(AuthProvider authProvider) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: ResponsiveHelper.getResponsivePadding(context),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _buildProductCard(product, authProvider);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, AuthProvider authProvider) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetail,
            arguments: product,
          );
        },
        child: Padding(
          padding: ResponsiveHelper.getResponsivePadding(context),
          child: ResponsiveHelper.isSmallScreen(context)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mobile Layout: Stacked
                    Row(
                      children: [
                        // Product Image
                        Container(
                          width: ResponsiveHelper.getResponsiveWidth(context, 0.2),
                          height: ResponsiveHelper.getResponsiveHeight(context, 0.1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                            color: Colors.grey.shade200,
                          ),
                          child: product.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                                  child: Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: ResponsiveHelper.getResponsiveIconSize(context),
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade400,
                                  size: ResponsiveHelper.getResponsiveIconSize(context),
                                ),
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),
                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.035),
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
                              Text(
                                'Rs. ${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                    // Description
                    Text(
                      product.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                    // Category and Quantity
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.01),
                            vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.005),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                          ),
                          child: Text(
                            product.category,
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${product.quantity} ${product.unit}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                    // Seller Info
                    Text(
                      authProvider.isFarmer ? 'Your Product' : 'by ${product.sellerName}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                    // Action Button
                    if (authProvider.isBuyer) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _testBuyingFunctionality(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                            ),
                          ),
                          child: Text(
                            'Buy Now',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else if (authProvider.isFarmer) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.editProduct,
                                  arguments: product,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryGreen,
                                side: BorderSide(color: AppTheme.primaryGreen),
                                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                                ),
                              ),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _deleteProduct(product),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
                                padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Desktop Layout: Side by side
                    Container(
                      width: ResponsiveHelper.getResponsiveImageSize(context, 0.08),
                      height: ResponsiveHelper.getResponsiveImageSize(context, 0.08),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                        color: Colors.grey.shade200,
                      ),
                      child: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                              child: Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                    size: ResponsiveHelper.getResponsiveIconSize(context),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.image_not_supported,
                              color: Colors.grey.shade400,
                              size: ResponsiveHelper.getResponsiveIconSize(context),
                            ),
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.02)),

                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.035),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.005)),
                          Text(
                            product.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveHelper.getResponsiveSpacing(context, 0.01),
                                  vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.005),
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                                ),
                                child: Text(
                                  product.category,
                                  style: TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${product.quantity} ${product.unit}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                          Row(
                            children: [
                              Text(
                                'Rs. ${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.04),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                authProvider.isFarmer ? 'Your Product' : 'by ${product.sellerName}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.025),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 0.015)),
                          Row(
                            children: [
                              if (authProvider.isBuyer) ...[
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _testBuyingFunctionality(product);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                                      ),
                                    ),
                                    child: Text(
                                      'Buy Now',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else if (authProvider.isFarmer) ...[
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.editProduct,
                                        arguments: product,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryGreen,
                                      side: BorderSide(color: AppTheme.primaryGreen),
                                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                                      ),
                                    ),
                                    child: Text(
                                      'Edit Product',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _deleteProduct(product),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: BorderSide(color: Colors.red),
                                      padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getResponsiveSpacing(context, 0.01)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context)),
                                      ),
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 0.03),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
            'Error Loading Products',
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
            onPressed: _loadProducts,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(AuthProvider authProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            authProvider.isFarmer ? Icons.inventory_2_outlined : Icons.shopping_basket_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            authProvider.isFarmer 
              ? 'No Products Listed' 
              : 'No Products Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authProvider.isFarmer
              ? 'Start selling by adding your first product'
              : 'Check back later for fresh products from local farmers',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          if (authProvider.isFarmer)
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addProduct);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Your First Product'),
            ),
        ],
      ),
    );
  }
}
