import 'dart:math' as math;

/// Pure geometry helpers for the dinner wheel, kept free of Flutter widgets so they
/// can be unit tested directly. Angles are degrees, measured clockwise from the
/// top of the wheel (where the fixed pointer sits).
class WheelMath {
  const WheelMath._();

  static double segmentAngle(int foodCount) => 360 / foodCount;

  /// Angle of the midpoint of slice [index] out of [foodCount] slices.
  static double sliceCenterAngle(int index, int foodCount) {
    final segment = segmentAngle(foodCount);
    return index * segment + segment / 2;
  }

  /// Absolute rotation the wheel must reach so slice [selectedIndex]'s center lands
  /// under the top pointer, always spinning forward from [currentRotation].
  static double targetRotation({
    required int selectedIndex,
    required int foodCount,
    required double currentRotation,
    int extraSpins = 6,
  }) {
    final centerAngle = sliceCenterAngle(selectedIndex, foodCount);
    final targetMod = (360 - centerAngle) % 360;
    final currentMod = currentRotation % 360;
    final delta = (targetMod - currentMod + 360) % 360;
    return currentRotation + delta + extraSpins * 360;
  }

  /// Fractional (0..1) position of slice [index]'s label within the wheel's bounding box.
  static ({double x, double y}) labelAnchor(
    int index,
    int foodCount, {
    double radiusFraction = 0.32,
  }) {
    final angleFromPointer = sliceCenterAngle(index, foodCount) - 90;
    final radians = angleFromPointer * math.pi / 180;
    return (
      x: 0.5 + radiusFraction * math.cos(radians),
      y: 0.5 + radiusFraction * math.sin(radians),
    );
  }

  /// HSL hue (0-359) for slice [index], evenly spaced around the wheel so every
  /// pair of neighboring slices - including the wrap from the last to the first -
  /// is separated by the same 360/[foodCount] degrees of contrast.
  static double sliceHue(int index, int foodCount) => (index * 360 / foodCount) % 360;

  /// Font size (logical pixels) for a slice label that stays legible while avoiding
  /// overlap with its neighbors as [foodCount] grows. Bounded by the wheel's
  /// [diameter] and by the tangential space available at the label's anchor radius
  /// (0.64 of the wheel's radius, matching [labelAnchor]'s default) for a slice
  /// this thin - the more slices, the less tangential room each label gets.
  static double labelFontSize(
    double diameter,
    int foodCount, {
    double radiusFraction = 0.64,
    double minFontSize = 8,
    double maxFontSize = 16,
  }) {
    final anchorRadius = diameter / 2 * radiusFraction;
    final segmentRadians = segmentAngle(foodCount) * math.pi / 180;
    final tangentialSpace = 2 * anchorRadius * math.sin(segmentRadians / 2);
    final geometryLimit = tangentialSpace * 0.7;
    final diameterLimit = diameter * 0.045;
    return math.min(geometryLimit, diameterLimit).clamp(minFontSize, maxFontSize);
  }

  /// True if a label whose upright reading direction currently points at
  /// [angleRadians] (canvas convention: 0 = east/right, increasing clockwise)
  /// would read upside-down and should be rotated another 180° for readability.
  static bool shouldFlipLabel(double angleRadians) {
    final twoPi = 2 * math.pi;
    final normalized = ((angleRadians + math.pi) % twoPi + twoPi) % twoPi - math.pi;
    return normalized.abs() > math.pi / 2;
  }
}
