# 🍽️ DishDash — Smart Dinner Planner & Grocery Assistant

> An intuitive, full-stack dinner planning assistant built to end decision fatigue, simplify weekly meal prep, and streamline your grocery runs.

---

## 📖 Overview

"What should we have for dinner?" shouldn't be the hardest question of your day.

**DishDash** is a modern meal management application designed to organize your favorite home recipes, schedule meals across the week, compile an automated master grocery list, and help you decide what to eat when inspiration runs dry.

---

## ✨ Key Features

### 📅 Weekly Dinner Planner
* **7-Day Schedule:** Assign dinners for Monday through Sunday with quick-swap options.
* **Batch Planning:** Plan an entire week in seconds or let the app fill empty slots automatically.

### 🎡 "Spin the Wheel" Decision Maker
* **Stuck on what to cook?** Spin the randomized dinner wheel to make quick choices.
* **Smart Filters:** Constrain the wheel by tags such as *Quick (<30m)*, *Vegetarian*, *Comfort Food*, or *Pantry Friendly*.

### 📖 Recipe Vault & Cooking Mode
* **Step-by-Step Instructions:** Clean, distraction-free cooking directions.
* **Dynamic Ingredients:** Scalable serving sizes with exact measurements.
* **Tagging & Metadata:** Filter dishes by prep time, difficulty, cuisine, and dietary requirements.

### 🛒 Consolidated Grocery List
* **Automated Aggregation:** Combines overlapping ingredients across the entire week (e.g., 2 onions + 3 onions = 5 onions).
* **Categorized Checklist:** Organizes items by aisle (Produce, Dairy, Spices, Meat, Pantry) for faster grocery shopping.
* **Pantry Stash Toggles:** Mark ingredients you already have at home so you only buy what you need.

---

## 🛠️ Tech Stack

* **Frontend:** [Flutter](https://flutter.dev/) (Dart, Material 3)
* **Backend & Database:** [Supabase](https://supabase.com/) *(planned)*
  * **Database:** PostgreSQL with Row Level Security (RLS)
  * **Auth:** Supabase Auth (Email / Password or Magic Links)
  * **Storage:** Supabase Storage (for recipe photos)

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.44.x or newer)
* A target device: Chrome/Edge (web), Windows desktop, or a mobile emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/dishdash.git
   cd dishdash
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run -d chrome
   ```
   Or target Windows desktop with `flutter run -d windows`.

4. **Run tests:**
   ```bash
   flutter test
   ```

Supabase configuration (project URL, anon key, and schema) will be documented here once the backend is wired up.

---

## 📂 Project Structure

```text
lib/
├── main.dart                     # Entry point (exports app.dart)
├── app.dart                      # MaterialApp + theme setup
├── models/                       # Food, Meal - plain data classes
├── controllers/                  # FoodListController, MealListController, WheelSpinController
├── theme/                        # AppColors + AppTheme
├── utils/                        # wheel_math.dart - pure rotation/label geometry (unit tested)
├── widgets/
│   ├── common/                   # Reused across pages: EyebrowLabel, PrimaryButton, SectionIntro, PanelHeader, CountBadge, EntryInputRow
│   ├── wheel/                    # WheelPainter, WheelDisplay, WheelStage, SpinResultLabel
│   ├── food/                     # FoodPanel, FoodListTile (eating-out wheel entries)
│   ├── meal/                     # MealTile, MealSortControl, MealEditSheet (home meals)
│   └── navigation/               # AppBottomNavBar
└── pages/
    ├── main_shell.dart           # Bottom-nav shell holding all 5 sections
    ├── eating_out_wheel_page.dart
    ├── home_wheel_page.dart
    ├── home_meals_list_page.dart # Add/favorite/sort/reorder + recipe details
    └── placeholder_page.dart     # "Coming soon" (shopping list, meal planning)
test/
├── widget_test.dart              # Navigation + wheel + meals list widget tests
├── meal_list_controller_test.dart# Unit tests for meal list logic (sort, favorite, reorder)
└── wheel_math_test.dart          # Unit tests for wheel geometry
```

The bottom navigation bar has five sections: **Eat Out** (a wheel for restaurants/takeout), **Meals** (manage your home-cooked recipes), **Spin** (the home-cooking wheel, in the middle), **Shopping** and **Plan** (placeholders for now).


---

## 🗺️ Roadmap

- [ ] **AI-Powered "Pantry Cleanout":** Suggest meals based on ingredients you already have.
- [ ] **Export to Notes / Reminders:** One-click grocery export to Apple Reminders, Google Keep, or WhatsApp.
- [ ] **Meal Prep Batch Mode:** Flag shared prep steps (e.g., "Chop 4 onions for Tuesday and Thursday").
- [ ] **Shared Household Mode:** Multi-user household sync via Supabase Realtime.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
