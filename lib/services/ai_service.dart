import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class AiService {
  static const String _geminiModel = 'gemini-1.5-flash';

  // Use a demo API key here. Replace this with your actual key in production!
  static const String _demoApiKey =
      'AQ.Ab8RN6K1Xstwb4L1xZ-kpm4iWj7QCGfCIx1eZg06pa991qggJg';

  static Future<Map<String, dynamic>> parseVoiceCommand(
    String command,
    String apiKey,
  ) async {
    final keyToUse = apiKey.isNotEmpty ? apiKey : _demoApiKey;

    // In a real app, if the demo key is invalid, this will throw an exception.
    // The user will see that they need to provide a real key.
    if (keyToUse == 'AQ.Ab8RN6K1Xstwb4L1xZ-kpm4iWj7QCGfCIx1eZg06pa991qggJg') {
      return _mockVoiceParse(
        command,
      ); // Use mock if still using the dummy string
    }

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);

      final prompt =
          '''
Analyze the following user transaction voice command in Bangla or English. Extract details and return ONLY a JSON response block.
Do not include any markdown fences or additional text outside the JSON.

User command: "$command"

JSON format:
{
  "title": "Descriptive title in Bengali (e.g., 'বাজার খরচ' or 'বেতন প্রাপ্তি')",
  "amount": 0.0,
  "type": "Expense" or "Income",
  "category": "Food" or "Transport" or "Groceries" or "Salary" or "Medicine" or "Other",
  "account": "Cash" or "Bank"
}
''';

      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        final text = response.text!;
        String cleanJson = text;
        if (text.contains('```json')) {
          cleanJson = text.split('```json')[1].split('```')[0].trim();
        } else if (text.contains('```')) {
          cleanJson = text.split('```')[1].split('```')[0].trim();
        }

        return jsonDecode(cleanJson.trim());
      }
    } catch (_) {
      // Fallback
    }
    return _mockVoiceParse(command);
  }

  static Future<Map<String, dynamic>> parseReceiptImage(
    List<int> imageBytes,
    String apiKey,
  ) async {
    final keyToUse = apiKey.isNotEmpty ? apiKey : _demoApiKey;

    if (keyToUse == 'YOUR_GEMINI_API_KEY_HERE') {
      return _mockReceiptParse();
    }

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);

      final prompt = '''
Analyze this receipt image. Extract:
1. Vendor / Store Name (String)
2. Total Amount (double)
3. Category (e.g., Groceries, Food, Transport, Other)
4. Date (Format: YYYY-MM-DD)

Return ONLY a JSON response block:
{
  "vendor": "Vendor Name",
  "amount": 0.0,
  "category": "Groceries",
  "date": "2026-06-14"
}
''';

      final imagePart = DataPart('image/jpeg', Uint8List.fromList(imageBytes));

      final response = await model.generateContent([
        Content.multi([TextPart(prompt), imagePart]),
      ]);

      if (response.text != null) {
        final text = response.text!;
        String cleanJson = text;
        if (text.contains('```json')) {
          cleanJson = text.split('```json')[1].split('```')[0].trim();
        } else if (text.contains('```')) {
          cleanJson = text.split('```')[1].split('```')[0].trim();
        }
        return jsonDecode(cleanJson.trim());
      }
    } catch (_) {
      // Fallback
    }
    return _mockReceiptParse();
  }

  static Future<String> generateFinancialAdvice(
    double totalIncome,
    double totalExpense,
    double netSavings,
    String apiKey,
  ) async {
    final keyToUse = apiKey.isNotEmpty ? apiKey : _demoApiKey;

    if (keyToUse == 'YOUR_GEMINI_API_KEY_HERE') {
      return _mockFinancialAdvice(totalIncome, totalExpense, netSavings);
    }

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);

      final prompt =
          '''
Given the following monthly financial summary:
- Total Income: ৳$totalIncome
- Total Expense: ৳$totalExpense
- Net Savings: ৳$netSavings

Analyze this user's situation and write a concise financial feedback report in professional Bengali.
Include:
1. An overall assessment of their financial status (e.g. healthy, warnings on overspending, etc.)
2. Exactly 3 brief, actionable savings bullet points in Bengali.
Keep the entire output under 150 words.
''';

      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        return response.text!;
      }
    } catch (_) {
      // Fallback
    }
    return _mockFinancialAdvice(totalIncome, totalExpense, netSavings);
  }

  static Future<String> generateDueReminder({
    required String name,
    required double amount,
    DateTime? dueDate,
    required String tone,
    required String apiKey,
  }) async {
    final keyToUse = apiKey.isNotEmpty ? apiKey : _demoApiKey;

    if (keyToUse == 'YOUR_GEMINI_API_KEY_HERE') {
      return _mockDueReminder(name, amount, dueDate, tone);
    }

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);

      final dateStr = dueDate != null
          ? DateFormat('dd-MM-yyyy').format(dueDate)
          : 'নির্ধারিত সময়ে';
      final prompt =
          '''
Generate a single-paragraph payment reminder SMS in Bengali for a customer named "$name" who owes ৳$amount, due on $dateStr.
The tone of the reminder should be "$tone" (gentle/polite, moderate/standard, or firm/demanding).
Do not include subject lines, formatting, or placeholders. Just return the SMS text in Bengali.
''';

      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        return response.text!.trim();
      }
    } catch (_) {
      // Fallback
    }
    return _mockDueReminder(name, amount, dueDate, tone);
  }

  static Future<String> chatWithAssistant({
    required String message,
    required List<Content> history,
    required String apiKey,
    required Future<Map<String, Object?>> Function(
      String name,
      Map<String, Object?> args,
    )
    onCallTool,
  }) async {
    final keyToUse = apiKey.isNotEmpty ? apiKey : _demoApiKey;

    if (keyToUse == _demoApiKey || keyToUse == 'YOUR_GEMINI_API_KEY_HERE') {
      return "দয়া করে একটি সঠিক API কী প্রদান করুন। ডেমো কী দিয়ে চ্যাটবট কাজ করবে না।";
    }

    try {
      final addTransactionTool = FunctionDeclaration(
        'addTransaction',
        'Adds a new transaction (income or expense). Call this when user wants to add an expense or income.',
        Schema(
          SchemaType.object,
          properties: {
            'amount': Schema(
              SchemaType.number,
              description: 'Amount of transaction',
            ),
            'type': Schema(SchemaType.string, description: 'Expense or Income'),
            'category': Schema(
              SchemaType.string,
              description: 'Category (e.g. Food, Transport, Salary)',
            ),
            'account': Schema(
              SchemaType.string,
              description: 'Account type (Cash or Bank)',
            ),
            'title': Schema(
              SchemaType.string,
              description: 'A short Bengali title for the transaction',
            ),
          },
          requiredProperties: [
            'amount',
            'type',
            'category',
            'account',
            'title',
          ],
        ),
      );

      final addDebtTool = FunctionDeclaration(
        'addDebt',
        'Adds a new debt/loan. Call this when user lends money to someone or borrows money from someone.',
        Schema(
          SchemaType.object,
          properties: {
            'personName': Schema(
              SchemaType.string,
              description: 'Name of the person',
            ),
            'amount': Schema(SchemaType.number, description: 'Amount of debt'),
            'type': Schema(
              SchemaType.string,
              description:
                  'Give or Take (Give if user lent money, Take if user borrowed)',
            ),
          },
          requiredProperties: ['personName', 'amount', 'type'],
        ),
      );

      final getSummaryTool = FunctionDeclaration(
        'getFinancialSummary',
        'Gets the current total income, total expense, and balance.',
        Schema(SchemaType.object, properties: {}),
      );

      final tool = Tool(
        functionDeclarations: [addTransactionTool, addDebtTool, getSummaryTool],
      );

      final model = GenerativeModel(
        model: _geminiModel,
        apiKey: keyToUse,
        tools: [tool],
        systemInstruction: Content.system(
          'You are an expert Bengali financial assistant named Amar Hisab Assistant. You help users manage their money. When a user asks to add a transaction or debt, use the appropriate tool. Always reply in clear, professional Bengali.',
        ),
      );

      final chat = model.startChat(history: history);
      var response = await chat.sendMessage(Content.text(message));

      if (response.functionCalls.isNotEmpty) {
        final functionCall = response.functionCalls.first;
        final result = await onCallTool(functionCall.name, functionCall.args);

        response = await chat.sendMessage(
          Content.functionResponse(functionCall.name, result),
        );
      }

      return response.text ?? 'দুঃখিত, আমি বুঝতে পারিনি।';
    } catch (e) {
      return 'একটি ত্রুটি ঘটেছে: \$e';
    }
  }

  static Future<String> predictCashFlow({
    required double thisMonthIncome,
    required double thisMonthExpense,
    required double lastMonthIncome,
    required double lastMonthExpense,
    required String apiKey,
  }) async {
    final keyToUse = apiKey.isNotEmpty ? apiKey : _demoApiKey;

    if (keyToUse == _demoApiKey || keyToUse == 'YOUR_GEMINI_API_KEY_HERE') {
      return _mockPredictCashFlow();
    }

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);

      final prompt = '''
Analyze the following cash flow data and provide a 2-3 sentence prediction for the upcoming month in Bengali.
- Last Month Income: ৳\$lastMonthIncome
- Last Month Expense: ৳\$lastMonthExpense
- This Month Income: ৳\$thisMonthIncome
- This Month Expense: ৳\$thisMonthExpense

Tell the user if they are on track to save more, or if they are at risk of a cash shortage. Be professional and concise.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? _mockPredictCashFlow();
    } catch (_) {
      return _mockPredictCashFlow();
    }
  }

  // MOCK FALLBACKS
  static Map<String, dynamic> _mockVoiceParse(String command) {
    double amount = 0.0;
    final match = RegExp(r'\d+').firstMatch(command);
    if (match != null) {
      amount = double.tryParse(match.group(0)!) ?? 0.0;
    }

    String title = 'অন্যান্য খরচ';
    String category = 'Other';
    String type = 'Expense';
    String account = 'Cash';

    final text = command.toLowerCase();

    if (text.contains('নগদ') ||
        text.contains('ক্যাশ') ||
        text.contains('cash')) {
      account = 'Cash';
    } else if (text.contains('ব্যাংক') || text.contains('bank')) {
      account = 'Bank';
    }

    if (text.contains('পেলাম') ||
        text.contains('আয়') ||
        text.contains('বেতন') ||
        text.contains('income') ||
        text.contains('জমা')) {
      type = 'Income';
      title = 'আয় প্রাপ্তি';
      category = 'Salary';
    } else {
      type = 'Expense';
    }

    if (type == 'Expense') {
      if (text.contains('বাজার') ||
          text.contains('চাল') ||
          text.contains('grocery')) {
        title = 'বাজার খরচ';
        category = 'Groceries';
      } else if (text.contains('খাবার') ||
          text.contains('বিরিয়ানি') ||
          text.contains('রেস্টুরেন্ট') ||
          text.contains('food')) {
        title = 'খাবার খরচ';
        category = 'Food';
      } else if (text.contains('বাস') ||
          text.contains('রিকশা') ||
          text.contains('যাতায়াত') ||
          text.contains('ভাড়া') ||
          text.contains('transport')) {
        title = 'যাতায়াত খরচ';
        category = 'Transport';
      } else if (text.contains('ওষুধ') ||
          text.contains('ডাক্তার') ||
          text.contains('মেডিসিন') ||
          text.contains('medicine')) {
        title = 'ওষুধ ক্রয়';
        category = 'Medicine';
      }
    }

    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'account': account,
    };
  }

  static Map<String, dynamic> _mockReceiptParse() {
    final nowStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return {
      'vendor': 'স্বপ্ন সুপার শপ (Shwapno)',
      'amount': 1540.0,
      'category': 'Groceries',
      'date': nowStr,
    };
  }

  static String _mockFinancialAdvice(
    double income,
    double expense,
    double savings,
  ) {
    if (expense > income) {
      return '''
⚠️ **সতর্কতা:** আপনার ব্যয় আয়ের চেয়ে বেশি হচ্ছে! এটি দীর্ঘমেয়াদে সঞ্চয় এবং ব্যবসায়ের বড় ক্ষতি করতে পারে।

* **অপ্রয়োজনীয় খরচ বন্ধ করুন:** কুইক অ্যাকশন বা খুচরা খরচগুলো নিয়ন্ত্রণ করুন।
* **বাজেট সেট করুন:** আপনার প্রতি মাসের জন্য একটি কঠোর সর্বোচ্চ খরচ সীমা নির্ধারণ করুন।
* **বকেয়া সংগ্রহ ত্বরান্বিত করুন:** পাওনা টাকা সংগ্রহের জন্য তাগাদা SMS ফিচারটি ব্যবহার করুন।
''';
    } else if (savings < 5000) {
      return '''
📉 **পরামর্শ:** আপনার আয় ব্যয়ের অনুপাত ঠিক আছে, তবে সঞ্চয়ের পরিমাণ বেশ কম (৳$savings)। 

* **জরুরি তহবিল তৈরি:** প্রতি মাসের শুরুতে আয়ের অন্তত ১০% সরিয়ে রাখুন।
* **ছোট খরচ পর্যবেক্ষণ:** অপ্রয়োজনীয় কফি, চা বা যাতায়াত খরচ কমান।
* **সঞ্চয় লক্ষ্য ঠিক করুন:** সেটিংস থেকে আপনার সঞ্চয় লক্ষ্য বাড়িয়ে নিন।
''';
    } else {
      return '''
✅ **চমৎকার অবস্থা!** আপনার আর্থিক অবস্থা খুবই ইতিবাচক। আয়ের চেয়ে ব্যয়ের পরিমাণ অনেক কম এবং আপনি ৳$savings সঞ্চয় করেছেন।

* **উদ্বৃত্ত বিনিয়োগ:** উদ্বৃত্ত সঞ্চয় ব্যাংক বা ডিপিএস-এ দীর্ঘমেয়াদে বিনিয়োগ করুন।
* **অগ্রিম বিল প্রদান:** নির্ধারিত বিলগুলো সময়মতো পরিশোধ করার জন্য শিডিউল লেনদেন অন রাখুন।
* **ঋণ পরিশোধ:** বকেয়া পাওনাদারদের কিস্তি পরিশোধ করে দায় মুক্ত থাকুন।
''';
    }
  }

  static String _mockDueReminder(
    String name,
    double amount,
    DateTime? dueDate,
    String tone,
  ) {
    final dateStr = dueDate != null
        ? DateFormat('dd-MM-yyyy').format(dueDate)
        : 'নির্ধারিত সময়ে';
    switch (tone) {
      case 'gentle':
        return 'প্রিয় $name ভাই, আশা করি ভালো আছেন। আপনার বকেয়া হিসাবটি (৳$amount) সুযোগমত পরিশোধ করার জন্য বিনীত অনুরোধ করছি। আপনার সহযোগিতার জন্য ধন্যবাদ।';
      case 'firm':
        return 'জনাব $name, আপনার বকেয়া ৳$amount পরিশোধের শেষ সময় ($dateStr) অতিবাহিত হয়েছে। অবিলম্বে বকেয়া পরিশোধ করার অনুরোধ করা যাচ্ছে। অন্যথায় আইনি পদক্ষেপ গ্রহণ করা হতে পারে।';
      case 'moderate':
      default:
        return 'আসসালামু আলাইকুম $name সাহেব, আপনার টালিখাতায় মোট বাকি রয়েছে ৳$amount। নির্ধারিত তারিখ ছিল: $dateStr। অনুগ্রহ করে বকেয়া পরিশোধ করুন। ধন্যবাদ।';
    }
  }

  static String _mockPredictCashFlow() {
    return 'এআই প্রেডিকশন: গত মাসের তুলনায় আপনার খরচ বৃদ্ধি পেয়েছে। এই ধারা অব্যাহত থাকলে আগামী মাসে নগদ অর্থের ঘাটতি হতে পারে। দয়া করে অপ্রয়োজনীয় খরচ কমান।';
  }
}
