import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/wheel_math.dart';

/// Drives the wheel's spin animation and picks the winning entry.
class WheelSpinController extends ChangeNotifier {
  WheelSpinController({required TickerProvider vsync})
      : _controller = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 3200)) {
    _rotationAnimation = AlwaysStoppedAnimation(_currentRotation);
  }

  final AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0;
  bool _spinning = false;

  Animation<double> get rotationAnimation => _rotationAnimation;
  bool get spinning => _spinning;

  /// Spins to a random entry among [foodCount] choices, calling [onSettled] with the
  /// winning index once the animation completes.
  void spin(int foodCount, {required ValueChanged<int> onSettled}) {
    if (_spinning || foodCount < 2) return;

    final selected = math.Random().nextInt(foodCount);
    final target = WheelMath.targetRotation(
      selectedIndex: selected,
      foodCount: foodCount,
      currentRotation: _currentRotation,
    );

    _spinning = true;
    _rotationAnimation = Tween<double>(begin: _currentRotation, end: target)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    notifyListeners();

    _controller
      ..reset()
      ..forward().whenComplete(() {
        _currentRotation = target % 360;
        // Snap back to a plain stopped animation at the normalized angle so the
        // settled wheel renders from the same small rotation value as a fresh,
        // never-spun wheel, instead of holding onto the multi-turn raw `target`.
        _rotationAnimation = AlwaysStoppedAnimation(_currentRotation);
        _spinning = false;
        notifyListeners();
        onSettled(selected);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
