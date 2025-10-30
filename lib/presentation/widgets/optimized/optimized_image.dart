import 'package:flutter/material.dart';

/// Memory-efficient image widget with caching and optimization
class OptimizedImage extends StatefulWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration cacheDuration;
  final BorderRadius? borderRadius;
  final Color? color;
  final BlendMode? colorBlendMode;
  
  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.cacheDuration = const Duration(days: 7),
    this.borderRadius,
    this.color,
    this.colorBlendMode,
  }) : assert(imageUrl != null || assetPath != null, 'Either imageUrl or assetPath must be provided');

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => widget.enableMemoryCache;

  Widget _buildImage() {
    Widget image;
    
    if (widget.assetPath != null) {
      image = Image.asset(
        widget.assetPath!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        cacheWidth: widget.width?.toInt(),
        cacheHeight: widget.height?.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? const Icon(Icons.error);
        },
      );
    } else {
      image = Image.network(
        widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        color: widget.color,
        colorBlendMode: widget.colorBlendMode,
        cacheWidth: widget.width?.toInt(),
        cacheHeight: widget.height?.toInt(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return widget.placeholder ?? 
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
        },
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? 
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Icon(Icons.error),
            );
        },
      );
    }
    
    if (widget.borderRadius != null) {
      image = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: image,
      );
    }
    
    return image;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildImage();
  }
}

/// Optimized avatar widget
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? child;
  
  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.child,
  });

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        child: child,
      );
    }
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor,
        foregroundImage: NetworkImage(imageUrl!),
        child: name != null 
          ? Text(
              _getInitials(name!),
              style: TextStyle(
                color: foregroundColor,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      );
    }
    
    if (name != null && name!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        child: Text(
          _getInitials(name!),
          style: TextStyle(
            color: foregroundColor ?? Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey,
      child: Icon(
        Icons.person,
        size: radius,
        color: foregroundColor ?? Colors.white,
      ),
    );
  }
}