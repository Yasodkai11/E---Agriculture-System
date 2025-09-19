import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final IconData fallbackIcon;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    this.size = 50.0,
    this.backgroundColor,
    this.iconColor,
    this.fallbackIcon = Icons.person,
    this.onTap,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = backgroundColor ?? 
        theme.colorScheme.surfaceContainerHighest;
    final defaultIconColor = iconColor ?? 
        theme.colorScheme.onSurfaceVariant;
    final defaultBorderColor = borderColor ?? 
        theme.colorScheme.outline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: defaultBackgroundColor,
          border: showBorder
              ? Border.all(
                  color: defaultBorderColor,
                  width: borderWidth,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackIcon(defaultIconColor);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
              : _buildFallbackIcon(defaultIconColor),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(Color iconColor) {
    return Center(
      child: Icon(
        fallbackIcon,
        size: size * 0.6,
        color: iconColor,
      ),
    );
  }
}

/// A specialized profile picture widget for dashboard header
class DashboardProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;
  final double size;

  const DashboardProfilePicture({
    super.key,
    this.imageUrl,
    this.onTap,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      imageUrl: imageUrl,
      size: size,
      backgroundColor: Colors.white.withOpacity(0.2),
      iconColor: Colors.white,
      fallbackIcon: Icons.person,
      onTap: onTap,
      showBorder: true,
      borderColor: Colors.white.withOpacity(0.3),
      borderWidth: 2.0,
    );
  }
}

/// A profile picture widget for profile screens
class ProfileScreenPicture extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback? onTap;
  final double size;
  final bool isEditing;

  const ProfileScreenPicture({
    super.key,
    this.imageUrl,
    this.onTap,
    this.size = 100.0,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        ProfilePictureWidget(
          imageUrl: imageUrl,
          size: size,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          iconColor: theme.colorScheme.onSurfaceVariant,
          fallbackIcon: Icons.person,
          onTap: onTap,
          showBorder: true,
          borderColor: theme.colorScheme.outline.withOpacity(0.3),
          borderWidth: 1.0,
        ),
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.cardColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.camera_alt,
                color: theme.primaryColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                size: size * 0.15,
              ),
            ),
          ),
      ],
    );
  }
}
