import 'package:flutter/material.dart';

import '../../controllers/food_list_controller.dart';
import '../common/primary_button.dart';

/// Text field + add button for entering a new wheel entry.
class FoodInputRow extends StatelessWidget {
  const FoodInputRow({super.key, required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: const Key('food-input'),
            controller: controller,
            maxLength: FoodListController.maxNameLength,
            decoration: const InputDecoration(
              hintText: 'Try homemade pizza',
              counterText: '',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        const SizedBox(width: 8),
        PrimaryButton(
          key: const Key('add-food-button'),
          label: 'Add',
          onPressed: onSubmit,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ],
    );
  }
}
