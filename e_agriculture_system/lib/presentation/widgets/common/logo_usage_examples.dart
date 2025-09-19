import 'package:flutter/material.dart';
import 'app_logo_widget.dart';

/// Examples of how to use the AppLogoWidget in different scenarios
class LogoUsageExamples extends StatelessWidget {
  const LogoUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo Usage Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Full Logo with Text and Subtitle
            const Text(
              '1. Full Logo (Splash/Welcome Screens)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Center(
              child: AppLogoWidget(
                size: 120,
                showText: true,
                showSubtitle: true,
                customTitle: 'AGRIGO',
                customSubtitle: 'Smart Agriculture Solutions',
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Example 2: Compact Logo (Headers)
            const Text(
              '2. Compact Logo (Headers/Navigation)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  AppLogoCompact(
                    size: 40,
                    showText: true,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Dashboard Header Example',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Example 3: Loading Logo
            const Text(
              '3. Loading Logo (Splash Screen)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Center(
              child: AppLogoLoading(
                size: 80,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Example 4: Icon Only
            const Text(
              '4. Icon Only (Small Spaces)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Center(
              child: AppLogoWidget(
                size: 60,
                showText: false,
                showSubtitle: false,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Example 5: Custom Colors
            const Text(
              '5. Custom Colors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Center(
              child: AppLogoWidget(
                size: 100,
                showText: true,
                showSubtitle: true,
                textColor: Colors.blue,
                iconColor: Colors.blue,
                customTitle: 'Custom Logo',
                customSubtitle: 'With Custom Colors',
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Example 6: Animated Logo
            const Text(
              '6. Animated Logo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Center(
              child: AppLogoWidget(
                size: 100,
                showText: true,
                showSubtitle: true,
                isAnimated: true,
                animationDuration: Duration(milliseconds: 2000),
                customTitle: 'Animated',
                customSubtitle: 'Logo Example',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
