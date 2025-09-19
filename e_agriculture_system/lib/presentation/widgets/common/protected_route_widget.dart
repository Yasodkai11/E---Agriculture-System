import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final String requiredPermission;
  final String? fallbackRoute;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.requiredPermission,
    this.fallbackRoute,
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
          case 'authenticated':
            hasPermission = authProvider.isAuthenticated;
            break;
          default:
            hasPermission = true; // Default to allowing access
        }

        if (!hasPermission) {
          return _buildAccessDeniedScreen(context, authProvider);
        }

        return child;
      },
    );
  }

  Widget _buildAccessDeniedScreen(BuildContext context, AuthProvider authProvider) {
    String title = 'Access Denied';
    String message = 'You do not have permission to access this feature.';
    
    // Customize message based on permission type
    switch (requiredPermission) {
      case 'farmer':
        title = 'Farmer Access Required';
        message = 'This feature is only available to farmers.';
        break;
      case 'buyer':
        title = 'Buyer Access Required';
        message = 'This feature is only available to buyers.';
        break;
      case 'seller':
        title = 'Seller Access Required';
        message = 'You need seller permissions to access this feature.';
        break;
      case 'buyer_marketplace':
        title = 'Buyer Access Required';
        message = 'You need buyer permissions to access this feature.';
        break;
      case 'authenticated':
        title = 'Authentication Required';
        message = 'Please log in to access this feature.';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Go to Dashboard'),
                  ),
                  if (fallbackRoute != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(fallbackRoute!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Alternative Route'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (!authProvider.isAuthenticated)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Login'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Convenience widgets for common protection scenarios
class FarmerOnlyRoute extends StatelessWidget {
  final Widget child;
  
  const FarmerOnlyRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      requiredPermission: 'farmer',
      child: child,
    );
  }
}

class BuyerOnlyRoute extends StatelessWidget {
  final Widget child;
  
  const BuyerOnlyRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      requiredPermission: 'buyer',
      child: child,
    );
  }
}

class SellerOnlyRoute extends StatelessWidget {
  final Widget child;
  
  const SellerOnlyRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      requiredPermission: 'seller',
      child: child,
    );
  }
}

class AuthenticatedRoute extends StatelessWidget {
  final Widget child;
  
  const AuthenticatedRoute({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProtectedRoute(
      requiredPermission: 'authenticated',
      child: child,
    );
  }
}
