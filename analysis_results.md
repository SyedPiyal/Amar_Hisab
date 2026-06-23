# Project Analysis & Modernization Plan for "Amar Hisab"

This document provides a comprehensive analysis of the **Amar Hisab** Flutter accounting application. It highlights the existing features, lists missing core accounting features, compares the project with the popular Bangladeshi business app **Talikhata (টালিখাতা)**, outlines how to exceed Talikhata's capabilities, and details how and where to implement modern AI features.

---

## 1. Current Project Architecture & Features

The project is structured as a clean, localized, local-first Flutter application utilizing:
*   **Database:** `Hive` & `Hive Flutter` for local caching and offline operations.
*   **State Management:** `Provider` for reactive UI updates.
*   **Visualizations:** `fl_chart` for custom reporting.
*   **Documents:** `pdf` and `printing` for document rendering.
*   **Localization:** Out-of-the-box support for English (`en`) and Bangla (`bn`).

### Existing Feature Set
1.  **Authentication & Onboarding:** Setup wizard and user credentials stored via Hive (`userBox`).
2.  **Dashboard:** Accounts status (Cash, Bank), savings progress tracker, recent transactions list, and a 7-day graphical trend line.
3.  **Account Ledger:** Dual management modes supporting simple ledger tracking or double-entry ledgers.
4.  **Transaction Ledger:** Creation, deletion, category tagging, search, and expense category breakdown.
5.  **Debt Ledger (দেনা-পাওনা):** Debt list, partial payments (instalments), debtor/creditor categories, and automatic transaction linkings.
6.  **Reports:** Periodical expense bar-charts, category-wise pie-charts, Profit & Loss statements, CSV exports, and printable PDF invoice templates.

---

## 2. Missing Core Accounting Features

For a general business or individual bookkeeping application, the following traditional accounting components are missing or incomplete:

| Missing Feature | Description | How & Where to Implement |
| :--- | :--- | :--- |
| **Complete Chart of Accounts (COA)** | A systematic structure categorizing Assets, Liabilities, Equity, Revenues, and Expenses into hierarchical ledger nodes. | **Model:** Create `lib/models/chart_of_accounts.dart` referencing parent-child account IDs.<br>**Provider:** Create `lib/providers/coa_provider.dart` to manage nodes.<br>**UI:** A tree-view account builder screen under `lib/screens/accounts/`. |
| **Transaction Attachments** | Supporting receipt images, PDF invoices, or utility bill photos as evidence for ledger transactions. | **Model:** Modify [transaction.dart](file:///e:/AndroidProject/f/amar_hisab/lib/models/transaction.dart) to support a list of file paths: `List<String> attachmentPaths`.<br>**UI:** Add a gallery/camera attachment picker in [add_transaction_screen.dart](file:///e:/AndroidProject/f/amar_hisab/lib/screens/transactions/add_transaction_screen.dart) using `image_picker` or `file_picker`. |
| **Active Scheduled Bills** | The current scheduled transactions screen is a static design mockup. It does not run background schedules. | **Logic:** Implement `workmanager` or `android_alarm_manager_plus` background tasks that poll scheduled configurations daily, inserting a new `Transaction` if the current date matches the recurrence condition. |
| **Tax/VAT Adjustments** | Calculation of tax rates on expense items, separated ledger logs for Tax paid, and VAT inputs. | **Model:** Add `taxPercentage` and `taxAmount` to [transaction.dart](file:///e:/AndroidProject/f/amar_hisab/lib/models/transaction.dart).<br>**UI:** Implement a toggle inside [add_transaction_screen.dart](file:///e:/AndroidProject/f/amar_hisab/lib/screens/transactions/add_transaction_screen.dart) to automatically compute tax based on transaction gross amount. |
| **Account Reconciliation** | Reconciling internal cash/bank accounts with actual bank statements or transactions received via SMS. | **Logic:** Parse bank statement CSV/Excel imports. Cross-reference transaction timestamp and amount with Hive transactions to flags mismatches. |

---

## 3. Comparative Analysis: Amar Hisab vs. Talikhata (টালিখাতা)

**Talikhata** is a highly optimized, micro-merchant transaction tracker designed for the Bangladeshi SME market.

### What Talikhata Has That "Amar Hisab" Lacks
1.  **Tagada SMS (তগাদা SMS - Due Reminders):**
    *   *Talikhata:* One-tap SMS reminders sent to customers regarding pending credits with a pre-written polite template.
    *   *Amar Hisab:* Lacks phone number entries on Debtors/Creditors, meaning direct notifications are impossible.
2.  **Payment Link Integration (TallyPay):**
    *   *Talikhata:* Merchants can request online payments using a custom link. Customers pay via bKash, Nagad, Rocket, or card, which deposits directly into the merchant's linked wallet.
    *   *Amar Hisab:* Works strictly offline and does not integrate payments.
3.  **Cloud Backup & OTP Login:**
    *   *Talikhata:* Immediate cloud backup using a mobile number. If a merchant loses their phone, their ledger data is safe.
    *   *Amar Hisab:* Relies on Hive local data. If the app is uninstalled, data is permanently deleted.
4.  **Contact Book Picker:**
    *   *Talikhata:* Pulls names and phone numbers directly from the device phonebook.
    *   *Amar Hisab:* Requires manual typing of person names.

---

## 4. How to Outperform Talikhata

To make **Amar Hisab** the preferred choice over Talikhata, you can leverage Flutter's cross-platform nature and target advanced users:

1.  **Multi-Platform Access (Web & Desktop):**
    *   Talikhata is mobile-only. You can compile Amar Hisab to **Web** and **Windows Desktop**, enabling shopkeepers to run their accounts from a PC or tablet.
2.  **Advanced Analytics and Profitability Reports:**
    *   Provide fully comprehensive reports like Cash Flow Statements, Balance Sheets, and category-wise margin analyzers which Talikhata lacks.
3.  **Multi-Currency support:**
    *   Support BDT, USD, EUR, etc. dynamically for freelancers, importers, and e-commerce merchants.
4.  **AI-Powered Automation (The Core Advantage):**
    *   Add voice processing, automated receipt scanning, and AI financial advice to create a modern bookkeeping experience.

---

## 5. Integrating AI: Where, What, & How to Implement

Integrating AI will modernize the app. Below is the roadmap on how to build and place these features.

### A. Voice-Activated Bookkeeping (কণ্ঠস্বর দিয়ে হিসাব)
*   **What it does:** Allows users to speak a transaction (e.g., *"১০০ টাকার চাল কিনলাম ক্যাশ অ্যাকাউন্ট থেকে"* or *"Received 5000 from Karim"*). The AI transcribes the voice, extracts structured transaction parameters, and automatically inserts the ledger entry.
*   **Where to implement:**
    *   **UI:** Add a floating microphone icon in [dashboard_screen.dart](file:///e:/AndroidProject/f/amar_hisab/lib/screens/home/dashboard_screen.dart) or a button inside [add_transaction_screen.dart](file:///e:/AndroidProject/f/amar_hisab/lib/screens/transactions/add_transaction_screen.dart).
    *   **Packages:** Add `speech_to_text: ^6.6.0` (for speech-to-text conversion) and `google_generative_ai: ^0.2.0` (for calling the Gemini API).
*   **How to implement (Logic Flow):**
    1.  Activate microphone recording and fetch the text transcript.
    2.  Send the transcript to **Gemini API** using a structured prompt:
        ```text
        You are an accounting parser. Extract transaction details from the user speech:
        Speech: "${speechText}"
        Format: Return ONLY a JSON object:
        {
          "title": "Short descriptive name in Bangla",
          "amount": double,
          "type": "Income" or "Expense",
          "category": "Food" | "Transport" | "Groceries" | "Salary" | "Salary/Business" | "Other",
          "account": "Cash" or "Bank"
        }
        ```
    3.  Parse the JSON response in Flutter and update the `TransactionProvider` data.

---

### B. AI receipt Scanner & OCR (রসিদ স্ক্যানার)
*   **What it does:** The user snaps a picture of an invoice or receipt. The AI extracts the vendor, total price, VAT, items, and date.
*   **Where to implement:**
    *   **UI:** Add an "AI Scan Receipt" option inside [add_transaction_screen.dart](file:///e:/AndroidProject/f/amar_hisab/lib/screens/transactions/add_transaction_screen.dart).
    *   **Packages:** `image_picker: ^1.0.7` and `google_generative_ai: ^0.2.0` (using Multimodal Gemini models like `gemini-1.5-flash`).
*   **How to implement (Logic Flow):**
    1.  User takes an image via `ImagePicker`.
    2.  Load image bytes and send them as a multipart request to Gemini:
        ```text
        Analyze this receipt image. Extract:
        - Total Amount (numeric)
        - Date (YYYY-MM-DD format)
        - Vendor Name / Store Name
        - Category
        Return JSON representation only.
        ```
    3.  Pre-fill the transaction input forms with these parsed values, enabling the user to save it with one click.

---

### C. AI Financial Advisor & Cashflow Forecast (আর্থিক এআই উপদেষ্টা)
*   **What it does:** Analyzes spending behaviors and predicts cash flow. Tells the user if their business or personal budget is heading towards a deficit.
*   **Where to implement:**
    *   **UI:** Create a new card or sub-route under [reports_screen.dart](file:///e:/AndroidProject/f/amar_hisab/lib/screens/reports/reports_screen.dart) labeled "এআই আর্থিক পরামর্শ" (AI Advisor).
    *   **Packages:** `google_generative_ai` SDK.
*   **How to implement (Logic Flow):**
    1.  Serialize the list of last 30 transactions as a structured text block:
        ```text
        Date: 2026-06-01, Amount: 5000, Type: Income, Title: Salary
        Date: 2026-06-02, Amount: 1200, Type: Expense, Title: Internet Bill
        Date: 2026-06-03, Amount: 400, Type: Expense, Title: Market
        ```
    2.  Send to Gemini with the system instruction:
        ```text
        You are a business financial analyst. Based on this user's monthly ledger:
        1. Identify the top 3 highest spending categories.
        2. Identify any warning pattern (e.g. expenses outperforming income).
        3. Provide 3 action items in professional Bengali.
        ```
    3.  Display the generated markdown output beautifully on the dashboard card.

---

### D. Smart Due Reminder Generator (স্মার্ট তগাদা জেনারেটর)
*   **What it does:** Evaluates a debtor's records (outstanding balance, due date status) and writes a custom, polite reminder in Bengali suitable for SMS or WhatsApp.
*   **Where to implement:**
    *   **UI:** Add an "এআই তগাদা" (AI Reminder) action button inside [debt_details_screen.dart](file:///e:/AndroidProject/f/amar_hisab/lib/screens/debts/debt_details_screen.dart).
    *   **Integration:** Use `url_launcher` to load the generated text into the native SMS app or WhatsApp.
*   **How to implement (Logic Flow):**
    1.  Pass the debtor's profile (`personName`, `remainingAmount`, `dueDate`) to Gemini:
        ```text
        Create a polite, professional payment reminder in Bengali for customer "${personName}" who owes ৳${remainingAmount}. Mention the due date was ${dueDate}. Keep it concise for SMS.
        ```
    2.  Provide options for "Gentle" (নরম), "Moderate" (মাঝারি), or "Firm" (কড়া) tone templates.
    3.  Clicking "Send" launches the default SMS/WhatsApp composer populated with the chosen reminder.
