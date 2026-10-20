import 'package:flutter/material.dart';

class CommonLoading extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final double? height;
  final String? message;

  const CommonLoading({
    super.key,
    this.size = 36,
    this.strokeWidth = 3,
    this.color = const Color(0xffF28C00),
    this.height,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ],
    );

    if (height != null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

class CommonEmpty extends StatelessWidget {
  final double? height;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const CommonEmpty({
    super.key,
    this.height = 240,
    this.title = 'No products found',
    this.message = 'There are no products to show right now.',
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(retryLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF28C00),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ],
    );

    if (height != null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

class CommonError extends StatelessWidget {
  final double? height;
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final bool isRetryEnabled;
  final IconData icon;
  final double iconSize;

  const CommonError({
    super.key,
    this.height = 240,
    this.title = 'Failed to load',
    this.message = 'Please check your connection and try again.',
    this.retryLabel = 'Retry',
    this.onRetry,
    this.isRetryEnabled = true,
    this.icon = Icons.cloud_off_outlined,
    this.iconSize = 45,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: Colors.grey),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: isRetryEnabled ? onRetry : null,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(retryLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffF28C00),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ],
    );

    if (height != null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
