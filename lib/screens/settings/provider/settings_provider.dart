import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/app_settings.dart';

class SettingsProvider with ChangeNotifier {
  late Box<AppSettings> _settingsBox;
  AppSettings? _settings;
  bool _isFirstLaunch = true;

  AppSettings get settings => _settings ?? AppSettings();
  bool get isFirstLaunch => _isFirstLaunch;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    // Initialize SharedPreferences for persistent flags
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // Initialize Hive for other settings
    _settingsBox = await Hive.openBox<AppSettings>('settings');
    if (_settingsBox.isEmpty) {
      _settings = AppSettings();
      await _settingsBox.add(_settings!);
    } else {
      _settings = _settingsBox.getAt(0);
    }
    notifyListeners();
  }

  Future<void> updateSettings({
    String? currency,
    String? language,
    bool? isAdvancedMode,
    bool? isFirstLaunch,
    double? monthlySavingsGoal,
    String? geminiApiKey,
    bool? isCloudBackupEnabled,
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) async {
    if (_settings == null) return;

    if (currency != null) _settings!.currency = currency;
    if (language != null) _settings!.language = language;
    if (isAdvancedMode != null) _settings!.isAdvancedMode = isAdvancedMode;
    
    if (isFirstLaunch != null) {
      _isFirstLaunch = isFirstLaunch;
      _settings!.isFirstLaunch = isFirstLaunch;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', isFirstLaunch);
    }

    if (monthlySavingsGoal != null) _settings!.monthlySavingsGoal = monthlySavingsGoal;
    if (geminiApiKey != null) _settings!.geminiApiKey = geminiApiKey;
    if (isCloudBackupEnabled != null) _settings!.isCloudBackupEnabled = isCloudBackupEnabled;
    if (darkModeEnabled != null) _settings!.darkModeEnabled = darkModeEnabled;
    if (notificationsEnabled != null) _settings!.notificationsEnabled = notificationsEnabled;
    if (biometricEnabled != null) _settings!.biometricEnabled = biometricEnabled;

    await _settings!.save();
    notifyListeners();
  }

  bool get isAdvancedMode => _settings?.isAdvancedMode ?? false;
  String get currency => _settings?.currency ?? 'BDT';
  String get language => _settings?.language ?? 'bn';
  double get monthlySavingsGoal => _settings?.monthlySavingsGoal ?? 0.0;
  String get geminiApiKey => _settings?.geminiApiKey ?? '';
  bool get isCloudBackupEnabled => _settings?.isCloudBackupEnabled ?? false;
  bool get darkModeEnabled => _settings?.darkModeEnabled ?? false;
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get biometricEnabled => _settings?.biometricEnabled ?? false;
}
