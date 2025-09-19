import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/theme_provider.dart';

class ThemeToggle extends StatelessWidget {
  final bool showLabel;
  final bool showIcon;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;

  const ThemeToggle({
    super.key,
    this.showLabel = true,
    this.showIcon = true,
    this.size,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: isDarkMode 
                    ? (activeColor ?? Colors.amber)
                    : (inactiveColor ?? Theme.of(context).colorScheme.onSurfaceVariant),
                size: size ?? 24,
              ),
              if (showLabel) const SizedBox(width: 8),
            ],
            if (showLabel) ...[
              Text(
                isDarkMode ? 'Light' : 'Dark',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Switch(
              value: isDarkMode,
              onChanged: (value) {
                if (value) {
                  themeProvider.setDarkTheme();
                } else {
                  themeProvider.setLightTheme();
                }
              },
              activeColor: activeColor ?? Theme.of(context).primaryColor,
              inactiveThumbColor: inactiveColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        );
      },
    );
  }
}
