import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'wheel_math.dart';

/// Paints the wheel's colored slices, center hub, and per-slice labels.
///
/// [rotation] (degrees) spins the slices around the center. Each label is
/// oriented radially (pointing outward along its own slice, like a spoke) so
/// long names keep fitting as more slices are added - the radial run length
/// stays constant regardless of slice count, unlike the tangential width.
/// Labels in the lower half are flipped 180° so they never read upside-down.
class WheelPainter extends CustomPainter {
  const WheelPainter({required this.foods, this.rotation = 0});

  final List<String> foods;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final segment = WheelMath.segmentAngle(foods.length);
    final rotationRadians = rotation * math.pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationRadians);
    canvas.translate(-center.dx, -center.dy);

    for (var i = 0; i < foods.length; i++) {
      final startAngle = (-90 + i * segment) * math.pi / 180;
      final sweepAngle = segment * math.pi / 180;
      canvas.drawArc(rect, startAngle, sweepAngle, true, Paint()..color = _colorForSlice(i));
    }

    canvas.drawCircle(center, radius * 0.14, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius * 0.12, Paint()..color = const Color(0xFF1F2A24));
    canvas.restore();

    for (var i = 0; i < foods.length; i++) {
      _paintLabel(canvas, size, center, rotationRadians, i);
    }
  }

  Color _colorForSlice(int index) {
    final hue = WheelMath.sliceHue(index, foods.length);
    return HSLColor.fromAHSL(1, hue, 0.62, 0.5).toColor();
  }

  void _paintLabel(Canvas canvas, Size size, Offset center, double rotationRadians, int index) {
    final anchor = WheelMath.labelAnchor(index, foods.length);
    final dx = (anchor.x - 0.5) * size.width;
    final dy = (anchor.y - 0.5) * size.height;
    final cosR = math.cos(rotationRadians);
    final sinR = math.sin(rotationRadians);
    final position = center + Offset(dx * cosR - dy * sinR, dx * sinR + dy * cosR);

    var textRotation = (WheelMath.sliceCenterAngle(index, foods.length) - 90) * math.pi / 180 + rotationRadians;
    if (WheelMath.shouldFlipLabel(textRotation)) {
      textRotation += math.pi;
    }

    final maxWidth = math.max(size.width * 0.36, 60.0);
    final fontSize = WheelMath.labelFontSize(size.width, foods.length);

    final painter = TextPainter(
      text: TextSpan(
        text: foods[index],
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1))],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(textRotation);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) =>
      oldDelegate.rotation != rotation || !listEquals(oldDelegate.foods, foods);
}

/// Small downward-pointing triangle fixed above the wheel.
class PointerPainter extends CustomPainter {
  const PointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF1F2A24));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
