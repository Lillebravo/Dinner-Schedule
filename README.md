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
├── main.dart              # App entry point and MaterialApp setup
├── dinner_wheel_page.dart # Spin-the-wheel screen: food list, form, layout
├── wheel_painter.dart      # CustomPainter for wheel slices, hub, and labels
└── wheel_math.dart         # Pure rotation/label geometry (unit tested)
test/
├── widget_test.dart        # Widget tests for add/remove/spin behavior
└── wheel_math_test.dart    # Unit tests for wheel geometry
```

---

## 🗺️ Roadmap

- [ ] **AI-Powered "Pantry Cleanout":** Suggest meals based on ingredients you already have.
- [ ] **Export to Notes / Reminders:** One-click grocery export to Apple Reminders, Google Keep, or WhatsApp.
- [ ] **Meal Prep Batch Mode:** Flag shared prep steps (e.g., "Chop 4 onions for Tuesday and Thursday").
- [ ] **Shared Household Mode:** Multi-user household sync via Supabase Realtime.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
