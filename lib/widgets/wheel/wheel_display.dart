import 'package:flutter/material.dart';

import 'wheel_painter.dart';

/// The circular wheel graphic plus its fixed top pointer, kept in sync with [rotation].
class WheelDisplay extends StatelessWidget {
  const WheelDisplay({super.key, required this.foods, required this.rotation, required this.size});

  final List<String> foods;
  final Animation<double> rotation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size + 22,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 22,
            child: AnimatedBuilder(
              animation: rotation,
              builder: (context, child) => Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 10),
                  boxShadow: const [BoxShadow(color: Color(0x33273B2C), blurRadius: 70, offset: Offset(0, 24))],
                ),
                child: CustomPaint(painter: WheelPainter(foods: foods, rotation: rotation.value)),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            child: SizedBox(width: 28, height: 22, child: CustomPaint(painter: PointerPainter())),
          ),
        ],
      ),
    );
  }
}
