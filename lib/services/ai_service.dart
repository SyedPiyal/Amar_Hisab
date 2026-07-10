import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class AiService {
  // Use the standard model name
  static const String _geminiModel = 'gemini-3.1-flash-lite';

  // static const String _masterApiKey = 'AQ.Ab8RN6K1Xstwb4L1xZ-kpm4iWj7QCGfCIx1eZg06pa991qggJg';
  static const String _masterApiKey = 'AQ.Ab8RN6KRXL7rSTXmC7T0n_PppU9mFdRHLkRH-bWUGy7WvNryEg';

  static Future<Map<String, dynamic>> parseVoiceCommand(
    String command,
    String apiKey,
  ) async {
    final keyToUse = _getValidKey(apiKey);
    if (keyToUse == null) return _mockVoiceParse(command);
    
    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);
      final prompt = 'Extract transaction details as JSON: "$command"';
      final response = await model.generateContent([Content.text(prompt)]);
      if (response.text != null) return _extractJson(response.text!);
    } catch (e) {
      print('AiService.parseVoiceCommand error: $e');
    }
    return _mockVoiceParse(command);
  }

  static Future<Map<String, dynamic>> parseReceiptImage(
    List<int> imageBytes,
    String apiKey,
  ) async {
    final keyToUse = _getValidKey(apiKey);
    if (keyToUse == null) return _mockReceiptParse();

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);
      final imagePart = DataPart('image/jpeg', Uint8List.fromList(imageBytes));
      final response = await model.generateContent([
        Content.multi([TextPart('Extract receipt details'), imagePart]),
      ]);
      if (response.text != null) return _extractJson(response.text!);
    } catch (e) {
      print('AiService.parseReceiptImage error: $e');
    }
    return _mockReceiptParse();
  }

  static Future<String> generateFinancialAdvice(
    double totalIncome,
    double totalExpense,
    double netSavings,
    String apiKey,
  ) async {
    final keyToUse = _getValidKey(apiKey);
    if (keyToUse == null) return _mockFinancialAdvice(totalIncome, totalExpense, netSavings);

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);
      final prompt = 'Income: $totalIncome, Expense: $totalExpense, Savings: $netSavings. Give brief financial advice in Bengali.';
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? _mockFinancialAdvice(totalIncome, totalExpense, netSavings);
    } catch (e) {
      print('AiService.generateFinancialAdvice error: $e');
      return _mockFinancialAdvice(totalIncome, totalExpense, netSavings);
    }
  }

  static Future<String> generateDueReminder({
    required String name,
    required double amount,
    DateTime? dueDate,
    required String tone,
    required String apiKey,
  }) async {
    final keyToUse = _getValidKey(apiKey);
    if (keyToUse == null) return _mockDueReminder(name, amount, dueDate, tone);

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);
      final dateStr = dueDate != null ? DateFormat('dd-MM-yyyy').format(dueDate) : 'নির্ধারিত সময়ে';
      final prompt = 'Generate a $tone tone payment reminder for $name who owes $amount due on $dateStr. Reply in Bengali.';
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? _mockDueReminder(name, amount, dueDate, tone);
    } catch (e) {
      print('AiService.generateDueReminder error: $e');
      return _mockDueReminder(name, amount, dueDate, tone);
    }
  }

  static Future<String> chatWithAssistant({
    required String message,
    required List<Content> history,
    required String apiKey,
    required Future<Map<String, Object?>> Function(String name, Map<String, Object?> args) onCallTool,
  }) async {
    final keyToUse = _getValidKey(apiKey);

    if (keyToUse == null) {
      return "সিস্টেমে সঠিক API Key সেট করা নেই। দয়া করে AiService.dart ফাইলে আপনার 'AIzaSy' বা 'AQ.' দিয়ে শুরু হওয়া কী-টি বসান।";
    }

    try {
      final tools = [
        Tool(functionDeclarations: [
          FunctionDeclaration(
            'addTransaction',
            'Adds a new transaction.',
            Schema(SchemaType.object, properties: {
              'amount': Schema(SchemaType.number),
              'type': Schema(SchemaType.string, description: 'Expense or Income'),
              'category': Schema(SchemaType.string),
              'account': Schema(SchemaType.string),
              'title': Schema(SchemaType.string),
            }, requiredProperties: ['amount', 'type', 'category', 'account', 'title']),
          ),
          FunctionDeclaration(
            'getFinancialSummary',
            'Gets the current month financial summary.',
            Schema(SchemaType.object, properties: {}),
          ),
        ])
      ];

      final model = GenerativeModel(
        model: _geminiModel,
        apiKey: keyToUse,
        tools: tools,
        systemInstruction: Content.system(
          'You are Amar Hisab Assistant. Use tools for financial data. Always reply in Bengali.',
        ),
      );

      final chat = model.startChat(history: history);
      var response = await chat.sendMessage(Content.text(message));

      if (response.functionCalls.isNotEmpty) {
        final functionCall = response.functionCalls.first;
        final result = await onCallTool(functionCall.name, functionCall.args);
        // Workaround for Gemini 3.1 thought_signature bug in older SDKs
        response = await chat.sendMessage(Content.text(
          'Function ${functionCall.name} returned: ${jsonEncode(result)}. Please provide the final response to the user based on this data in Bengali.'
        ));
      }

      return response.text ?? 'দুঃখিত, আমি বুঝতে পারিনি।';
    } catch (e) {
      print('AiService.chatWithAssistant error: $e');
      if (e.toString().contains('not found') || e.toString().contains('403')) {
        return "ভুল API Key ব্যবহার করা হয়েছে। নিশ্চিত করুন যে আপনার কী-টি Google AI Studio (aistudio.google.com) থেকে নেওয়া।";
      }
      return 'এআই ত্রুটি: $e';
    }
  }

  static String? _getValidKey(String providedKey) {
    final key = providedKey.isNotEmpty ? providedKey : _masterApiKey;
    if (key.isEmpty || key.contains('YOUR_AIzaSy_KEY') || (!key.startsWith('AIzaSy') && !key.startsWith('AQ.'))) {
      return null;
    }
    return key;
  }

  static Future<String> predictCashFlow({
    required double thisMonthIncome,
    required double thisMonthExpense,
    required double lastMonthIncome,
    required double lastMonthExpense,
    required String apiKey,
  }) async {
    final keyToUse = _getValidKey(apiKey);
    if (keyToUse == null) return _mockPredictCashFlow();

    try {
      final model = GenerativeModel(model: _geminiModel, apiKey: keyToUse);
      final prompt = 'Predict next month cash flow in Bengali based on income/expense trends.';
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? _mockPredictCashFlow();
    } catch (e) {
      print('AiService.predictCashFlow error: $e');
      return _mockPredictCashFlow();
    }
  }

  static Map<String, dynamic> _extractJson(String text) {
    try {
      String cleanJson = text;
      if (text.contains('```json')) {
        cleanJson = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        cleanJson = text.split('```')[1].split('```')[0].trim();
      }
      return jsonDecode(cleanJson.trim());
    } catch (e) {
      return {};
    }
  }

  static Map<String, dynamic> _mockVoiceParse(String c) => {'title': 'অন্যান্য', 'amount': 0.0, 'type': 'Expense', 'category': 'Other', 'account': 'Cash'};
  static Map<String, dynamic> _mockReceiptParse() => {'vendor': 'স্বপ্ন', 'amount': 0.0, 'category': 'Groceries', 'date': '2024-01-01'};
  static String _mockFinancialAdvice(double i, double e, double s) => "আপনার আয়-ব্যয় নিয়ন্ত্রণে রাখুন।";
  static String _mockDueReminder(String n, double a, DateTime? d, String t) => "পাওনা পরিশোধের অনুরোধ।";
  static String _mockPredictCashFlow() => "খরচ নিয়ন্ত্রণে রাখুন।";
}
