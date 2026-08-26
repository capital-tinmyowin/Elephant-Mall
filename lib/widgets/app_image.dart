import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a local asset
    if (imageUrl.startsWith('assets/') || imageUrl.startsWith('images/')) {
      return _buildLocalImage();
    }

    // Check if it's a network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return _buildNetworkImage();
    }
     if (imageUrl.contains('.jpg') || 
        imageUrl.contains('.png') || 
        imageUrl.contains('.jpeg') ||
        imageUrl.contains('.gif') ||
        imageUrl.contains('.webp')) {
      return _buildLocalImage();
    }
    // Fallback: try as local asset
    return _buildLocalImage();
  }

  Widget _buildLocalImage() {
    String assetPath = imageUrl;
    
    // Ensure it has 'assets/' prefix if needed
    if (!assetPath.startsWith('assets/') && 
        !assetPath.startsWith('images/') &&
        assetPath.contains('.')) {
      // Try common asset paths
      return _tryMultipleAssetPaths();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: Image.asset(
        assetPath,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Try without 'assets/' prefix
          String cleanPath = assetPath.replaceFirst('assets/', '');
          return Image.asset(
            cleanPath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Try with 'assets/' prefix
              String withAssets = 'assets/$cleanPath';
              return Image.asset(
                withAssets,
                height: height,
                width: width,
                fit: fit ?? BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _tryMultipleAssetPaths() {
    String path = imageUrl;
    
    // Try to extract just the filename
    String fileName = path.split('/').last;
    List<String> possiblePaths = [
      'assets/images/$fileName',
      'assets/$fileName',
      'images/$fileName',
      fileName,
      'assets/$path',
      path,
    ];

    // Try each path until one works
    for (String testPath in possiblePaths) {
      try {
        // Check if asset exists (this is a simple check, might not work in all cases)
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          child: Image.asset(
            testPath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
          ),
        );
      } catch (e) {
        continue;
      }
    }

    // If all paths fail
    return _buildErrorWidget();
  }

  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) {
          // Try local asset as fallback
          if (imageUrl.contains('/images/') || imageUrl.contains('/assets/')) {
            String localPath = imageUrl.split('/').last;
            return Image.asset(
              localPath,
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorWidget();
              },
            );
          }
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
        );
  }
}