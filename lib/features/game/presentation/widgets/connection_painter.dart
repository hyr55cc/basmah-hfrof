import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Paints the line connecting selected letters in the game
class ConnectionPainter extends CustomPainter {
  ConnectionPainter({
    required this.connectionPoints,
    required this.currentPointerPosition,
    required this.isDragging,
    required this.isValidSoFar,
  });

  final List<Offset> connectionPoints;
  final Offset? currentPointerPosition;
  final bool isDragging;
  final bool isValidSoFar;

  @override
  void paint(Canvas canvas, Size size) {
    if (connectionPoints.isEmpty) return;

    final points = <Offset>[...connectionPoints];
    if (isDragging && currentPointerPosition != null) {
      points.add(currentPointerPosition!);
    }

    // Draw glow / shadow
    final glowPaint = Paint()
      ..color = (isValidSoFar ? AppColors.primary : AppColors.error)
          .withOpacity(0.3)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    _drawPath(canvas, points, glowPaint);

    // Main line
    final linePaint = Paint()
      ..color = isValidSoFar ? AppColors.primary : AppColors.error
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    _drawPath(canvas, points, linePaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    _drawPath(canvas, points, highlightPaint);

    // Draw dots at each connection point
    for (final point in connectionPoints) {
      final dotOuter = Paint()
        ..color = isValidSoFar ? AppColors.primary : AppColors.error
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 8, dotOuter);

      final dotInner = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 4, dotInner);
    }

    // Draw active pointer dot
    if (isDragging &&
        currentPointerPosition != null &&
        points.isNotEmpty &&
        currentPointerPosition != points[points.length - 1]) {
      final pointerPaint = Paint()
        ..color = (isValidSoFar ? AppColors.primary : AppColors.error)
            .withOpacity(0.7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentPointerPosition!, 6, pointerPaint);
    }
  }

  void _drawPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      // Use quadratic bezier for smooth curves
      final prev = points[i - 1];
      final current = points[i];
      final mid = Offset(
        (prev.dx + current.dx) / 2,
        (prev.dy + current.dy) / 2,
      );
      if (i == 1) {
        path.lineTo(mid.dx, mid.dy);
      } else {
        path.quadraticBezierTo(
          prev.dx,
          prev.dy,
          mid.dx,
          mid.dy,
        );
      }
    }
    // Final segment to the last point
    final last = points.last;
    path.lineTo(last.dx, last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConnectionPainter oldDelegate) {
    return oldDelegate.connectionPoints != connectionPoints ||
        oldDelegate.currentPointerPosition != currentPointerPosition ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.isValidSoFar != isValidSoFar;
  }
}
