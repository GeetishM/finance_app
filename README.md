
# Finance Companion

**A premium, privacy-first personal finance manager built with Flutter.**


## Badges

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Hive](https://img.shields.io/badge/Hive-Database-FF9E0F?style=for-the-badge)](https://pub.dev/packages/hive)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

*100% Offline • Local-First • Lightning Fast • Absolute Privacy*

## Overview
**Finance Companion** is not just another ledger—it's a study in Local-First UX. Unlike traditional finance apps that require cloud syncing, mandatory accounts, and risk exposing your financial data, this app operates on a **100% Offline & Local-First philosophy**. 

All your financial data stays exactly where it belongs: on your device. By combining high-performance local storage with a meticulously polished interface, Finance Companion proves that "Offline" doesn't have to mean "Simple." It is built for the user who values their data privacy as much as their financial health.

---
## Core Features
* 📊 **Intelligent Dashboard:** Real-time tracking of Total Balance, Income, and Expenses wrapped in a stunning glassmorphic visual style.
* 📈 **Data Visualization:** Interactive Pie Charts for category-wise spending and Bar Charts for daily expense trends.
* 🎯 **Savings Goals:** A dedicated module to set, track, and visualize progress toward your biggest financial milestones.
* 🌍 **Offline Localization:** Full support for **22 Indian languages**, powered by a local dictionary to ensure maximum accessibility without needing an internet connection.
* ⏰ **Smart Reminders:** Local push notifications and in-app banners that nudge you to log daily expenses.
* 🌗 **Adaptive Theming:** Seamlessly integrated Dark and Light modes that respect your system settings or manual preference.


## Technical Architecture

This app is built to be robust, responsive, and scalable using modern Flutter architecture.

* **Framework:** Flutter (Dart)
* **State Management:** `Provider` (for reactive UI updates and clean separation of business logic).
* **Local Database:** `Hive` (a lightweight, blazing-fast NoSQL database for local storage).
* **Notifications:** `flutter_local_notifications` combined with `timezone` for accurate, offline scheduling.
* **Charts:** `fl_chart` for highly customizable and performant data rendering.

---

## UI/UX Refinements (The "Why" Behind the Design)

To elevate Finance Companion from a basic utility to a production-ready product, meticulous attention was paid to the UI/UX:

* **Dialogue Layout & Safety:** Dialog titles are wrapped in `Expanded` widgets with calculated `actionsPadding`. *Why?* Prevents text overflow on smaller devices and provides breathing room between destructive buttons and dialog borders.
* **Destructive Action Clarity:** Buttons read "Delete All" instead of "Delete Everything". *Why?* Standardizes layout for narrow screens, preventing the UI from squishing buttons side-by-side while maintaining clear intent.
* **Whitespace & Visual Hierarchy:** Custom `contentPadding` (`fromLTRB(24, 20, 24, 12)`) in alert components. *Why?* Ensures a balanced vertical rhythm between titles, body descriptions, and action buttons, reducing cognitive load.
* **Tactile Button Feedback:** Explicit padding (`symmetric(horizontal: 20, vertical: 12)`) is forced on ElevatedButtons. *Why?* Guarantees buttons maintain a premium "pill" shape and a large tap target, even when the OS tries to shrink them.
* **Localization & Text Fitting:** Used `FittedBox` with `BoxFit.scaleDown` for currency displays. *Why?* Financial amounts vary wildly in length (e.g., ₹10 vs ₹1,00,00,000). This ensures large numbers never wrap to a second line, preserving mathematical clarity.

---
## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) (Version 3.0.0 or higher)
* Android Studio / VS Code

### Installation

1. Clone the repository
   ```bash
    git clone [https://github.com/yourusername/finance-companion.git](https://github.com/yourusername/finance-companion.git)
   ```

2. Navigate to the project directory
    ```bash 
        cd finance-companion
    ```
3. Install dependencies
```bash 
    flutter pub get
```
4. Generate Hive type adapters
```bash
    flutter packages pub run build_runner build
```
5. Run the app
```bash
    flutter run
```


## Demo

https://drive.google.com/file/d/1BoXBRevI4qzx2VSuyaDk0lA7B9z4ZB01/view?usp=sharing

