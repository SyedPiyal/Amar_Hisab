import 'package:flutter/foundation.dart';
import '../../services/billing/printer_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

enum PrinterStatus {
  initial,
  scanning,
  scanSuccess,
  scanFailure,
  connecting,
  connected,
  connectionFailure,
  disconnected,
  testPrinting,
}

class PrinterProvider with ChangeNotifier {
  PrinterStatus _status = PrinterStatus.initial;
  String? _connectedMac;
  String? _connectedName;
  String? _errorMessage;
  List<BluetoothInfo> _devices = [];

  PrinterStatus get status => _status;
  String? get connectedMac => _connectedMac;
  String? get connectedName => _connectedName;
  String? get errorMessage => _errorMessage;
  List<BluetoothInfo> get devices => _devices;

  final PrinterHelper _printerHelper = PrinterHelper();

  PrinterProvider() {
    init();
  }

  void init() {
    final mac = Hive.box('settings').get('printer_mac');
    final name = Hive.box('settings').get('printer_name');
    _status = PrinterStatus.initial;
    _connectedMac = mac;
    _connectedName = name;
    notifyListeners();
  }

  Future<void> scanPrinters() async {
    _status = PrinterStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    try {
      final devices = await _printerHelper.getBondedDevices();
      _devices = devices;
      _status = PrinterStatus.scanSuccess;
      notifyListeners();
    } catch (e) {
      _status = PrinterStatus.scanFailure;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> connectPrinter(String mac, String name) async {
    _status = PrinterStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    final success = await _printerHelper.connect(mac);
    if (success) {
      await Hive.box('settings').put('printer_mac', mac);
      await Hive.box('settings').put('printer_name', name);
      _status = PrinterStatus.connected;
      _connectedMac = mac;
      _connectedName = name;
    } else {
      _status = PrinterStatus.connectionFailure;
      _errorMessage = 'Failed to connect to printer';
    }
    notifyListeners();
  }

  Future<void> disconnectPrinter() async {
    await _printerHelper.disconnect();
    await Hive.box('settings').delete('printer_mac');
    await Hive.box('settings').delete('printer_name');
    _status = PrinterStatus.disconnected;
    _connectedMac = null;
    _connectedName = null;
    notifyListeners();
  }

  Future<void> testPrint(String shopName) async {
    _status = PrinterStatus.testPrinting;
    notifyListeners();
    
    await _printerHelper.printText('Test Print from $shopName\n\n\n');
    
    _status = PrinterStatus.scanSuccess;
    notifyListeners();
  }
}
