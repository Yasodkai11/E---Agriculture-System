import 'dart:io';
import 'package:e_agriculture_system/data/models/payment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'unified_image_storage_service.dart';

class MarketplaceService {
  static final MarketplaceService _instance = MarketplaceService._internal();
  factory MarketplaceService() => _instance;
  MarketplaceService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UnifiedImageStorageService _storage = UnifiedImageStorageService();

  // Collection references
  CollectionReference get _productsCollection => _firestore.collection('products');
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _usersCollection => _firestore.collection('users');

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  // Product Operations
  Future<String> createProduct({
    required String name,
    required String description,
    required double price,
    required String unit,
    required int quantity,
    required String category,
    required String location,
    List<File>? images,
    List<String>? imageUrls,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get current user data
      final userDoc = await _usersCollection.doc(currentUserId!).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromMap(userData);

      // Check if user can sell products
      if (!userModel.canSellProducts()) {
        throw Exception('User does not have permission to sell products');
      }

      // Handle images - either upload File objects or use provided URLs
      List<String> finalImageUrls = [];
      
      if (images != null && images.isNotEmpty) {
        // Upload File objects
        finalImageUrls = await _storage.uploadImages(images, 'products');
      } else if (imageUrls != null && imageUrls.isNotEmpty) {
        // Use provided URLs (from web upload)
        finalImageUrls = imageUrls;
      }

      // Create product model
      final productModel = ProductModel(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        price: price,
        unit: unit,
        quantity: quantity,
        category: category,
        imageUrl: finalImageUrls.isNotEmpty ? finalImageUrls.first : null,
        imageUrls: finalImageUrls.isNotEmpty ? finalImageUrls : null,
        sellerId: currentUserId!,
        sellerName: userModel.fullName,
        sellerLocation: location,
        isAvailable: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        specifications: specifications,
        rating: 0.0,
        reviewCount: 0,
      );

      // Save to Firestore
      final docRef = await _productsCollection.add(productModel.toMap());
      
      // Update product with generated ID
      await _productsCollection.doc(docRef.id).update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  Future<List<ProductModel>> getAllProducts({
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? quality,
  }) async {
    try {
      Query query = _productsCollection.where('isAvailable', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                    .where('name', isLessThan: '$searchQuery\uf8ff');
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ensure ID is included
            return ProductModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    try {
      final querySnapshot = await _productsCollection
          .where('sellerId', isEqualTo: sellerId)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ensure ID is included
            return ProductModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get seller products: $e');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      if (productId.isEmpty) {
        throw Exception('Product ID cannot be empty');
      }
      
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure ID is included
        return ProductModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  Future<void> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    String? unit,
    int? quantity,
    String? category,
    String? location,
    List<File>? images,
    Map<String, dynamic>? specifications,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user owns the product
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      if (product.sellerId != currentUserId) {
        throw Exception('User does not have permission to update this product');
      }

      Map<String, dynamic> updateData = {
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (unit != null) updateData['unit'] = unit;
      if (quantity != null) updateData['quantity'] = quantity;
      if (category != null) updateData['category'] = category;
      if (location != null) updateData['sellerLocation'] = location;
      if (specifications != null) updateData['specifications'] = specifications;

      // Handle new images if provided
      if (images != null && images.isNotEmpty) {
        List<String> imageUrls = await _storage.uploadImages(images, 'products');
        if (imageUrls.isNotEmpty) {
          updateData['imageUrl'] = imageUrls.first;
          updateData['imageUrls'] = imageUrls;
        }
      }

      await _productsCollection.doc(productId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user owns the product
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      if (product.sellerId != currentUserId) {
        throw Exception('User does not have permission to delete this product');
      }

      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Order Operations
  Future<String> createOrder({
    required String productId,
    required int quantity,
    required String shippingAddress,
    required String contactNumber,
    String? notes,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Validate product ID
      if (productId.isEmpty) {
        throw Exception('Product ID cannot be empty');
      }

      // Get current user data
      final userDoc = await _usersCollection.doc(currentUserId!).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromMap(userData);

      // Check if user can buy products
      if (!userModel.canBuyProducts()) {
        throw Exception('User does not have permission to buy products');
      }

      // Get product details
      final product = await getProductById(productId);
      if (product == null) {
        throw Exception('Product not found');
      }

      if (!product.isAvailable || product.quantity < quantity) {
        throw Exception('Product not available in requested quantity');
      }

      // Calculate total amount
      final totalAmount = product.price * quantity;

      // Create order item
      final orderItem = OrderItem(
        productId: productId,
        productName: product.name,
        productImage: product.imageUrl ?? '📦',
        price: product.price,
        quantity: quantity,
        total: totalAmount, unitPrice: 0.0, totalPrice: 0.0,
      );

      // Create order model
      final orderModel = OrderModel(
        id: '', // Will be set by Firestore
        buyerId: currentUserId!,
        farmerId: product.sellerId,
        farmerName: product.sellerName,
        items: [orderItem],
        subtotal: totalAmount,
        tax: totalAmount * 0.1, // 10% tax
        shipping: 150.0, // Fixed shipping cost
        total: totalAmount + (totalAmount * 0.1) + 150.0,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        shippingAddress: shippingAddress,
        contactNumber: contactNumber,
        notes: notes ?? '',
        orderDate: DateTime.now(),
        paymentDetails: {'method': 'Cash on Delivery', 'transactionId': ''},
        isRated: false, createdAt: DateTime.now(), deliveryAddress: '', updatedAt: DateTime.now(), buyerName: '',
      );

      // Save order to Firestore
      final docRef = await _ordersCollection.add(orderModel.toMap());
      
      // Update order with generated ID
      await _ordersCollection.doc(docRef.id).update({'id': docRef.id});

      // Note: Product quantity update should be handled by the seller
      // or through a Cloud Function to maintain proper permissions
      // For now, we'll create the order without updating product quantity

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get orders by buyer (for buyer's order tracking)
  Future<List<OrderModel>> getOrdersByBuyer(String buyerId) async {
    try {
      final querySnapshot = await _ordersCollection
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('orderDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Ensure ID is included
            return OrderModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      // If index error, fallback to simple query and sort in memory
      if (e.toString().contains('index')) {
        print('Index not ready, using fallback query for buyer orders');
        final querySnapshot = await _ordersCollection
            .where('buyerId', isEqualTo: buyerId)
            .get();

        final orders = querySnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // Ensure ID is included
              return OrderModel.fromMap(data);
            })
            .toList();
        
        // Sort in memory
        orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        return orders;
      } else {
        throw Exception('Failed to get buyer orders: $e');
      }
    }
  }

  Future<List<OrderModel>> getOrdersBySeller(String sellerId) async {
    try {
      // First try with ordering (requires index)
      try {
        final querySnapshot = await _ordersCollection
            .where('farmerId', isEqualTo: sellerId) // Use farmerId field to match OrderModel
            .orderBy('orderDate', descending: true)
            .get();

        return querySnapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // Ensure ID is included
              return OrderModel.fromMap(data);
            })
            .toList();
      } catch (e) {
        // If index error, fallback to simple query and sort in memory
        if (e.toString().contains('index')) {
          print('Index not ready, using fallback query');
          final querySnapshot = await _ordersCollection
              .where('farmerId', isEqualTo: sellerId) // Use farmerId field to match OrderModel
              .get();

          final orders = querySnapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id; // Ensure ID is included
                return OrderModel.fromMap(data);
              })
              .toList();
          
          // Sort in memory
          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
          return orders;
        } else {
          rethrow;
        }
      }
    } catch (e) {
      throw Exception('Failed to get seller orders: $e');
    }
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure ID is included
        return OrderModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get order details
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      // Check if user has permission to update this order
      if (order.buyerId != currentUserId && order.farmerId != currentUserId) {
        throw Exception('User does not have permission to update this order');
      }

      await _ordersCollection.doc(orderId).update({
        'status': status.name,
      });

      // If farmer is confirming the order, update product quantity
      if (status == OrderStatus.confirmed && order.farmerId == currentUserId) {
        await _updateProductQuantityForOrder(order);
      }
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Helper method to update product quantity when seller confirms order
  Future<void> _updateProductQuantityForOrder(OrderModel order) async {
    try {
      // Update quantity for each item in the order
      for (final item in order.items) {
        // Get current product
        final product = await getProductById(item.productId);
        if (product == null) {
          throw Exception('Product not found');
        }

        // Calculate new quantity
        final newQuantity = product.quantity - item.quantity;
        
        // Update product quantity
        await _productsCollection.doc(item.productId).update({
          'quantity': newQuantity,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Mark product as unavailable if quantity becomes 0
        if (newQuantity <= 0) {
          await _productsCollection.doc(item.productId).update({
            'isAvailable': false,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to update product quantity: $e');
    }
  }

  // Utility Methods
  Future<String> _uploadProductImage(String userId, File image, int index) async {
    try {
      return await _storage.uploadImage(image, 'products', index: index);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  List<String> getProductCategories() {
    return [
      'vegetables',
      'fruits',
      'grains',
      'dairy',
      'meat',
      'poultry',
      'seafood',
      'herbs',
      'spices',
      'other',
    ];
  }

  List<String> getOrderStatuses() {
    return [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
    ];
  }

  // Sample Data for Testing
  Future<void> createSampleProducts() async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get current user data
      final userDoc = await _usersCollection.doc(currentUserId!).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromMap(userData);

      // Check if user can sell products
      if (!userModel.canSellProducts()) {
        throw Exception('User does not have permission to sell products');
      }

      // Sample products data
      final sampleProducts = [
        {
          'name': 'Fresh Organic Tomatoes',
          'description': 'Freshly harvested organic tomatoes, pesticide-free, perfect for salads and cooking. Grown with natural fertilizers.',
          'price': 150.0,
          'unit': 'kg',
          'quantity': 50,
          'category': 'vegetables',
          'location': 'Colombo, Sri Lanka',
        },
        {
          'name': 'Sweet Corn',
          'description': 'Sweet and juicy corn, harvested at peak freshness. Perfect for boiling, grilling, or making corn soup.',
          'price': 80.0,
          'unit': 'pieces',
          'quantity': 100,
          'category': 'vegetables',
          'location': 'Kandy, Sri Lanka',
        },
        {
          'name': 'Fresh Mangoes',
          'description': 'Ripe and sweet mangoes, perfect for eating fresh or making smoothies. Available in various sizes.',
          'price': 200.0,
          'unit': 'kg',
          'quantity': 30,
          'category': 'fruits',
          'location': 'Jaffna, Sri Lanka',
        },
        {
          'name': 'Red Rice',
          'description': 'Organic red rice, rich in nutrients and antioxidants. Perfect for healthy meals.',
          'price': 120.0,
          'unit': 'kg',
          'quantity': 200,
          'category': 'grains',
          'location': 'Anuradhapura, Sri Lanka',
        },
      ];

      // Create each sample product
      for (final productData in sampleProducts) {
        final productModel = ProductModel(
          id: '',
          name: productData['name'] as String,
          description: productData['description'] as String,
          price: productData['price'] as double,
          unit: productData['unit'] as String,
          quantity: productData['quantity'] as int,
          category: productData['category'] as String,
          imageUrl: null, // No images for sample products
          sellerId: currentUserId!,
          sellerName: userModel.fullName,
          sellerLocation: productData['location'] as String,
          isAvailable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          specifications: {
            'Quality': 'Premium',
            'Harvest Date': DateTime.now().subtract(Duration(days: 2)).toString().split(' ')[0],
            'Storage': 'Refrigerated',
          },
          rating: 0.0,
          reviewCount: 0,
        );

        // Save to Firestore
        final docRef = await _productsCollection.add(productModel.toMap());
        await _productsCollection.doc(docRef.id).update({'id': docRef.id});
      }

      print('✅ Sample products created successfully!');
    } catch (e) {
      throw Exception('Failed to create sample products: $e');
    }
  }
}
