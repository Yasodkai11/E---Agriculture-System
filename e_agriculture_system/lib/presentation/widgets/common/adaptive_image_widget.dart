import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Adaptive image widget that can display images from different storage types
class AdaptiveImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool showLoadingIndicator;

  const AdaptiveImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.showLoadingIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determine storage type and display appropriate image
    if (_isLocalPath(imagePath)) {
      return _buildLocalImage();
    } else if (_isCloudinaryUrl(imagePath)) {
      return _buildNetworkImage(imagePath);
    } else if (_isImageBBUrl(imagePath)) {
      return _buildNetworkImage(imagePath);
    } else if (_isBase64String(imagePath)) {
      return _buildBase64Image();
    } else if (_isNetworkUrl(imagePath)) {
      return _buildNetworkImage(imagePath);
    } else {
      return _buildErrorWidget();
    }
  }

  /// Check if path is a local file path
  bool _isLocalPath(String path) {
    return path.startsWith('/') || path.contains('images');
  }

  /// Check if URL is from Cloudinary
  bool _isCloudinaryUrl(String url) {
    return url.contains('cloudinary.com');
  }

  /// Check if URL is from ImageBB
  bool _isImageBBUrl(String url) {
    return url.contains('i.ibb.co') || url.contains('imgbb.com');
  }

  /// Check if string is base64 encoded
  bool _isBase64String(String data) {
    return data.length > 100 && !data.startsWith('http');
  }

  /// Check if string is a network URL
  bool _isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Build local image widget
  Widget _buildLocalImage() {
    // For web, local file paths are not supported
    if (kIsWeb) {
      return _buildErrorWidget();
    } else {
      // For mobile platforms, use Image.file
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.asset(
            imagePath, // Use Image.asset for local assets
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          ),
        ),
      );
    }
  }


  /// Build network image widget
  Widget _buildNetworkImage(String url) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) {
            return _buildPlaceholder();
          },
          errorWidget: (context, url, error) {
            return _buildErrorWidget();
          },
        ),
      ),
    );
  }

  /// Build base64 image widget
  Widget _buildBase64Image() {
    try {
      final bytes = base64Decode(imagePath);
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          ),
        ),
      );
    } catch (e) {
      return _buildErrorWidget();
    }
  }

  /// Build placeholder widget
  Widget _buildPlaceholder() {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: showLoadingIndicator
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : const SizedBox.shrink(),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}

/// Thumbnail version of adaptive image widget
class AdaptiveImageThumbnail extends StatelessWidget {
  final String imagePath;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AdaptiveImageThumbnail({
    super.key,
    required this.imagePath,
    this.size = 60,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveImageWidget(
      imagePath: imagePath,
      width: size,
      height: size,
      fit: fit,
      borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
      showLoadingIndicator: false,
    );
  }
}

/// Full-width adaptive image widget
class AdaptiveImageFullWidth extends StatelessWidget {
  final String imagePath;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AdaptiveImageFullWidth({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveImageWidget(
      imagePath: imagePath,
      width: double.infinity,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
    );
  }
}

/// Square adaptive image widget
class AdaptiveImageSquare extends StatelessWidget {
  final String imagePath;
  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AdaptiveImageSquare({
    super.key,
    required this.imagePath,
    this.size = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveImageWidget(
      imagePath: imagePath,
      width: size,
      height: size,
      fit: fit,
      borderRadius: borderRadius,
    );
  }
}

