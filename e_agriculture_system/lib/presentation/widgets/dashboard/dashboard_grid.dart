import 'package:e_agriculture_system/core/utills/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'dashboard_card.dart';

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'title': 'Rice', 'icon': Icons.rice_bowl, 'route': '/rice'},
      {'title': 'Tools', 'icon': Icons.build, 'route': '/tools'},
      {
        'title': 'Fertilizer',
        'icon': Icons.local_florist,
        'route': '/fertilizer',
      },
      {'title': 'Tips', 'icon': Icons.lightbulb, 'route': '/daily'},
      {'title': 'Chat', 'icon': Icons.chat, 'route': '/chat'},
    ];

    return GridView.builder(
      padding: ResponsiveHelper.getResponsivePadding(context),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
        mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 0.02),
        crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(context, 0.02),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return DashboardCard(
          title: item['title'],
          icon: item['icon'],
          onTap: () => Navigator.pushNamed(context, item['route']),
        );
      },
    );
  }
}
