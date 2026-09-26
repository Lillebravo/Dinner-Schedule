import 'package:flutter/foundation.dart';

import 'translations.dart';

/// A supported UI language: its code (used to look up translations) and its
/// own display name (shown in its own language, e.g. "Svenska" not "Swedish").
class AppLanguage {
  const AppLanguage(this.code, this.label);

  final String code;
  final String label;
}

/// Owns the app's current UI language and looks up translated strings.
class LocaleController extends ChangeNotifier {
  static const supported = [
    AppLanguage('en', 'English'),
    AppLanguage('sv', 'Svenska'),
  ];

  String _languageCode = 'en';
  String get languageCode => _languageCode;

  void setLanguage(String code) {
    if (code == _languageCode || !kTranslations.containsKey(code)) return;
    _languageCode = code;
    notifyListeners();
  }

  /// Switches to the next supported language, wrapping around.
  void cycleLanguage() {
    final index = supported.indexWhere((lang) => lang.code == _languageCode);
    setLanguage(supported[(index + 1) % supported.length].code);
  }

  /// Looks up [key]'s translation for the current language (falling back to
  /// English, then to the key itself). [params] fills in `{placeholder}`
  /// tokens in the translated string.
  String t(String key, [Map<String, String>? params]) {
    var value = kTranslations[_languageCode]?[key] ?? kTranslations['en']?[key] ?? key;
    params?.forEach((name, replacement) => value = value.replaceAll('{$name}', replacement));
    return value;
  }
}
