import 'package:flutter_test/flutter_test.dart';

import 'package:dishdash/utils/wheel_math.dart';

void main() {
  group('WheelMath', () {
    test('segmentAngle divides the circle evenly', () {
      expect(WheelMath.segmentAngle(4), 90);
      expect(WheelMath.segmentAngle(10), 36);
    });

    test('sliceCenterAngle returns the midpoint of each slice', () {
      expect(WheelMath.sliceCenterAngle(0, 4), 45);
      expect(WheelMath.sliceCenterAngle(1, 4), 135);
      expect(WheelMath.sliceCenterAngle(3, 4), 315);
    });

    test('targetRotation lands every slice exactly under the top pointer', () {
      const foodCount = 7;
      for (var index = 0; index < foodCount; index++) {
        final rotation = WheelMath.targetRotation(
          selectedIndex: index,
          foodCount: foodCount,
          currentRotation: 130,
        );
        final finalCenter = (WheelMath.sliceCenterAngle(index, foodCount) + rotation) % 360;
        expect(finalCenter, closeTo(0, 1e-9));
      }
    });

    test('targetRotation always spins forward from the current rotation', () {
      final rotation = WheelMath.targetRotation(selectedIndex: 2, foodCount: 6, currentRotation: 950);
      expect(rotation, greaterThan(950));
    });

    test('sliceHue separates every neighboring pair, including the wrap-around, evenly', () {
      for (final count in [2, 3, 4, 5, 6, 7, 11, 13]) {
        final hues = List.generate(count, (i) => WheelMath.sliceHue(i, count));
        for (var i = 0; i < count; i++) {
          final next = hues[(i + 1) % count];
          var diff = (next - hues[i]).abs();
          diff = diff > 180 ? 360 - diff : diff;
          expect(diff, closeTo(360 / count, 1e-9));
        }
      }
    });

    test('labelAnchor keeps every slice label away from the center hub', () {
      for (var i = 0; i < 8; i++) {
        final anchor = WheelMath.labelAnchor(i, 8);
        final distance = ((anchor.x - 0.5).abs() + (anchor.y - 0.5).abs());
        expect(distance, greaterThan(0.1));
      }
    });

    test('labelAnchor places the first slice toward the top-right quadrant', () {
      final anchor = WheelMath.labelAnchor(0, 4);
      expect(anchor.x, greaterThan(0.5));
      expect(anchor.y, lessThan(0.5));
    });

    test('labelFontSize shrinks as more slices compete for the same wheel', () {
      const diameter = 420.0;
      final fewSlices = WheelMath.labelFontSize(diameter, 4);
      final manySlices = WheelMath.labelFontSize(diameter, 50);
      final tonsOfSlices = WheelMath.labelFontSize(diameter, 80);

      expect(fewSlices, 16);
      expect(manySlices, lessThan(fewSlices));
      expect(tonsOfSlices, lessThan(manySlices));
      expect(tonsOfSlices, 8);
    });

    test('labelFontSize stays within its configured bounds', () {
      for (final count in [2, 5, 12, 30, 60, 100]) {
        final size = WheelMath.labelFontSize(420, count);
        expect(size, greaterThanOrEqualTo(8));
        expect(size, lessThanOrEqualTo(16));
      }
    });

    test('shouldFlipLabel keeps upper-half labels upright and flips lower-half ones', () {
      expect(WheelMath.shouldFlipLabel(0), isFalse);
      expect(WheelMath.shouldFlipLabel(1.0), isFalse);
      expect(WheelMath.shouldFlipLabel(-1.0), isFalse);
      expect(WheelMath.shouldFlipLabel(3.0), isTrue);
      expect(WheelMath.shouldFlipLabel(-3.0), isTrue);
      expect(WheelMath.shouldFlipLabel(4 * 3.141592653589793), isFalse);
    });
  });
}
