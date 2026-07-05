import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isFirstCheck = true;
  
  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _connectionStatusController.stream;

  void initialize() {
    // Check initial status
    _connectivity.checkConnectivity().then(_updateStatus);

    // Listen to changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // connectivity_plus 6.0.0+ returns a List<ConnectivityResult>
    bool hasConnection = results.any((result) => result != ConnectivityResult.none);
    
    _connectionStatusController.add(hasConnection);

    if (_isFirstCheck) {
      _isFirstCheck = false;
      _showToast(hasConnection ? "Internet is available" : "No internet available", hasConnection);
      return;
    }

    if (hasConnection) {
      _showToast("Internet is available", true);
    } else {
      _showToast("No internet available", false);
    }
  }

  void _showToast(String message, bool isSuccess) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void dispose() {
    _subscription?.cancel();
    _connectionStatusController.close();
  }
}
