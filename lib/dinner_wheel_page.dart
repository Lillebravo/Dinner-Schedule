import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'wheel_math.dart';
import 'wheel_painter.dart';

const _ink = Color(0xFF1F2A24);
const _muted = Color(0xFF657068);
const _coral = Color(0xFFE95032);
const _coralDark = Color(0xFFB93822);
const _line = Color(0xFFCBD4CA);

class DinnerWheelPage extends StatefulWidget {
  const DinnerWheelPage({super.key});

  @override
  State<DinnerWheelPage> createState() => _DinnerWheelPageState();
}

class _DinnerWheelPageState extends State<DinnerWheelPage> with SingleTickerProviderStateMixin {
  final List<String> _foods = ['Tacos', 'Pasta', 'Curry', 'Stir-fry'];
  final _foodController = TextEditingController();

  late final AnimationController _controller;
  Animation<double> _rotationAnimation = const AlwaysStoppedAnimation(0);
  double _currentRotation = 0;
  bool _spinning = false;
  String? _selectedFood;
  String? _fieldError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
  }

  @override
  void dispose() {
    _controller.dispose();
    _foodController.dispose();
    super.dispose();
  }

  void _addFood() {
    final value = _foodController.text.trim();
    final duplicate = _foods.any((food) => food.toLowerCase() == value.toLowerCase());

    setState(() {
      if (value.isEmpty || value.length > 40) {
        _fieldError = 'Enter a food name up to 40 characters.';
        return;
      }
      if (duplicate) {
        _fieldError = 'That food is already on the wheel.';
        return;
      }
      _fieldError = null;
      _foods.add(value);
      _foodController.clear();
      _selectedFood = null;
    });
  }

  void _removeFood(String food) {
    if (_spinning || _foods.length <= 2) return;
    setState(() {
      _foods.remove(food);
      if (_selectedFood == food) _selectedFood = null;
    });
  }

  void _spin() {
    if (_spinning || _foods.length < 2) return;

    final selectedIndex = math.Random().nextInt(_foods.length);
    final target = WheelMath.targetRotation(
      selectedIndex: selectedIndex,
      foodCount: _foods.length,
      currentRotation: _currentRotation,
    );

    setState(() {
      _spinning = true;
      _selectedFood = null;
      _rotationAnimation = Tween<double>(begin: _currentRotation, end: target)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    });

    _controller
      ..reset()
      ..forward().whenComplete(() {
        if (!mounted) return;
        setState(() {
          _currentRotation = target % 360;
          _spinning = false;
          _selectedFood = _foods[selectedIndex];
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 840;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildIntro(),
                    const SizedBox(height: 40),
                    isNarrow
                        ? Column(
                            children: [
                              _buildWheelStage(),
                              const SizedBox(height: 40),
                              _buildFoodPanel(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(flex: 13, child: _buildWheelStage()),
                              const SizedBox(width: 48),
                              Expanded(flex: 7, child: _buildFoodPanel()),
                            ],
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 17, backgroundColor: _coral, child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
            const SizedBox(width: 10),
            const Text('DishDash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ink)),
          ],
        ),
        const Text('DINNER DECISION MAKER', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TONIGHT'S MENU", style: TextStyle(color: _coralDark, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        const Text(
          "Let the wheel pick dinner.",
          style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: _ink, height: 1.0),
        ),
        const SizedBox(height: 14),
        const Text(
          'Add the food you are craving, give it a spin, and leave the debate to chance.',
          style: TextStyle(color: _muted, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildWheelStage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wheelSize = constraints.maxWidth.clamp(220.0, 420.0);
        return Column(
          children: [
            SizedBox(
              width: wheelSize,
              height: wheelSize + 22,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 22,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) => Container(
                        width: wheelSize,
                        height: wheelSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 10),
                          boxShadow: const [BoxShadow(color: Color(0x33273B2C), blurRadius: 70, offset: Offset(0, 24))],
                        ),
                        child: CustomPaint(painter: WheelPainter(foods: _foods, rotation: _rotationAnimation.value)),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 0,
                    child: SizedBox(width: 28, height: 22, child: CustomPaint(painter: PointerPainter())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              key: const Key('spin-button'),
              onPressed: _spinning ? null : _spin,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _ink.withValues(alpha: 0.55),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(_spinning ? 'Spinning...' : 'Spin the wheel'),
            ),
            const SizedBox(height: 20),
            Semantics(
              liveRegion: true,
              child: _selectedFood != null
                  ? Column(
                      children: [
                        const Text('Dinner is decided', style: TextStyle(color: _muted)),
                        const SizedBox(height: 4),
                        Text(_selectedFood!, key: const Key('result-text'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _ink)),
                      ],
                    )
                  : const Text('Your pick will appear here', key: Key('result-placeholder'), style: TextStyle(color: _muted)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoodPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHEEL ENTRIES', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  SizedBox(height: 6),
                  Text("What's on the table?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _line)),
              child: Text('${_foods.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('food-input'),
                controller: _foodController,
                maxLength: 40,
                decoration: const InputDecoration(
                  hintText: 'Try homemade pizza',
                  counterText: '',
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                ),
                onSubmitted: (_) => _addFood(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              key: const Key('add-food-button'),
              onPressed: _addFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        if (_fieldError != null) ...[
          const SizedBox(height: 6),
          Text(_fieldError!, key: const Key('field-error'), style: const TextStyle(color: Color(0xFFA43A24), fontSize: 12)),
        ],
        const SizedBox(height: 12),
        for (final food in _foods)
          Container(
            key: ValueKey('food-item-$food'),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _line))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(food, style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: _muted,
                  tooltip: 'Remove $food',
                  onPressed: (_spinning || _foods.length <= 2) ? null : () => _removeFood(food),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Text('Keep at least two choices on the wheel.', style: TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }
}
