import 'package:flutter/material.dart';
import '../../../data/models/sri_lanka_market_price_model.dart';

class CommodityIconWidget extends StatelessWidget {
  final ProductCategory category;
  final String? customIcon;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const CommodityIconWidget({
    super.key,
    required this.category,
    this.customIcon,
    this.size = 24.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = customIcon != null ? _getCustomIcon(customIcon!) : _getCategoryIcon(category);
    final iconColor = color ?? _getCategoryColor(category);
    final bgColor = backgroundColor ?? _getCategoryBackgroundColor(category);

    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          iconData,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.grains:
        return Icons.grain;
      case ProductCategory.vegetables:
        return Icons.eco;
      case ProductCategory.fruits:
        return Icons.apple;
      case ProductCategory.spices:
        return Icons.local_fire_department;
      case ProductCategory.beverages:
        return Icons.local_drink;
      case ProductCategory.industrial:
        return Icons.factory;
      case ProductCategory.dairy:
        return Icons.water_drop;
      case ProductCategory.meat:
        return Icons.restaurant;
      case ProductCategory.fish:
        return Icons.set_meal;
      case ProductCategory.other:
        return Icons.category;
    }
  }

  IconData _getCustomIcon(String customIcon) {
    // Map custom icon strings to Material Icons
    switch (customIcon.toLowerCase()) {
      case 'rice':
        return Icons.grain;
      case 'coconut':
        return Icons.circle;
      case 'tea':
        return Icons.local_drink;
      case 'rubber':
        return Icons.circle_outlined;
      case 'cinnamon':
        return Icons.local_fire_department;
      case 'pepper':
        return Icons.local_fire_department;
      case 'cardamom':
        return Icons.local_fire_department;
      case 'banana':
        return Icons.apple;
      case 'pineapple':
        return Icons.apple;
      case 'chili':
        return Icons.local_fire_department;
      case 'onion':
        return Icons.eco;
      case 'potato':
        return Icons.eco;
      case 'tomato':
        return Icons.eco;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.grains:
        return Colors.amber[700]!;
      case ProductCategory.vegetables:
        return Colors.green[600]!;
      case ProductCategory.fruits:
        return Colors.orange[600]!;
      case ProductCategory.spices:
        return Colors.red[600]!;
      case ProductCategory.beverages:
        return Colors.brown[600]!;
      case ProductCategory.industrial:
        return Colors.blue[600]!;
      case ProductCategory.dairy:
        return Colors.blue[300]!;
      case ProductCategory.meat:
        return Colors.red[700]!;
      case ProductCategory.fish:
        return Colors.blue[500]!;
      case ProductCategory.other:
        return Colors.grey[600]!;
    }
  }

  Color _getCategoryBackgroundColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.grains:
        return Colors.amber[50]!;
      case ProductCategory.vegetables:
        return Colors.green[50]!;
      case ProductCategory.fruits:
        return Colors.orange[50]!;
      case ProductCategory.spices:
        return Colors.red[50]!;
      case ProductCategory.beverages:
        return Colors.brown[50]!;
      case ProductCategory.industrial:
        return Colors.blue[50]!;
      case ProductCategory.dairy:
        return Colors.blue[25]!;
      case ProductCategory.meat:
        return Colors.red[50]!;
      case ProductCategory.fish:
        return Colors.blue[50]!;
      case ProductCategory.other:
        return Colors.grey[50]!;
    }
  }
}

/// Widget for displaying commodity icon with trend indicator
class CommodityIconWithTrendWidget extends StatelessWidget {
  final ProductCategory category;
  final PriceTrend trend;
  final String? customIcon;
  final double size;
  final bool showTrend;

  const CommodityIconWithTrendWidget({
    super.key,
    required this.category,
    required this.trend,
    this.customIcon,
    this.size = 24.0,
    this.showTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CommodityIconWidget(
          category: category,
          customIcon: customIcon,
          size: size,
        ),
        if (showTrend)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getTrendColor(trend),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getTrendIcon(trend),
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getTrendIcon(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.up:
        return Icons.trending_up;
      case PriceTrend.down:
        return Icons.trending_down;
      case PriceTrend.stable:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.up:
        return Colors.green;
      case PriceTrend.down:
        return Colors.red;
      case PriceTrend.stable:
        return Colors.orange;
    }
  }
}




