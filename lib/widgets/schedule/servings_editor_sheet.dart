import 'package:flutter/material.dart';

import '../../l10n/app_locale.dart';
import '../common/primary_button.dart';
import '../common/servings_stepper.dart';

/// Opens a small bottom sheet for adjusting a scheduled dinner's planned
/// serving count, starting at [current]. Calls [onSave] with the new value if
/// the user confirms, or does nothing if they dismiss it unchanged.
Future<void> showServingsEditorSheet(BuildContext context, {required int current, required ValueChanged<int> onSave}) async {
  final result = await showModalBottomSheet<int>(
    context: context,
    builder: (context) => _ServingsEditorSheet(initialServings: current),
  );
  if (result != null) onSave(result);
}

class _ServingsEditorSheet extends StatefulWidget {
  const _ServingsEditorSheet({required this.initialServings});

  final int initialServings;

  @override
  State<_ServingsEditorSheet> createState() => _ServingsEditorSheetState();
}

class _ServingsEditorSheetState extends State<_ServingsEditorSheet> {
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.initialServings;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServingsStepper(servings: _servings, onChanged: (value) => setState(() => _servings = value)),
            const SizedBox(height: 16),
            PrimaryButton(
              key: const Key('servings-editor-save'),
              label: tr(context, 'common.save'),
              onPressed: () => Navigator.of(context).pop(_servings),
            ),
          ],
        ),
      ),
    );
  }
}
