import 'package:flutter/widgets.dart';

import 'locale_controller.dart';

/// Makes the app's [LocaleController] available to any descendant without
/// threading it through every widget's constructor - any widget can call
/// [AppLocale.of] (or the [tr] shorthand) and rebuilds automatically when the
/// language changes.
class AppLocale extends InheritedNotifier<LocaleController> {
  const AppLocale({super.key, required LocaleController controller, required super.child}) : super(notifier: controller);

  static LocaleController of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppLocale>()!.notifier!;
}

/// Shorthand for `AppLocale.of(context).t(key)`.
String tr(BuildContext context, String key, [Map<String, String>? params]) => AppLocale.of(context).t(key, params);
