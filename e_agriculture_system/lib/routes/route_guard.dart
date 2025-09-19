import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';

class RouteGuard {
  static Route<dynamic>? guardRoute(
    RouteSettings settings,
    AuthProvider authProvider,
  ) {
    // Public routes that don't require authentication
    final publicRoutes = [
      '/login',
      '/register',
      '/reset-password',

      '/welcome',
      '/otp-auth',
    ];

    // Check if route is public
    if (publicRoutes.contains(settings.name)) {
      return null; // Allow access
    }

    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: settings,
      );
    }

    // Role-based route protection
    switch (settings.name) {
      case '/dashboard':
        return _guardDashboardRoute(settings, authProvider);
      
      case '/marketplace':
      case '/add-product':
      case '/my-orders':
        return _guardMarketplaceRoute(settings, authProvider);
      
      case '/crop-monitor':
      case '/weather-forecast':
      case '/farm-equipment':
      case '/pest-control':
      case '/harvest-planning':
      case '/financial-records':
        return _guardFarmerRoute(settings, authProvider);
      
      case '/buyer-products':
      case '/buyer-orders':
      case '/buyer-profile':
        return _guardBuyerRoute(settings, authProvider);
      
      default:
        // For unknown routes, redirect to dashboard
        return MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
          settings: const RouteSettings(name: '/dashboard'),
        );
    }
  }

  static Route<dynamic>? _guardDashboardRoute(
    RouteSettings settings,
    AuthProvider authProvider,
  ) {
    // Dashboard is accessible to all authenticated users
    // The dashboard will show different content based on user role
    return MaterialPageRoute(
      builder: (context) => const DashboardScreen(),
      settings: settings,
    );
  }

  static Route<dynamic>? _guardMarketplaceRoute(
    RouteSettings settings,
    AuthProvider authProvider,
  ) {
    // Marketplace routes require specific permissions
    if (settings.name == '/add-product' || settings.name == '/my-orders') {
      // Add product and view orders require seller permissions
      if (!authProvider.canSellProducts) {
        return _createAccessDeniedRoute(
          'Access Denied',
          'You need seller permissions to access this feature.',
          settings,
        );
      }
    }

    // Marketplace browsing is available to all authenticated users
    return null; // Allow access
  }

  static Route<dynamic>? _guardFarmerRoute(
    RouteSettings settings,
    AuthProvider authProvider,
  ) {
    // Farmer-specific routes
    if (!authProvider.canAccessFarmerDashboard) {
      return _createAccessDeniedRoute(
        'Access Denied',
        'This feature is only available to farmers.',
        settings,
      );
    }

    return null; // Allow access
  }

  static Route<dynamic>? _guardBuyerRoute(
    RouteSettings settings,
    AuthProvider authProvider,
  ) {
    // Buyer-specific routes
    if (!authProvider.canAccessBuyerDashboard) {
      return _createAccessDeniedRoute(
        'Access Denied',
        'This feature is only available to buyers.',
        settings,
      );
    }

    return null; // Allow access
  }

  static Route<dynamic> _createAccessDeniedRoute(
    String title,
    String message,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 80,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      ),
      settings: settings,
    );
  }
}

// Widget wrapper for route protection
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final String requiredPermission;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.requiredPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if user has the required permission
        bool hasPermission = false;
        
        switch (requiredPermission) {
          case 'farmer':
            hasPermission = authProvider.canAccessFarmerDashboard;
            break;
          case 'buyer':
            hasPermission = authProvider.canAccessBuyerDashboard;
            break;
          case 'seller':
            hasPermission = authProvider.canSellProducts;
            break;
          case 'buyer_marketplace':
            hasPermission = authProvider.canBuyProducts;
            break;
          default:
            hasPermission = true; // Default to allowing access
        }

        if (!hasPermission) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block,
                      size: 80,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You do not have permission to access this feature.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Go to Dashboard'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
