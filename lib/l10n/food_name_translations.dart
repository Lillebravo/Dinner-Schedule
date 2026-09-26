import 'package:flutter/widgets.dart';

import 'app_locale.dart';

/// Translated display names for the app's curated/default food entries, keyed
/// by language then the food's canonical (English) name. Only entries that
/// differ from the original need listing - anything else (including any
/// custom food the user typed in) falls through to [name] unchanged, so
/// user-entered text is never mangled.
const Map<String, Map<String, String>> kFoodNameTranslations = {
  'sv': {
    'Burgers': 'Hamburgare',
    'Thai': 'Thailändskt',
    'Italian': 'Italienskt',
    'Chinese': 'Kinesiskt',
    'Indian': 'Indiskt',
    'Korean': 'Koreanskt',
    'Salad': 'Sallad',
    'Sandwich': 'Smörgås',
  },
};

/// Looks up [name]'s translated display name for the current language, or
/// returns [name] unchanged if there's no translation for it.
String translateFoodName(BuildContext context, String name) {
  final code = AppLocale.of(context).languageCode;
  return kFoodNameTranslations[code]?[name] ?? name;
}
