import 'dart:io';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

class PrinterHelper {
  // Singleton
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isBluetoothConnected = false;
  bool _isWifiConnected = false;
  Socket? _socket;

  bool get isConnected => _isBluetoothConnected || _isWifiConnected;

  Future<bool> checkPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<BluetoothInfo>> getBondedDevices() async {
    try {
      final List<BluetoothInfo> list =
          await PrintBluetoothThermal.pairedBluetooths;
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<bool> connectBluetooth(String macAddress) async {
    try {
      await disconnect(); // Disconnect existing
      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isBluetoothConnected = result;
      return result;
    } catch (e) {
      _isBluetoothConnected = false;
      return false;
    }
  }

  Future<bool> connectWifi(String ipAddress, {int port = 9100}) async {
    try {
      await disconnect(); // Disconnect existing
      _socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5));
      _isWifiConnected = true;
      return true;
    } catch (e) {
      _isWifiConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      if (_isBluetoothConnected) {
        await PrintBluetoothThermal.disconnect;
        _isBluetoothConnected = false;
      }
      if (_isWifiConnected) {
        _socket?.destroy();
        _socket = null;
        _isWifiConnected = false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _writeBytes(List<int> bytes) async {
    if (_isBluetoothConnected) {
      await PrintBluetoothThermal.writeBytes(bytes);
    } else if (_isWifiConnected && _socket != null) {
      _socket!.add(bytes);
      await _socket!.flush();
    }
  }

  Future<void> printText(String text) async {
    if (!isConnected) return;
    await _writeBytes(_textToBytes(text));
  }

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    required String footer,
  }) async {
    final pdf = pw.Document();

    // Load Bangla fonts using PdfGoogleFonts from printing package
    final font = await PdfGoogleFonts.hindSiliguriRegular();
    final boldFont = await PdfGoogleFonts.hindSiliguriBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(shopName, style: pw.TextStyle(font: boldFont, fontSize: 16)),
              if (address1.isNotEmpty) pw.Text(address1, style: pw.TextStyle(font: font, fontSize: 9)),
              if (address2.isNotEmpty) pw.Text(address2, style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Phone: $phone', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.SizedBox(height: 5),
              pw.Text(
                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(font: font, fontSize: 9),
              ),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.Text('RETAIL INVOICE', style: pw.TextStyle(font: boldFont, fontSize: 11)),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(15),
                  1: const pw.FlexColumnWidth(),
                  2: const pw.FixedColumnWidth(35),
                  3: const pw.FixedColumnWidth(25),
                  4: const pw.FixedColumnWidth(35),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('No', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                      pw.Text('Description', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                      pw.Text('Price', style: pw.TextStyle(font: boldFont, fontSize: 8), textAlign: pw.TextAlign.right),
                      pw.Text('Qty', style: pw.TextStyle(font: boldFont, fontSize: 8), textAlign: pw.TextAlign.right),
                      pw.Text('Total', style: pw.TextStyle(font: boldFont, fontSize: 8), textAlign: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(children: [pw.SizedBox(height: 2), pw.SizedBox(), pw.SizedBox(), pw.SizedBox(), pw.SizedBox()]),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Text('$index', style: pw.TextStyle(font: font, fontSize: 8)),
                        pw.Text(item['name'], style: pw.TextStyle(font: font, fontSize: 8)),
                        pw.Text(item['price'].toStringAsFixed(2), style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.right),
                        pw.Text(item['qty'].toString(), style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.right),
                        pw.Text(item['total'].toStringAsFixed(2), style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.right),
                      ],
                    );
                  }),
                ],
              ),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:', style: pw.TextStyle(font: boldFont, fontSize: 11)),
                  pw.Text('৳${total.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 11)),
                ],
              ),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),
              pw.Text(footer, style: pw.TextStyle(font: font, fontSize: 9), textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  List<int> _textToBytes(String text) {
    return List.from(text.codeUnits);
  }
}
