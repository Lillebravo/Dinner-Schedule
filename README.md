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

* **Frontend:** [Angular](https://angular.dev/) (Standalone Components, Signals, Reactive Forms)
* **Language:** [TypeScript](https://www.typescriptlang.org/)
* **Backend & Database:** [Supabase](https://supabase.com/)
  * **Database:** PostgreSQL with Row Level Security (RLS)
  * **Auth:** Supabase Auth (Email / Password or Magic Links)
  * **Storage:** Supabase Storage (for recipe photos)
* **Styling:** Tailwind CSS / SCSS

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
* [Node.js](https://nodejs.org/) (v18.x or v20.x recommended)
* [npm](https://www.npmjs.com/) or [pnpm](https://pnpm.io/)
* [Angular CLI](https://angular.dev/tools/cli):
  ```bash
  npm install -g @angular/cli
  ```

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/dishdash.git
   cd dishdash
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure Environment Variables:**
   Create an environment configuration file in `src/environments/environment.development.ts`:
   ```typescript
   export const environment = {
     production: false,
     supabaseUrl: 'YOUR_SUPABASE_PROJECT_URL',
     supabaseKey: 'YOUR_SUPABASE_ANON_KEY'
   };
   ```

4. **Set Up Supabase Schema:**
   Run your SQL scripts within your Supabase project's SQL Editor to set up:
   * `recipes` (id, title, instructions, prep_time, tags, created_by)
   * `ingredients` (id, name, aisle_category)
   * `recipe_ingredients` (recipe_id, ingredient_id, amount, unit)
   * `weekly_plans` (id, user_id, date, recipe_id)

5. **Run the Development Server:**
   ```bash
   ng serve
   ```
   Navigate to `http://localhost:4200/` in your browser.

---

## 📂 Project Structure

```text
src/
├── app/
│   ├── core/              # Supabase client service, auth guards, interceptors
│   ├── features/
│   │   ├── planner/       # Weekly schedule calendar component & state
│   │   ├── wheel/         # Spin-the-wheel randomized selector
│   │   ├── recipes/       # Recipe catalog, creation forms, detail views
│   │   └── grocery-list/  # Weekly aggregated grocery checklist
│   ├── shared/            # Reusable UI components, pipes, directives
│   └── app.config.ts      # Application config & routing
├── environments/          # Supabase credentials & environment configs
└── styles.scss            # Global styles and design tokens
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
