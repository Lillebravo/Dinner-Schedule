import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import 'primary_button.dart';

/// Text field + submit button for adding a new named entry (a food, a meal, ...).
class EntryInputRow extends StatelessWidget {
  const EntryInputRow({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.hintText = 'Add an entry',
    this.maxLength = 40,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String hintText;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: const Key('food-input'),
            controller: controller,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hintText,
              counterText: '',
              isDense: true,
              border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        const SizedBox(width: 8),
        PrimaryButton(
          key: const Key('add-food-button'),
          label: tr(context, 'common.add'),
          onPressed: onSubmit,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ],
    );
  }
}
