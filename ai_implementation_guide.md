# Amar Hisab: AI Implementation & Improvement Guide

This documentation provides a comprehensive overview of the current Artificial Intelligence (AI) implementation in the **Amar Hisab** project, highlights areas for improvement, and details a roadmap for integrating new AI features.

---

## 1. Current AI Implementation

The project currently uses the `google_generative_ai` package (specifically the `gemini-1.5-flash` model) to power several smart features. 

### Existing Features
1. **Voice Command Parsing (`parseVoiceCommand`)**
   - **What:** Converts spoken Bengali/English sentences into structured JSON transaction data.
   - **Where:** `lib/services/ai_service.dart` and `lib/widgets/ai_voice_dialog.dart`.
2. **Receipt Scanning OCR (`parseReceiptImage`)**
   - **What:** Extracts vendor name, total amount, category, and date from an image of a receipt.
   - **Where:** `lib/services/ai_service.dart`.
3. **Financial Advisor (`generateFinancialAdvice`)**
   - **What:** Generates brief, actionable financial feedback in Bengali based on total income, expenses, and savings.
   - **Where:** `lib/services/ai_service.dart`.
4. **Smart SMS Generator (`generateDueReminder`)**
   - **What:** Generates tailored payment reminder SMS messages with customizable tones (gentle, moderate, firm).
   - **Where:** `lib/services/ai_service.dart`.

> [!WARNING]
> **Security Risk:** The current implementation uses a hardcoded demo API key or falls back to mock responses. This is unsafe for production and limits functionality.

---

## 2. How to Improve Current Implementation

Before adding new features, the existing AI infrastructure must be secured and optimized.

### A. Secure API Key Management
*   **What:** Remove hardcoded API keys from the source code.
*   **How:** 
    1. Add the `flutter_dotenv` package to your `pubspec.yaml`.
    2. Create a `.env` file in the root directory and add your `GEMINI_API_KEY`.
    3. Update `ai_service.dart` to load the key via `dotenv.env['GEMINI_API_KEY']`.
*   **Where:** `lib/services/ai_service.dart` and `main.dart` (to initialize dotenv).

### B. Robust JSON Parsing & Schema Definition
*   **What:** The current string manipulation used to extract JSON (e.g., `text.split('```json')`) is fragile and prone to breaking if the AI formats the response slightly differently.
*   **How:** 
    1. Update the Gemini prompt to enforce strict JSON schemas.
    2. Utilize the `responseSchema` configuration in the Gemini SDK (if available) to force structured output.
    3. Add robust `try-catch` blocks with explicit type casting and null checks when decoding the JSON.
*   **Where:** All parsing methods within `lib/services/ai_service.dart`.

### C. Context-Aware Financial Advice
*   **What:** The current financial advice is too generic as it only looks at top-level totals.
*   **How:** Fetch the top 3 highest expense categories and compare the current month's totals with the previous month's. Feed this detailed context into the Gemini prompt so it can generate highly specific advice (e.g., "Your transport expenses are 20% higher than last month").
*   **Where:** Modify `generateFinancialAdvice` in `lib/services/ai_service.dart` and the provider that calls it.

---

## 3. Where Else to Implement AI (New Features Roadmap)

Here are the advanced AI features you can implement next to elevate the app to an enterprise level.

### Feature 1: Conversational Accounting Assistant (Chatbot)
*   **What:** An interactive chat interface where users can ask complex questions naturally. (e.g., *"How much do I owe Rahim?"*, *"What were my total sales last week?"*).
*   **How:** 
    1. Use Gemini with **Function Calling (Tools)**.
    2. Define Dart functions that query your Hive database (e.g., `getDebtSummary(name)`, `getTransactionsByDateRange(startDate, endDate)`).
    3. Pass these tool declarations to the Gemini model. When a user asks a question, Gemini will instruct the app to execute the correct database function and then return a natural language response based on the data.
*   **Where:** Create a new feature module at `lib/screens/ai_chat/`.

### Feature 2: Anomaly Detection & Typo Prevention
*   **What:** Identify unusual transactions to prevent user errors before they are saved. (e.g., User usually spends ৳100 on transport but types ৳10,000).
*   **How:** 
    1. When the user taps 'Save Transaction', fetch the historical average amount for that specific category.
    2. If the entered amount is more than 3x the average, trigger a prompt to Gemini or use a simple statistical check to ask: *"This amount seems unusually high for this category. Are you sure?"*
*   **Where:** `lib/providers/transaction_provider.dart` (inside the save transaction logic).

### Feature 3: Predictive Cash Flow Projections
*   **What:** Predict future cash flow shortages based on historical spending habits.
*   **How:** 
    1. Aggregate the last 3-6 months of monthly income and expenses.
    2. Pass this historical data array to Gemini.
    3. Ask Gemini to project the upcoming month's financial health and provide a warning if a cash shortage is highly probable.
*   **Where:** Add a new "AI Projections" tab in `lib/screens/reports_screen.dart`.

### Feature 4: Automated Bank SMS Parsing
*   **What:** Automatically suggest adding transactions by reading incoming bank SMS alerts.
*   **How:** 
    1. Use a package like `telephony` to listen for incoming SMS (requires user permission).
    2. If the sender is a known bank (e.g., bKash, DBBL), pass the SMS text to Gemini to extract the amount, type (income/expense), and context.
    3. Display a floating notification in the app: *"We detected a new bKash payment of ৳500. Add to ledger?"*
*   **Where:** Create a background listener in `lib/services/sms_service.dart`.

---

> [!TIP]
> **Recommended Next Step:** 
> Start by implementing **Secure API Key Management (A)**. Once your infrastructure is secure and you have a valid API key running, move on to **Robust JSON Parsing (B)** to ensure your current features never crash. Only after the foundation is solid should you begin building the **Conversational Chatbot (Feature 1)**.
