import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class EventCoverImagePicker extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onImagePicked;
  final VoidCallback onImageRemoved;

  const EventCoverImagePicker({
    super.key,
    required this.imageUrl,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: imageUrl == null ? onImagePicked : null,
      child: Container(
        height: 180,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: const Color(0xFF3B4FEB),
            strokeWidth: 1.5,
            gap: 5,
            dashLength: 7,
            borderRadius: 12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(imageUrl!, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: onImageRemoved,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: Color(0xFF3B4FEB),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '+ Add cover image',
                        style: TextStyle(
                          color: Color(0xFF3B4FEB),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Recommended 1600 x 900',
                        style: TextStyle(
                          color: Color(0xFF717F8C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
    this.dashLength = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final ui.Path path = ui.Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final ui.Path dashedPath = ui.Path();
    double distance = 0.0;
    for (final ui.PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
