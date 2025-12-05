import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A reusable widget for displaying cached profile images with proper error handling
/// and loading states. Optimizes image loading and caching for better performance.
class CachedProfileImage extends StatelessWidget {
  /// The URL of the profile image to display
  final String? imageUrl;
  
  /// The size of the image (width and height)
  final double size;
  
  /// The icon to display when no image URL is provided or on error
  final IconData fallbackIcon;
  
  /// The size of the fallback icon
  final double? fallbackIconSize;
  
  /// The color of the fallback icon
  final Color? fallbackIconColor;
  
  /// The background color of the container
  final Color? backgroundColor;
  
  /// Whether to apply a circular shape
  final bool isCircular;
  
  /// Border radius when not circular
  final double? borderRadius;
  
  /// Optional semantic label for accessibility
  final String? semanticLabel;

  const CachedProfileImage({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.fallbackIcon = Icons.person,
    this.fallbackIconSize,
    this.fallbackIconColor,
    this.backgroundColor,
    this.isCircular = true,
    this.borderRadius,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFallbackIconSize = fallbackIconSize ?? size * 0.5;
    final effectiveFallbackIconColor = fallbackIconColor ?? Colors.black;
    final effectiveBackgroundColor = backgroundColor ?? Colors.white;

    Widget imageWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Placeholder while loading
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: effectiveBackgroundColor,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
        // Error widget when image fails to load
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: effectiveBackgroundColor,
          child: Icon(
            fallbackIcon,
            size: effectiveFallbackIconSize,
            color: effectiveFallbackIconColor,
          ),
        ),
        // Memory cache configuration for optimization
        memCacheWidth: (size * MediaQuery.of(context).devicePixelRatio).round(),
        memCacheHeight: (size * MediaQuery.of(context).devicePixelRatio).round(),
        // Max age for cached images (7 days)
        maxHeightDiskCache: (size * 3).round(),
        maxWidthDiskCache: (size * 3).round(),
      );
    } else {
      // No image URL provided, show fallback icon
      imageWidget = Container(
        width: size,
        height: size,
        color: effectiveBackgroundColor,
        child: Icon(
          fallbackIcon,
          size: effectiveFallbackIconSize,
          color: effectiveFallbackIconColor,
        ),
      );
    }

    // Apply shape (circular or rounded rectangle)
    Widget shapedWidget;
    if (isCircular) {
      shapedWidget = ClipOval(child: imageWidget);
    } else if (borderRadius != null) {
      shapedWidget = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: imageWidget,
      );
    } else {
      shapedWidget = imageWidget;
    }

    // Wrap with container for shadow and background
    final containerWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : (borderRadius != null ? BorderRadius.circular(borderRadius!) : null),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: shapedWidget,
    );

    // Add semantic label if provided
    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        image: true,
        child: containerWidget,
      );
    }

    return containerWidget;
  }
}
