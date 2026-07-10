import 'package:flutter/foundation.dart';
import '../../services/billing/printer_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:ping_discover_network_plus/ping_discover_network_plus.dart';

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
  permissionDenied,
}

enum ConnectionType { bluetooth, wifi }

class PrinterProvider with ChangeNotifier {
  PrinterStatus _status = PrinterStatus.initial;
  String? _connectedMac;
  String? _connectedIp;
  String? _connectedName;
  ConnectionType? _connectionType;
  String? _errorMessage;
  List<BluetoothInfo> _devices = [];
  List<String> _wifiDevices = [];
  bool _isWifiScanning = false;

  PrinterStatus get status => _status;
  String? get connectedMac => _connectedMac;
  String? get connectedIp => _connectedIp;
  String? get connectedName => _connectedName;
  ConnectionType? get connectionType => _connectionType;
  String? get errorMessage => _errorMessage;
  List<BluetoothInfo> get devices => _devices;
  List<String> get wifiDevices => _wifiDevices;
  bool get isWifiScanning => _isWifiScanning;

  final PrinterHelper _printerHelper = PrinterHelper();

  PrinterProvider() {
    init();
  }

  void init() {
    final settings = Hive.box('settings');
    final type = settings.get('printer_type');
    
    _connectedMac = settings.get('printer_mac');
    _connectedIp = settings.get('printer_ip');
    _connectedName = settings.get('printer_name');
    
    if (type == 'bluetooth') {
      _connectionType = ConnectionType.bluetooth;
    } else if (type == 'wifi') {
      _connectionType = ConnectionType.wifi;
    }
    
    _status = PrinterStatus.initial;
    notifyListeners();
  }

  Future<void> scanPrinters() async {
    _status = PrinterStatus.scanning;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasPermission = await _printerHelper.checkPermission();
      if (!hasPermission) {
        _status = PrinterStatus.permissionDenied;
        _errorMessage = 'Bluetooth permissions are required to scan for printers.';
        notifyListeners();
        return;
      }

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

  // Future<void> scanWifiPrinters() async {
  //   if (_isWifiScanning) return;
  //
  //   _isWifiScanning = true;
  //   _wifiDevices = [];
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     final info = NetworkInfo();
  //     final wifiIP = await info.getWifiIP();
  //
  //     if (wifiIP != null) {
  //       final String subnet = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
  //       final stream = NetworkAnalyzer.i.discover2(subnet, 9100, timeout: const Duration(milliseconds: 2000));
  //
  //       stream.listen((NetworkAddress addr) {
  //         if (addr.exists) {
  //           _wifiDevices.add(addr.ip);
  //           notifyListeners();
  //         }
  //       }).onDone(() {
  //         _isWifiScanning = false;
  //         notifyListeners();
  //       });
  //     } else {
  //       _isWifiScanning = false;
  //       _errorMessage = 'Could not determine Wi-Fi IP. Ensure Wi-Fi is connected.';
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     _isWifiScanning = false;
  //     _errorMessage = e.toString();
  //     notifyListeners();
  //   }
  // }

  Future<void> connectBluetoothPrinter(String mac, String name) async {
    _status = PrinterStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    final success = await _printerHelper.connectBluetooth(mac);
    if (success) {
      final settings = Hive.box('settings');
      await settings.put('printer_type', 'bluetooth');
      await settings.put('printer_mac', mac);
      await settings.put('printer_name', name);
      await settings.delete('printer_ip');
      
      _connectionType = ConnectionType.bluetooth;
      _connectedMac = mac;
      _connectedName = name;
      _connectedIp = null;
      _status = PrinterStatus.connected;
    } else {
      _status = PrinterStatus.connectionFailure;
      _errorMessage = 'Failed to connect to Bluetooth printer';
    }
    notifyListeners();
  }

  Future<void> connectWifiPrinter(String ip, {String name = 'WiFi Printer', int port = 9100}) async {
    _status = PrinterStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    final success = await _printerHelper.connectWifi(ip, port: port);
    if (success) {
      final settings = Hive.box('settings');
      await settings.put('printer_type', 'wifi');
      await settings.put('printer_ip', ip);
      await settings.put('printer_name', name);
      await settings.delete('printer_mac');
      
      _connectionType = ConnectionType.wifi;
      _connectedIp = ip;
      _connectedName = name;
      _connectedMac = null;
      _status = PrinterStatus.connected;
    } else {
      _status = PrinterStatus.connectionFailure;
      _errorMessage = 'Failed to connect to WiFi printer at $ip';
    }
    notifyListeners();
  }

  Future<void> disconnectPrinter() async {
    await _printerHelper.disconnect();
    final settings = Hive.box('settings');
    await settings.delete('printer_type');
    await settings.delete('printer_mac');
    await settings.delete('printer_ip');
    await settings.delete('printer_name');
    
    _status = PrinterStatus.disconnected;
    _connectedMac = null;
    _connectedIp = null;
    _connectedName = null;
    _connectionType = null;
    notifyListeners();
  }

  Future<void> testPrint(String shopName) async {
    _status = PrinterStatus.testPrinting;
    notifyListeners();
    
    await _printerHelper.printText('Test Print from $shopName\n\n\n');
    
    _status = PrinterStatus.connected; // Back to connected state
    notifyListeners();
  }
}
