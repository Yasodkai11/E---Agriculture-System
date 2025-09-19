import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utills/responsive_helper.dart';

class BuyerBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BuyerBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isSmallScreen(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            isMobile
                ? 20
                : ResponsiveHelper.getResponsiveBorderRadius(context) * 2,
          ),
          topRight: Radius.circular(
            isMobile
                ? 20
                : ResponsiveHelper.getResponsiveBorderRadius(context) * 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.08),
            blurRadius: isMobile ? 15 : 20,
            offset: const Offset(0, -3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isMobile ? 8 : 12,
            offset: const Offset(0, -1),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          context: context,
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          index: 0,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.store_outlined,
          activeIcon: Icons.store,
          label: 'Market',
          index: 1,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: 'Orders',
          index: 2,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: 'Favorites',
          index: 3,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          index: 4,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          context: context,
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
          index: 0,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.store_outlined,
          activeIcon: Icons.store,
          label: 'Marketplace',
          index: 1,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: 'Orders',
          index: 2,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: 'Favorites',
          index: 3,
        ),
        _buildNavItem(
          context: context,
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: 'Yasod',
          index: 3,
        ),

        _buildNavItem(
          context: context,
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
          index: 4,
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    final isMobile = ResponsiveHelper.isSmallScreen(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: isActive
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.transparent,
            border: isActive
                ? Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryGreen.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade600,
                  size: 20.0,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
