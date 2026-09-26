/// Translation tables for the app's UI strings, keyed by language code then
/// translation key. Add a new language by adding another top-level map here
/// and registering it in [LocaleController.supported].
const Map<String, Map<String, String>> kTranslations = {
  'en': {
    'common.add': 'Add',

    'header.eyebrow': 'DINNER DECISION MAKER',
    'header.themeTooltipLight': 'Switch to dark mode',
    'header.themeTooltipDark': 'Switch to light mode',
    'header.languageTooltip': 'Change language',

    'nav.eatOut': 'Eat Out',
    'nav.meals': 'Meals',
    'nav.spin': 'Spin',
    'nav.shopping': 'Shopping',
    'nav.plan': 'Plan',

    'homeWheel.eyebrow': "TONIGHT'S MENU",
    'homeWheel.headline': 'Let the wheel pick dinner.',
    'homeWheel.subtitle': 'Spinning from the meals in your Meals list - add more there any time.',
    'homeWheel.emptyHintFiltered': 'Not enough meals match your filters. Adjust filters in the Meals tab.',
    'homeWheel.emptyHint': 'Add at least two meals in the Meals tab to spin.',

    'eatingOut.eyebrow': 'DINING OUT',
    'eatingOut.headline': 'Let the wheel pick what to eat.',
    'eatingOut.subtitle': 'Add the meals you are craving, give it a spin, and skip the back-and-forth.',
    'eatingOut.emptyHint': 'Add at least two meals to spin the wheel.',

    'foodPanel.eyebrow': 'MEALS TO CRAVE',
    'foodPanel.title': 'What are you craving?',
    'foodPanel.inputHint': 'Try Ramen',
    'foodPanel.keepAtLeastTwo': 'Keep at least two choices on the wheel.',

    'wheel.spin': 'Spin the wheel',
    'wheel.spinning': 'Spinning...',

    'result.decided': 'Dinner is decided',
    'result.placeholder': 'Your pick will appear here',

    'schedule.addButton': 'Add to schedule',
    'schedule.addTooltip': 'Add "{title}" to schedule',
    'schedule.added': 'Added {title} to the schedule.',
    'schedule.addMealButton': 'Add meal',
    'schedule.eatOutButton': 'Eat out',
    'schedule.clearDinner': 'Clear dinner',

    'homeMeals.eyebrow': 'HOME COOKING',
    'homeMeals.title': 'Your meals',
    'homeMeals.addHint': 'Add a home-cooked meal',
    'homeMeals.noMatch': 'No meals match your filters.',
    'homeMeals.footer':
        'Keep at least two meals on the list. Drag to reorder while sorted by "Custom order". Tap a meal to add ingredients and instructions.',

    'mealPlan.eyebrow': 'MEAL PLANNING',
    'mealPlan.headline': 'Plan your week of dinners.',
    'mealPlan.subtitle': 'Assign a home-cooked meal or a night out to any day, then drag to rearrange.',
    'mealPlan.weekly': 'Weekly',
    'mealPlan.monthly': 'Monthly',
    'mealPlan.thisWeek': 'This week',
    'mealPlan.thisMonth': 'This month',
    'mealPlan.weekLabel': 'Week {number}',
    'mealPlan.footer': 'Long-press a scheduled dinner and drag it onto another day to swap them.',

    'shopping.eyebrow': 'GROCERY LIST',
    'shopping.title': 'Shopping list',
    'shopping.subtitle': 'Automatically built from the home-cooked meals scheduled this week.',
    'shopping.empty': 'No home-cooked meals scheduled this week yet. Add one in Plan to build a shopping list.',
    'shopping.forMeals': 'For {meals}',

    'dayPicker.title': 'Add to schedule',
    'dayPicker.tonight': 'Tonight',
    'dayPicker.alreadyPlanned': 'Already planned',
    'dayPicker.pickDifferentDate': 'Pick a different date...',
  },
  'sv': {
    'common.add': 'Lägg till',

    'header.eyebrow': 'MIDDAGENS BESLUTSFATTARE',
    'header.themeTooltipLight': 'Byt till mörkt läge',
    'header.themeTooltipDark': 'Byt till ljust läge',
    'header.languageTooltip': 'Byt språk',

    'nav.eatOut': 'Ät ute',
    'nav.meals': 'Måltider',
    'nav.spin': 'Snurra',
    'nav.shopping': 'Inköp',
    'nav.plan': 'Planera',

    'homeWheel.eyebrow': 'KVÄLLENS MENY',
    'homeWheel.headline': 'Låt hjulet välja middag.',
    'homeWheel.subtitle': 'Snurrar bland måltiderna i din lista - lägg till fler när du vill.',
    'homeWheel.emptyHintFiltered': 'Inte tillräckligt många måltider matchar dina filter. Justera filtren under Måltider.',
    'homeWheel.emptyHint': 'Lägg till minst två måltider under Måltider för att snurra.',

    'eatingOut.eyebrow': 'ÄTA UTE',
    'eatingOut.headline': 'Låt hjulet välja vad du ska äta.',
    'eatingOut.subtitle': 'Lägg till maträtterna du är sugen på, snurra hjulet och slipp velandet.',
    'eatingOut.emptyHint': 'Lägg till minst två maträtter för att snurra hjulet.',

    'foodPanel.eyebrow': 'SUGEN PÅ',
    'foodPanel.title': 'Vad är du sugen på?',
    'foodPanel.inputHint': 'Prova Ramen',
    'foodPanel.keepAtLeastTwo': 'Behåll minst två val på hjulet.',

    'wheel.spin': 'Snurra hjulet',
    'wheel.spinning': 'Snurrar...',

    'result.decided': 'Middagen är bestämd',
    'result.placeholder': 'Ditt val visas här',

    'schedule.addButton': 'Lägg till i schemat',
    'schedule.addTooltip': 'Lägg till "{title}" i schemat',
    'schedule.added': '{title} har lagts till i schemat.',
    'schedule.addMealButton': 'Lägg till måltid',
    'schedule.eatOutButton': 'Ät ute',
    'schedule.clearDinner': 'Rensa middag',

    'homeMeals.eyebrow': 'HEMLAGAT',
    'homeMeals.title': 'Dina måltider',
    'homeMeals.addHint': 'Lägg till en hemlagad måltid',
    'homeMeals.noMatch': 'Inga måltider matchar dina filter.',
    'homeMeals.footer':
        'Behåll minst två måltider i listan. Dra för att ändra ordning när sorteringen är "Anpassad ordning". Tryck på en måltid för att lägga till ingredienser och instruktioner.',

    'mealPlan.eyebrow': 'MÅLTIDSPLANERING',
    'mealPlan.headline': 'Planera din vecka med middagar.',
    'mealPlan.subtitle': 'Tilldela en hemlagad måltid eller en kväll ute till valfri dag, dra sedan för att ändra ordning.',
    'mealPlan.weekly': 'Vecka',
    'mealPlan.monthly': 'Månad',
    'mealPlan.thisWeek': 'Den här veckan',
    'mealPlan.thisMonth': 'Den här månaden',
    'mealPlan.weekLabel': 'Vecka {number}',
    'mealPlan.footer': 'Håll ner en schemalagd middag och dra den till en annan dag för att byta plats.',

    'shopping.eyebrow': 'INKÖPSLISTA',
    'shopping.title': 'Inköpslista',
    'shopping.subtitle': 'Skapas automatiskt från de hemlagade måltider som är schemalagda den här veckan.',
    'shopping.empty': 'Inga hemlagade måltider schemalagda den här veckan än. Lägg till en under Planera för att skapa en inköpslista.',
    'shopping.forMeals': 'Till {meals}',

    'dayPicker.title': 'Lägg till i schemat',
    'dayPicker.tonight': 'Ikväll',
    'dayPicker.alreadyPlanned': 'Redan planerat',
    'dayPicker.pickDifferentDate': 'Välj ett annat datum...',
  },
};
