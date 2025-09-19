import 'package:e_agriculture_system/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_agriculture_system/presentation/widgets/common/bottom_navigation_bar.dart';
import 'package:e_agriculture_system/presentation/widgets/common/buyer_bottom_navigation_bar.dart';
import 'package:e_agriculture_system/presentation/providers/auth_provider.dart';
import 'package:e_agriculture_system/presentation/providers/notification_provider.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utills/responsive_helper.dart';
import '../../../routes/app_routes.dart';
import '../marketplace/my_orders_screen.dart';
import '../marketplace/farmer_orders_screen.dart';
import '../../widgets/common/app_logo_widget.dart';
import '../../widgets/common/profile_picture_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentNavIndex = 0;

  List<DashboardItem> _getFarmerDashboardItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DashboardItem(
        title: l10n.marketplace,
        subtitle: l10n.sellYourProducts,
        icon: Icons.store,
        color: const Color(0xFF4A7C59),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF4A7C59)],
        route: AppRoutes.marketplace,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.orderManagement,
        subtitle: l10n.manageIncomingOrders,
        icon: Icons.shopping_cart,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.farmerOrders,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.dailyUpdates,
        subtitle: l10n.advancedDailyUpdates,
        icon: Icons.update,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.enhancedDaily,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.cropMonitor,
        subtitle: l10n.realtimeCropHealth,
        icon: Icons.eco_outlined,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.cropMonitor,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.weatherForecast,
        subtitle: l10n.tenDayPredictions,
        icon: Icons.cloud_outlined,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.weather,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.marketPrices,
        subtitle: l10n.liveCommodityRates,
        icon: Icons.trending_up_outlined,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.marketPrices,
        isBuyerFeature: true,
      ),
      DashboardItem(
        title: l10n.expertChat,
        subtitle: l10n.aiFarmingAssistant,
        icon: Icons.chat_bubble_outline,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.expertChat,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.farmEquipment,
        subtitle: l10n.smartToolManagement,
        icon: Icons.precision_manufacturing_outlined,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.farmEquipment,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.pestControl,
        subtitle: l10n.diseasePrevention,
        icon: Icons.pest_control_outlined,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF6B8E6B)],
        route: AppRoutes.pestControl,
        isBuyerFeature: false,
      ),
      DashboardItem(
        title: l10n.harvestPlanning,
        subtitle: l10n.optimizeYieldTiming,
        icon: Icons.schedule_outlined,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF6B8E6B)],
        route: AppRoutes.harvestPlanning,
        isBuyerFeature: false,
      ),
    ];
  }

  List<DashboardItem> _getBuyerDashboardItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DashboardItem(
        title: l10n.marketplace,
        subtitle: l10n.browseFreshProducts,
        icon: Icons.store,
        color: const Color(0xFF4A7C59),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF4A7C59)],
        route: AppRoutes.marketplace,
        isBuyerFeature: true,
      ),
      DashboardItem(
        title: l10n.myOrders,
        subtitle: l10n.trackYourPurchases,
        icon: Icons.shopping_cart,
        color: const Color(0xFF4A7C59),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF4A7C59)],
        route: AppRoutes.myOrders,
        isBuyerFeature: true,
      ),
      DashboardItem(
        title: l10n.favorites,
        subtitle: l10n.savedProducts,
        icon: Icons.favorite,
        color: const Color(0xFF4A7C59),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF4A7C59)],
        route: AppRoutes.favorites,
        isBuyerFeature: true,
      ),
      DashboardItem(
        title: l10n.marketPrices,
        subtitle: l10n.liveCommodityRates,
        icon: Icons.trending_up_outlined,
        color: const Color(0xFF4A7C59),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF4A7C59)],
        route: AppRoutes.marketPrices,
        isBuyerFeature: true,
      ),
      DashboardItem(
        title: l10n.searchFarmers,
        subtitle: l10n.connectDirectlyWithProducers,
        icon: Icons.search,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.searchFarmers,
        isBuyerFeature: true,
      ),
      DashboardItem(
        title: l10n.deliveryTracking,
        subtitle: l10n.trackYourShipments,
        icon: Icons.local_shipping,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFFA8D5A8), const Color(0xFF6B8E6B)],
        route: AppRoutes.deliveryTracking,
        isBuyerFeature: true,
      ),
      DashboardItem(
        title: l10n.support,
        subtitle: l10n.getHelpAssistance,
        icon: Icons.support_agent,
        color: const Color(0xFF6B8E6B),
        gradient: [const Color(0xFF8FBC8F), const Color(0xFF6B8E6B)],
        route: AppRoutes.support,
        isBuyerFeature: true,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  void _initializeDashboard() {
    final stopwatch = Stopwatch()..start();

    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );

      _slideAnimation =
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutBack,
            ),
          );

      _animationController.forward();

      stopwatch.stop();
      logger.logDashboardAction(
        'Dashboard initialized successfully',
        additionalData: {
          'initializationTime': stopwatch.elapsed.inMilliseconds,
        },
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      logger.error(
        'Failed to initialize dashboard',
        category: LogCategory.dashboard,
        screenName: 'MainDashboard',
        action: 'initialize',
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'initializationTime': stopwatch.elapsed.inMilliseconds,
        },
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    logger.logDashboardAction('Dashboard disposed');
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    // Get auth provider to check user type
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isBuyer = authProvider.isBuyer;

    // Handle navigation based on user type and index
    if (isBuyer) {
      // Buyer-specific navigation
      switch (index) {
        case 0:
          // Navigate to dashboard (Home)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (route) => false,
          );
          break;
        case 1:
          Navigator.pushNamed(context, AppRoutes.marketplace);
          break;
        case 2:
          Navigator.pushNamed(context, AppRoutes.myOrders);
          break;
        case 3:
          Navigator.pushNamed(context, AppRoutes.favorites);
          break;
        case 4:
          Navigator.pushNamed(context, AppRoutes.profile);
          break;
      }
    } else {
      // Farmer/default navigation
      switch (index) {
        case 0:
          // Navigate to dashboard (Home)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.dashboard,
            (route) => false,
          );
          break;
        case 1:
          Navigator.pushNamed(context, AppRoutes.allFarms);
          break;
        case 2:
          Navigator.pushNamed(context, AppRoutes.firestoreDataViewer);
          break;
        case 3:
          Navigator.pushNamed(context, AppRoutes.adminTest);
          break;
        case 4:
          Navigator.pushNamed(context, AppRoutes.profile);
          break;
      }
    }
  }

  void _onDashboardItemTap(DashboardItem item) {
    if (item.route != null) {
      // Handle custom routes
      if (item.route == AppRoutes.myOrders) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
        );
      } else if (item.route == AppRoutes.farmerOrders) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FarmerOrdersScreen()),
        );
      } else if (item.route == AppRoutes.myProducts) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('My Products')),
              body: const Center(
                child: Text('Product management screen coming soon...'),
              ),
            ),
          ),
        );
      } else {
        Navigator.pushNamed(context, item.route!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isFarmer = authProvider.isFarmer;
        final isBuyer = authProvider.isBuyer;

        // Determine which dashboard items to show
        List<DashboardItem> currentItems;
        String dashboardTitle;
        String welcomeMessage;
        String subtitle;

        final l10n = AppLocalizations.of(context)!;

        // Get user's first name for personalized greeting
        final userName =
            authProvider.userModel?.fullName.split(' ').first ?? 'User';

        if (isFarmer) {
          currentItems = _getFarmerDashboardItems(context);
          dashboardTitle = l10n.farmManagement;
          welcomeMessage = 'Good Morning, $userName! 🌱';
          subtitle = l10n.manageFarmOperations;
        } else if (isBuyer) {
          currentItems = _getBuyerDashboardItems(context);
          dashboardTitle = l10n.buyerMarketplace;
          welcomeMessage = 'Welcome, $userName! 🛒';
          subtitle = l10n.browseFreshProducts;
        } else {
          // Default to farmer dashboard for other user types
          currentItems = _getFarmerDashboardItems(context);
          dashboardTitle = l10n.dashboard;
          welcomeMessage = 'Welcome, $userName! 👋';
          subtitle = l10n.manageOperations;
        }

        return WillPopScope(
          onWillPop: () async {
            // Show confirmation dialog when back button is pressed
            final shouldPop = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Are you sure you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            );
            return shouldPop ?? false;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          const Color(0xFF2D5A3D),
                          const Color(0xFF4A7C59),
                          const Color(0xFF6B8E6B),
                          const Color(0xFF8FBC8F),
                        ]
                      : [
                          const Color(0xFF2D5A3D),
                          const Color(0xFF4A7C59),
                          const Color(0xFF6B8E6B),
                          const Color(0xFF8FBC8F),
                        ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Flexible(
                      flex: 0,
                      child: _buildModernHeader(
                        welcomeMessage,
                        subtitle,
                        dashboardTitle,
                      ),
                    ),
                    _buildWeatherCard(isFarmer),
                    Expanded(child: _buildDashboardGrid(currentItems)),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: isBuyer
                ? BuyerBottomNavigationBar(
                    currentIndex: _currentNavIndex,
                    onTap: _onNavTap,
                  )
                : CustomBottomNavigationBar(
                    currentIndex: _currentNavIndex,
                    onTap: _onNavTap,
                  ),
            floatingActionButton: Consumer<NotificationProvider>(
              builder: (context, notificationProvider, child) {
                return Stack(
                  children: [
                    FloatingActionButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.enhancedNotifications,
                        );
                      },
                      backgroundColor: const Color.fromARGB(255, 112, 173, 130),
                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                    ),
                    // Notification Badge on FAB
                    if (notificationProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                          child: Text(
                            notificationProvider.unreadCount > 99
                                ? '99+'
                                : notificationProvider.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(
    String welcomeMessage,
    String subtitle,
    String dashboardTitle,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // App Logo - smaller on mobile
                    AppLogoCompact(
                      size: ResponsiveHelper.isSmallScreen(context) ? 32 : 40,
                      color: Colors.white,
                      showText: !ResponsiveHelper.isSmallScreen(context),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.isSmallScreen(context) ? 8 : 12,
                    ),
                    // Welcome text - more flexible layout
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            welcomeMessage,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.isSmallScreen(context)
                                  ? 16
                                  : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.isSmallScreen(context)
                                  ? 10
                                  : 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Profile Picture - smaller on mobile
                    DashboardProfilePicture(
                      imageUrl: Provider.of<AuthProvider>(
                        context,
                      ).userModel?.profileImageUrl,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                      size: ResponsiveHelper.isSmallScreen(context) ? 35 : 45,
                    ),
                    SizedBox(
                      width: ResponsiveHelper.isSmallScreen(context) ? 4 : 8,
                    ),
                    // Notification Icon with Badge - more compact
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, child) {
                        return Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                ResponsiveHelper.isSmallScreen(context) ? 6 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.enhancedNotifications,
                                  );
                                },
                                icon: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: ResponsiveHelper.isSmallScreen(context)
                                      ? 16
                                      : 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ),
                            // Notification Badge
                            if (notificationProvider.unreadCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    notificationProvider.unreadCount > 99
                                        ? '99+'
                                        : notificationProvider.unreadCount
                                              .toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          ResponsiveHelper.isSmallScreen(
                                            context,
                                          )
                                          ? 8
                                          : 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    // Agriculture Icon - only show on larger screens to save space
                    if (!ResponsiveHelper.isSmallScreen(context)) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.agriculture,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                dashboardTitle,
                style: TextStyle(
                  fontSize: ResponsiveHelper.isSmallScreen(context) ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(bool isFarmer) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isFarmer ? Icons.wb_sunny : Icons.store,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFarmer
                        ? AppLocalizations.of(context)!.weatherUpdate
                        : AppLocalizations.of(context)!.marketStatus,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFarmer
                        ? AppLocalizations.of(context)!.sunnyPerfectFarming
                        : AppLocalizations.of(context)!.activeMarketplace,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(List<DashboardItem> items) {
    return SlideTransition(
      position: _slideAnimation,
      child: GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isSmallScreen(context) ? 12 : 16,
          vertical: 8,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
          crossAxisSpacing: ResponsiveHelper.isSmallScreen(context)
              ? 8.0
              : 12.0,
          mainAxisSpacing: ResponsiveHelper.isSmallScreen(context) ? 8.0 : 12.0,
          childAspectRatio: ResponsiveHelper.getResponsiveCardAspectRatio(
            context,
          ),
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildDashboardCard(item);
        },
      ),
    );
  }

  Widget _buildDashboardCard(DashboardItem item) {
    return GestureDetector(
      onTap: () => _onDashboardItemTap(item),
      child: Container(
        height: ResponsiveHelper.getResponsiveCardHeight(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveHelper.isSmallScreen(context) ? 10.0 : 12.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isSmallScreen(context) ? 6.0 : 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: ResponsiveHelper.isSmallScreen(context) ? 18.0 : 22.0,
                ),
              ),
              SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 6 : 8),
              Flexible(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.isSmallScreen(context)
                        ? 11.0
                        : 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: ResponsiveHelper.isSmallScreen(context) ? 2 : 4),
              Flexible(
                child: Text(
                  item.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: ResponsiveHelper.isSmallScreen(context)
                        ? 9.0
                        : 10.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final String? route;
  final bool isBuyerFeature;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
    this.route,
    required this.isBuyerFeature,
  });
}
