
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
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
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