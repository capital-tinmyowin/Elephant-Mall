import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double? borderRadius;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    // For Pinterest images, force proxy
     bool isAlreadyProxied = imageUrl.contains('/image/proxy');
    
    // If it's a Pinterest image and NOT already proxied, add proxy
    String finalUrl = imageUrl;
    if (!isAlreadyProxied && 
        (imageUrl.contains('pinimg.com') || imageUrl.contains('pinterest'))) {
      // Don't encode again - the proxiedImageUrl already encoded it
      finalUrl = imageUrl;
    }


    if (finalUrl.startsWith('http://') || finalUrl.startsWith('https://')) {
      return _buildNetworkImage(finalUrl);
    }

    if (finalUrl.startsWith('assets/')) {
      return _buildLocalImage(finalUrl);
    }
    return _buildLocalImage('assets/$finalUrl');
  }

  Widget _buildLocalImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: Image.asset(
        path,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) {
          return _buildErrorWidget();
        },
        httpHeaders: {
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'Cache-Control': 'no-cache',
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
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: height != null && height! > 60 ? 30 : 20,
            color: Colors.grey[400],
          ),
          if (height != null && height! > 80)
            Text(
              'Image not found',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
        ],
      ),
    );
  }
}