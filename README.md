# Amar Hisab (আমার হিসাব) 💸

<p align="center">
  <img src="assets/images/appLogo.png" alt="Amar Hisab Logo" width="120" height="120" style="border-radius: 20%;" />
</p>

<p align="center">
  <strong>An Enterprise-Grade, Offline-First Personal Finance, AI Assistant & Micro-POS Solution built with Flutter & Google Gemini AI.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Google_Gemini-AI-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Hive-NoSQL_DB-FF6F00?style=for-the-badge&logo=hive&logoColor=white" alt="Hive" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License" />
</p>

---

## 🌟 Overview

**Amar Hisab (আমার হিসাব)** is a full-featured, cross-platform financial management and Point-of-Sale (POS) ecosystem designed to bridge modern AI capabilities with real-world small business and personal accounting workflows.

Built from the ground up with **Flutter** and engineered around an **Offline-First Architecture**, Amar Hisab integrates **Google Gemini AI** for natural language voice parsing, receipt OCR, automated conversational function calling, cash flow predictions, and smart bilingual debt reminders. Additionally, it offers a micro-merchant billing engine featuring **ESC/POS Bluetooth Thermal Printing** and **Mobile Camera Barcode/QR Code Scanning**.

---

## 🚀 Key Highlights & Engineering Features

### 🤖 1. Gemini AI & Voice Intelligence
* **Voice-to-Transaction Parsing**: Speak naturally in **Bangla or English** (e.g., *"গতকাল বাজারে মাছ কিনলাম ৬৫০ টাকা ক্যাশ থেকে"*). Gemini extracts `amount`, `category`, `account`, and `type` into structured JSON.
* **Computer Vision Receipt Scanner**: Snap a picture of any invoice or grocery bill to automatically OCR and extract vendor name, total amount, date, and category.
* **Conversational AI with Tool/Function Calling**: Chat with an AI assistant that can dynamically query your financial database (`getFinancialSummary`) or execute actions (`addTransaction`) using Gemini Function Declarations.
* **AI Predictive Cash Flow & Health Advisor**: Analyzes month-over-month income vs. expenditure trajectories and outputs actionable financial recommendations in Bengali.
* **Tone-Aware Debt Recovery Generator**: Auto-generates personalized debt reminder SMS with adjustable tones (**Gentle**, **Moderate**, **Firm**) to facilitate respectful debt collection.

---

### 🛒 2. Micro-POS & Inventory Management
* **Bluetooth Thermal Receipt Printing**: Direct integration with 58mm / 80mm ESC/POS thermal printers via `print_bluetooth_thermal` for live retail receipt printing.
* **Barcode & QR Code Scanner**: Integrated high-speed camera scanning via `mobile_scanner` for rapid product lookup, stock checking, and cart additions.
* **Complete Retail Checkout Flow**: Product catalog management, cart calculations, customizable shop branding, discount/tax calculations, and instant customer invoice generation.
* **Inventory Tracking**: Stock level monitoring with low-inventory warnings.

---

### 💳 3. Comprehensive Financial Management
* **Multi-Account Ecosystem**: Manage balances across multiple liquid sources (Cash, Bank Accounts, Mobile Financial Services like bKash/Nagad/Rocket).
* **Double-Entry Style Ledger**: Track both personal income/expenses and business cash flows.
* **Debt & Credit (Udhari / Baki) Tracker**: Keep granular records of debts owed to you or payable by you, with due date tracking and automated settlement logs.
* **Smart Budgeting & Savings Goals**: Define category-based spending caps with real-time progress indicators and goal milestones.
* **Scheduled & Recurring Transactions**: Automate recurring bills, salaries, and subscriptions.

---

### 📊 4. Analytics & Document Generation
* **Interactive Financial Analytics**: Rich charts and historical breakdown graphs powered by `fl_chart`.
* **PDF Financial Statements**: Generate downloadable, print-ready, professional PDF statements for audits or personal records using `pdf` and `printing`.
* **Data Portability**: Full data export capabilities for external accounting tools.

---

### ⚡ 5. Offline-First & Cloud Synchronization Engine
* **Sub-Millisecond NoSQL Storage**: Utilizes **Hive** with custom TypeAdapters for zero-latency local read/writes without requiring active network connectivity.
* **Hybrid Firebase Cloud Sync**: Seamless synchronization with **Cloud Firestore** whenever an internet connection is detected via `connectivity_plus`.
* **Conflict-Resilient Sync Queue**: Offline operations are queued and reconciled transparently against the cloud backend.
* **Secure Authentication**: Firebase Auth for email/password authentication alongside persistent local sessions.

---

### 🌐 6. Native Localization (i18n) & Modern UI
* **Bilingual Support**: Instant runtime toggle between **English** and **Bengali (বাংলা)** via `flutter_localizations` with full Unicode typography.
* **Material Design 3**: Polished design system with dynamic theming (Light/Dark mode), smooth micro-animations, and responsive layouts.

---

## 🏗 System Architecture & Tech Stack

```
┌────────────────────────────────────────────────────────────────────────┐
│                               UI LAYER                                 │
│  Screens: Auth | Dashboard | POS Billing | Transactions | Reports     │
│  Widgets: Voice Modal | Scanner Overlay | Custom Charts | Receipts     │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ (ChangeNotifier / Provider)
┌───────────────────────────────────▼────────────────────────────────────┐
│                            STATE LAYER                                 │
│   AuthProvider | TransactionProvider | BillingProvider | DebtProvider │
│   InventoryProvider | BudgetProvider | PrinterProvider | ShopProvider  │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                            SERVICE LAYER                               │
│  AiService (Gemini API & Tools)  │  PrinterHelper (ESC/POS Bluetooth)  │
│  SyncService (Cloud Queue)       │  PdfService (Document Generation)   │
│  FirestoreService (Firebase API) │  ConnectivityService (Network)      │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│                         PERSISTENCE LAYER                              │
│   Hive NoSQL Local DB (TypeAdapters) ◄──► Cloud Firestore (Remote DB)  │
└────────────────────────────────────────────────────────────────────────┘
```

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart 3) | Cross-platform high-performance rendering engine with single codebase. |
| **State Management** | Provider (MVVM Pattern) | Lightweight, predictable reactive state management with dependency injection. |
| **Local Database** | Hive NoSQL | Pure Dart lightweight key-value database offering blazing-fast disk I/O. |
| **Cloud Backend** | Firebase Auth & Cloud Firestore | Real-time scalable document database with built-in identity management. |
| **Generative AI** | Google Gemini (3.1 Flash) | Multimodal AI for NLP voice parsing, image receipt OCR, and conversational tool execution. |
| **Hardware & POS** | ESC/POS Bluetooth Thermal & Mobile Scanner | Hardware abstraction for direct receipt printing and barcode scanning. |
| **Charts & PDFs** | `fl_chart`, `pdf`, `printing` | Custom vector rendering for dynamic data visualization and document generation. |

---

## 📂 Project Structure

```text
amar_hisab/
├── assets/
│   └── images/                # App branding and launcher assets
├── lib/
│   ├── app_providers.dart     # MultiProvider root registration
│   ├── firebase_options.dart  # Generated Firebase configuration
│   ├── main.dart              # Application entry point & Hive initialization
│   ├── l10n/                  # Localization (English & Bengali translation maps)
│   ├── models/                # Domain models & Hive TypeAdapters
│   │   ├── billing/           # POS Models (Product, Shop, CartItem)
│   │   ├── transaction.dart   # Transaction entity
│   │   ├── account.dart       # Financial Account entity
│   │   ├── debt.dart          # Debt & Credit ledger entity
│   │   └── sync_operation.dart# Offline-to-cloud synchronization queue
│   ├── providers/             # Global ChangeNotifier providers
│   │   └── billing/           # POS, Product, Shop & Printer providers
│   ├── screens/               # Feature-based UI Modules
│   │   ├── accounts/          # Account management screens
│   │   ├── ai_chat/           # Gemini conversational assistant screen
│   │   ├── auth/              # Login, Registration & Auth providers
│   │   ├── billing/           # POS Billing, Checkout & Thermal printing
│   │   ├── debts/             # Debt ledger & AI SMS reminder modal
│   │   ├── inventory/         # Stock management & Barcode scanner
│   │   ├── reports/           # Financial analytics, Charts & PDF export
│   │   ├── settings/          # Language, Theme & Gemini API Key setup
│   │   └── transactions/      # Income/Expense forms & Voice modals
│   ├── services/              # Business logic & hardware wrappers
│   │   ├── ai_service.dart    # Gemini API, Vision OCR & Function calling
│   │   ├── billing/           # ESC/POS Bluetooth printer helper
│   │   ├── firestore_service.dart # Remote Cloud Firestore sync adapter
│   │   ├── sync_service.dart  # Offline-first queue & reconciliation logic
│   │   ├── pdf_service.dart   # PDF invoice & financial report builder
│   │   └── database_service.dart # Hive box orchestrator
│   ├── theme/                 # App color palettes, typography, and styles
│   └── widgets/               # Reusable UI components & custom dialogs
└── pubspec.yaml               # Project dependencies & asset configuration
```

---

## 🛠 Getting Started & Setup Guide

### Prerequisites
* **Flutter SDK**: `>= 3.10.7`
* **Dart SDK**: `>= 3.0.0`
* **Android SDK**: `minSdkVersion 21+` (Required for Bluetooth & Adaptive Icons)
* **Google Gemini API Key**: Obtain a free API key from [Google AI Studio](https://aistudio.google.com/).

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/amar_hisab.git
   cd amar_hisab
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive TypeAdapters:**
   If modifying domain models or running for the first time:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Firebase Configuration (Optional for Cloud Sync):**
   * Place your `google-services.json` in `android/app/` (and `GoogleService-Info.plist` for iOS).
   * Run `flutterfire configure` if connecting to your own Firebase project.

5. **Run the Application:**
   ```bash
   flutter run
   ```

6. **Configure Gemini AI Key in App:**
   * Open the app ➡️ Navigate to **Settings** ➡️ **AI Settings** ➡️ Paste your Google Gemini API Key (Starts with `AIzaSy...`).

---

## 💡 Key Engineering Decisions & Best Practices

1. **Why Hive for Local-First Architecture?**
   * SQLite overhead is unnecessary for single-user mobile key-value querying. Hive provides zero-native-bridge Dart execution with serialized binary storage, resulting in near-instant load times even with thousands of transaction records.
2. **Resilient AI Fallbacks**:
   * If network connectivity is unavailable or the user has not provided a Gemini API Key, `AiService` falls back gracefully to localized heuristics and mock parsing without crashing or blocking the user.
3. **Hardware Abstraction for ESC/POS Printing**:
   * Designed a specialized `PrinterHelper` that compiles receipt layouts directly into standard ESC/POS byte commands, supporting customizable shop logos, QR codes, and formatted itemized invoices for 58mm/80mm Bluetooth printers.
4. **Clean Code & Separation of Concerns**:
   * UI components remain dumb and reactive. All business logic, asynchronous task dispatching, and synchronization operations reside inside dedicated Services and ChangeNotifier Providers.

---







