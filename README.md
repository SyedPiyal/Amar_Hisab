# Amar Hisab (আমার হিসাব) 💸

**Amar Hisab** is a smart, AI-powered personal finance and accounting manager built with Flutter. It helps users track their income, expenses, debts, and budgets with ease, featuring advanced AI capabilities like voice-to-transaction and receipt scanning.

---

## 🚀 Key Features

### 🤖 AI-Powered Intelligence
- **Voice Commands**: Add transactions naturally in **Bangla or English** (e.g., "বাজার খরচ ৫০০ টাকা").
- **Receipt Parsing**: Automatically extract vendor, amount, and category from receipt images using Google Gemini AI.
- **Financial Advisor**: Receive personalized financial health assessments and actionable savings tips in Bengali.
- **Smart Reminders**: Generate automated, tone-adjusted (Gentle, Moderate, Firm) SMS reminders for debt recovery.

### 📊 Comprehensive Financial Tracking
- **Multi-Account Management**: Track balances across Cash, Bank, and other accounts.
- **Income & Expense Logging**: Detailed categorization with an intuitive UI.
- **Debt & Credit Tracking**: Keep a close eye on who owes you and who you owe.
- **Budgeting**: Set monthly budgets for specific categories and monitor progress.
- **Scheduled Transactions**: Automate recurring bills and income.

### 📈 Insights & Reports
- **Interactive Visualizations**: Beautiful charts and graphs powered by `fl_chart`.
- **PDF Export**: Generate professional financial reports for any period.
- **History**: Search and filter through your entire transaction history.

### 🛠 Tech Stack & Architecture
- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [Hive](https://pub.dev/packages/hive) (Fast & NoSQL)
- **AI Integration**: [Google Generative AI (Gemini)](https://pub.dev/packages/google_generative_ai)
- **Localization**: Full support for **English** and **Bangla** (`flutter_localizations`).

---

## 🛠 Installation & Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10.7 or higher)
- [Dart SDK](https://dart.dev/get-started)
- A Google Gemini API Key (Optional, for AI features)

### Getting Started
1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/amar_hisab.git
   cd amar_hisab
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```text
lib/
├── l10n/          # Localization files (English & Bangla)
├── models/        # Hive data models (User, Account, Transaction, etc.)
├── providers/     # State management logic
├── screens/       # UI Screens (Auth, Home, Reports, Debts, etc.)
├── services/      # AI, PDF, and Export services
├── theme/         # App styling and themes
└── widgets/       # Reusable UI components
```

---

## 🔒 Privacy & Security
- **Offline First**: All your financial data is stored locally on your device using Hive.
- **No Cloud Sync (Default)**: Your sensitive data stays with you unless explicitly exported.

---

## 🤝 Contributing
Contributions are welcome! If you'd like to improve Amar Hisab, please fork the repo and create a pull request.

---

## 📄 License
This project is for educational/private use. See the `pubspec.yaml` for dependency licenses.

---
*Developed with ❤️ for better financial literacy.*
