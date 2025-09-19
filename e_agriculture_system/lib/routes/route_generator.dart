import 'package:e_agriculture_system/presentation/screens/admin/admin_test_screen.dart';
import 'package:e_agriculture_system/presentation/screens/dashboard/enhanced_daily_screen.dart';
import 'package:e_agriculture_system/presentation/screens/dashboard/enhanced_financial_records_screen.dart';
import 'package:e_agriculture_system/presentation/screens/marketplace/my_orders_screen.dart';
import 'package:e_agriculture_system/presentation/screens/marketplace/search_farmers_screen.dart';
import 'package:e_agriculture_system/presentation/screens/buyer/delivery_tracking_screen.dart';
import 'package:e_agriculture_system/presentation/screens/buyer/support_screen.dart';
import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/registration_screen.dart';
import '../presentation/screens/auth/reset_password_screen.dart';
import '../presentation/screens/auth/enhanced_forgot_password_screen.dart';
import '../presentation/screens/auth/change_password_screen.dart';
import '../presentation/screens/auth/otp_auth_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/dashboard/crop_monitor_screen.dart';
import '../presentation/screens/dashboard/weather_forecast_screen.dart';
import '../presentation/screens/dashboard/expert_chat_screen.dart';
import '../presentation/screens/dashboard/notification_screen.dart';
import '../presentation/screens/dashboard/market_prices_screen.dart';
import '../presentation/screens/dashboard/farm_equipment_screen.dart';
import '../presentation/screens/dashboard/pest_control_screen.dart';
import '../presentation/screens/dashboard/harvest_planning_screen.dart';
import '../presentation/screens/splash/welcome_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/dashboard/farm_details_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/dashboard/firestore_data_viewer_screen.dart';
import '../presentation/screens/marketplace/marketplace_screen.dart';
import '../presentation/screens/marketplace/add_product_screen.dart';
import '../presentation/screens/marketplace/product_detail_screen.dart';
import '../presentation/screens/marketplace/farmer_orders_screen.dart';
import '../presentation/screens/profile/notifications_screen.dart';
import '../presentation/screens/profile/privacy_security_screen.dart';
import '../presentation/screens/profile/help_support_screen.dart';
import '../presentation/screens/profile/about_screen.dart';
import '../presentation/screens/profile/enhanced_profile_screen.dart';
import '../presentation/screens/profile/buyer_profile_screen.dart';
import '../presentation/screens/notifications/enhanced_notification_screen.dart';
import '../presentation/screens/chatbot/chatbot_training_screen.dart';
import '../presentation/screens/chatbot/chatbot_setup_screen.dart';
import '../presentation/widgets/common/protected_route_widget.dart';
import '../data/models/product_model.dart';
import 'app_routes.dart';
import '../presentation/screens/marketplace/my_products_screen.dart';
import '../presentation/screens/payment/payment_slip_screen.dart';
import '../presentation/screens/payment/payment_screen.dart';
import '../presentation/screens/payment/sri_lankan_bank_payment_screen.dart';
import '../presentation/screens/payment/enhanced_payment_screen.dart';
import '../presentation/screens/payment/enhanced_payment_slip_screen.dart';
import '../presentation/screens/payment/payment_ui_demo_screen.dart';
import '../app.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Log the route being requested for debugging
    print('🛣️ Route requested: ${settings.name}');

    // Handle specific routes
    switch (settings.name) {
      case AppRoutes.root:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegistrationScreen(),
          settings: settings,
        );

      case AppRoutes.resetPassword:
        return MaterialPageRoute(
          builder: (_) => const ResetPasswordScreen(),
          settings: settings,
        );
      case AppRoutes.enhancedResetPassword:
        return MaterialPageRoute(
          builder: (_) => const EnhancedForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(
            child: ChangePasswordScreen(
              arguments: settings.arguments as Map<String, dynamic>?,
            ),
          ),
          settings: settings,
        );

      case AppRoutes.otpAuth:
        return MaterialPageRoute(
          builder: (_) => OtpAuthScreen(
            arguments: settings.arguments as Map<String, dynamic>?,
          ),
          settings: settings,
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: DashboardScreen()),
          settings: settings,
        );

      case AppRoutes.cropMonitor:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: CropMonitorScreen()),
          settings: settings,
        );

      case AppRoutes.weather:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: WeatherScreen()),
          settings: settings,
        );

      case AppRoutes.expertChat:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: ExpertChatScreen()),
          settings: settings,
        );

      case AppRoutes.daily:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: EnhancedDailyScreen()),
          settings: settings,
        );

      case AppRoutes.enhancedDaily:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: EnhancedDailyScreen()),
          settings: settings,
        );

      case AppRoutes.adminTest:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: AdminTestScreen()),
          settings: settings,
        );

      case AppRoutes.searchFarmers:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: SearchFarmersScreen()),
          settings: settings,
        );

      case AppRoutes.favorites:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(
            child: Scaffold(
              appBar: AppBar(title: const Text('Favorites')),
              body: const Center(
                child: Text('Favorites screen coming soon...'),
              ),
            ),
          ),
          settings: settings,
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: NotificationScreen()),
          settings: settings,
        );

      case AppRoutes.marketPrices:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: MarketPricesScreen()),
          settings: settings,
        );

      case AppRoutes.farmEquipment:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: FarmEquipmentScreen()),
          settings: settings,
        );

      case AppRoutes.pestControl:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: PestControlScreen()),
          settings: settings,
        );

      case AppRoutes.harvestPlanning:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: HarvestPlanningScreen()),
          settings: settings,
        );

      case AppRoutes.financialRecords:
        return MaterialPageRoute(
          builder: (_) =>
              FarmerOnlyRoute(child: EnhancedFinancialRecordsScreen()),
          settings: settings,
        );

      case AppRoutes.farmDetails:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: FarmDetailsScreen()),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: ProfileScreen()),
          settings: settings,
        );

      case AppRoutes.enhancedProfile:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: EnhancedProfileScreen()),
          settings: settings,
        );

      case AppRoutes.buyerProfile:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: BuyerProfileScreen()),
          settings: settings,
        );

      case AppRoutes.enhancedNotifications:
        return MaterialPageRoute(
          builder: (_) =>
              AuthenticatedRoute(child: EnhancedNotificationScreen()),
          settings: settings,
        );

      case AppRoutes.chatbotTraining:
        return MaterialPageRoute(
          builder: (_) => const ChatbotTrainingScreen(),
          settings: settings,
        );

      case AppRoutes.chatbotSetup:
        return MaterialPageRoute(
          builder: (_) => const ChatbotSetupScreen(),
          settings: settings,
        );
      // Profile Settings Routes
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: NotificationsScreen()),
          settings: settings,
        );

      case AppRoutes.privacySecurity:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: PrivacySecurityScreen()),
          settings: settings,
        );

      case AppRoutes.helpSupport:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: HelpSupportScreen()),
          settings: settings,
        );

      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: AboutScreen()),
          settings: settings,
        );

      case AppRoutes.firestoreDataViewer:
        return MaterialPageRoute(
          builder: (_) => FarmerOnlyRoute(child: FirestoreDataViewerScreen()),
          settings: settings,
        );

      case AppRoutes.enhancedFinancialRecords:
        return MaterialPageRoute(
          builder: (_) =>
              FarmerOnlyRoute(child: EnhancedFinancialRecordsScreen()),
          settings: settings,
        );

      // Marketplace Routes
      case AppRoutes.marketplace:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: MarketplaceScreen()),
          settings: settings,
        );

      case AppRoutes.addProduct:
        return MaterialPageRoute(
          builder: (_) => SellerOnlyRoute(child: AddProductScreen()),
          settings: settings,
        );

      case AppRoutes.editProduct:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) =>
              SellerOnlyRoute(child: AddProductScreen(productToEdit: product)),
          settings: settings,
        );

      case AppRoutes.myOrders:
        // Buyer Orders - Track purchases
        return MaterialPageRoute(
          builder: (_) => const MyOrdersScreen(),
          settings: settings,
        );

      case AppRoutes.farmerOrders:
        // Farmer Orders - Manage incoming orders
        return MaterialPageRoute(
          builder: (_) => const FarmerOrdersScreen(),
          settings: settings,
        );

      case AppRoutes.myProducts:
        // Farmer Products - Manage listings
        return MaterialPageRoute(
          builder: (_) => const MyProductsScreen(),
          settings: settings,
        );

      case AppRoutes.productDetail:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
          settings: settings,
        );

      case AppRoutes.deliveryTracking:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: DeliveryTrackingScreen()),
          settings: settings,
        );

      case AppRoutes.support:
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(child: SupportScreen()),
          settings: settings,
        );

      case AppRoutes.paymentSlip:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(
            child: PaymentSlipScreen(
              paymentId: args?['paymentId'] ?? '',
              orderId: args?['orderId'],
            ),
          ),
          settings: settings,
        );
      case AppRoutes.enhancedPayment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(
            child: EnhancedPaymentScreen(order: args?['order']),
          ),
          settings: settings,
        );
      case AppRoutes.enhancedPaymentSlip:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(
            child: EnhancedPaymentSlipScreen(
              paymentId: args?['paymentId'] ?? '',
              orderId: args?['orderId'],
            ),
          ),
          settings: settings,
        );
      case AppRoutes.paymentUIDemo:
        return MaterialPageRoute(
          builder: (_) => const PaymentUIDemoScreen(),
          settings: settings,
        );

      case AppRoutes.payment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(
            child: PaymentScreen(
              orderId: args?['orderId'] ?? '',
              amount: (args?['amount'] ?? 0.0).toDouble(),
              productName: args?['productName'] ?? '',
              sellerId: args?['sellerId'] ?? '',
              productId: args?['productId'] ?? '',
            ),
          ),
          settings: settings,
        );

      case AppRoutes.sriLankanBankPayment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AuthenticatedRoute(
            child: SriLankanBankPaymentScreen(
              orderId: args?['orderId'] ?? '',
              amount: (args?['amount'] ?? 0.0).toDouble(),
              productName: args?['productName'] ?? '',
              sellerId: args?['sellerId'] ?? '',
            ),
          ),
          settings: settings,
        );

      case '':
      case '/':
        // Handle root and empty routes by redirecting to welcome
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: const RouteSettings(name: AppRoutes.welcome),
        );

      case 'index.html':
      case 'index.htm':
        // Handle web-specific routes
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: const RouteSettings(name: AppRoutes.welcome),
        );

      default:
        // Log unknown route for debugging
        print('❌ Unknown route: ${settings.name}');

        // Return a default route for unknown routes
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Page Not Found'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Page Not Found',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The requested page "${settings.name}" was not found.',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final navigatorKey = App.currentNavigatorKey;
                      if (navigatorKey?.currentContext != null) {
                        Navigator.pushReplacementNamed(
                          navigatorKey!.currentContext!,
                          AppRoutes.dashboard,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go to Dashboard'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final navigatorKey = App.currentNavigatorKey;
                      if (navigatorKey?.currentContext != null) {
                        Navigator.pushReplacementNamed(
                          navigatorKey!.currentContext!,
                          AppRoutes.welcome,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go to Welcome'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

// Note: Navigator key is now managed by the App class to avoid GlobalKey conflicts
