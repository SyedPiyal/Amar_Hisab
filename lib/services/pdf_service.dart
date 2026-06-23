import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class PdfExportService {
  static final String _fontUrl = 'https://github.com/google/fonts/raw/main/ofl/hindsiliguri/HindSiliguri-Regular.ttf';
  static Uint8List? _fontData;

  static Future<pw.Font> _getFont() async {
    if (_fontData == null) {
      final response = await http.get(Uri.parse(_fontUrl));
      if (response.statusCode == 200) {
        _fontData = response.bodyBytes;
      } else {
        throw Exception('Failed to load font');
      }
    }
    return pw.Font.ttf(_fontData!.buffer.asByteData());
  }

  static Future<void> exportProfitLoss({
    required List<Transaction> incomeTxs,
    required List<Transaction> expenseTxs,
    required double totalIncome,
    required double totalExpense,
    required double netProfit,
  }) async {
    final pdf = pw.Document();
    final font = await _getFont();
    final date = DateFormat('dd MMM, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => [
          _buildHeader('লাভ-ক্ষতি বিবরণী (Profit & Loss Statement)', date),
          pw.SizedBox(height: 20),
          _buildSummaryCard('নিট লাভ/ক্ষতি (Net Profit)', netProfit, font),
          pw.SizedBox(height: 30),
          _buildSectionTitle('আর্থিক আয় (Income)'),
          _buildTransactionTable(incomeTxs, true),
          _buildTotalRow('মোট আয়', totalIncome),
          pw.SizedBox(height: 30),
          _buildSectionTitle('আর্থিক ব্যয় (Expense)'),
          _buildTransactionTable(expenseTxs, false),
          _buildTotalRow('মোট ব্যয়', totalExpense),
          pw.Divider(thickness: 2),
          _buildTotalRow('সর্বমোট মুনাফা', netProfit, isBold: true),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static Future<void> exportAccountBalances({
    required List<Account> accounts,
    required double totalBalance,
  }) async {
    final pdf = pw.Document();
    final font = await _getFont();
    final date = DateFormat('dd MMM, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => [
          _buildHeader('অ্যাকাউন্ট ব্যালেন্স বিবরণী (Balance Sheet Summary)', date),
          pw.SizedBox(height: 20),
          _buildSectionTitle('সকল অ্যাকাউন্টের স্থিতি'),
          _buildAccountTable(accounts),
          pw.Divider(thickness: 2),
          _buildTotalRow('মোট নিট মূল্য (Net Worth)', totalBalance, isBold: true),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static pw.Widget _buildHeader(String title, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'আমার হিসাব (Amar Hisab)',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.Text(date),
          ],
        ),
        pw.Divider(color: PdfColors.blue900),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryCard(String title, double amount, pw.Font font) {
    final color = amount >= 0 ? PdfColors.green : PdfColors.red;
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text(
            '৳ ${_toBengaliNumber(amount.toStringAsFixed(2))}',
            style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
      ),
    );
  }

  static pw.Widget _buildTransactionTable(List<Transaction> txs, bool isIncome) {
    return pw.TableHelper.fromTextArray(
      headers: ['বিবরণ (Title)', 'পরিমাণ (Amount)'],
      data: txs.map((tx) => [tx.title, '৳ ${_toBengaliNumber(tx.amount.toStringAsFixed(2))}']).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {1: pw.Alignment.centerRight},
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey100))),
    );
  }

  static pw.Widget _buildAccountTable(List<Account> accounts) {
    return pw.TableHelper.fromTextArray(
      headers: ['অ্যাকাউন্ট নাম (Account)', 'ব্যালেন্স (Balance)'],
      data: accounts.map((acc) => [acc.name, '৳ ${_toBengaliNumber(acc.balance.toStringAsFixed(2))}']).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {1: pw.Alignment.centerRight},
    );
  }

  static String _toBengaliNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], bengali[i]);
    }
    return input;
  }

  static pw.Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(
            '৳ ${_toBengaliNumber(amount.toStringAsFixed(2))}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: isBold ? 14 : 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'পৃষ্ঠা ${context.pageNumber} / ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }
}
