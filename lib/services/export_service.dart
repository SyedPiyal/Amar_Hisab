import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';

class ExportService {
  static Future<String> exportTransactionsToCsv(List<Transaction> transactions) async {
    String csvData = 'ID,Date,Title,Amount,Type,Category,AccountId,CreditAccountId,DebitAccountId\n';
    
    for (var tx in transactions) {
      csvData += '${tx.id},${tx.date},${tx.title},${tx.amount},${tx.type},${tx.category},${tx.accountId},${tx.creditAccountId ?? ""},${tx.debitAccountId ?? ""}\n';
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    
    await file.writeAsString(csvData);
    return path;
  }
}
