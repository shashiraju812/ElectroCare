// widgets/cached_product_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Professional product image widget with caching and shimmer loading effect
class CachedProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onRetry;

  const CachedProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.onRetry,
  });

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildShimmer(),
        errorWidget: (context, url, error) => Container(
          width: width ?? double.infinity,
          height: height ?? 200,
          decoration: BoxDecoration(
            color: backgroundColor ?? const Color(0xFFF0F4FF),
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.electrical_services,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              if (onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry', style: TextStyle(color: Colors.blue)),
                )
              else
                const Text(
                  'Image not available',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
            ],
          ),
        ),
      ),
    );
  }
}
