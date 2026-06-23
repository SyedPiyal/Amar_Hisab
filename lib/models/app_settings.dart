import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  String currency;

  @HiveField(1)
  String language;

  @HiveField(2)
  bool isAdvancedMode;

  @HiveField(3)
  bool isFirstLaunch;

  @HiveField(4)
  double monthlySavingsGoal;

  @HiveField(5)
  String geminiApiKey;

  @HiveField(6)
  bool isCloudBackupEnabled;

  @HiveField(7)
  bool darkModeEnabled;

  @HiveField(8)
  bool notificationsEnabled;

  @HiveField(9)
  bool biometricEnabled;

  AppSettings({
    this.currency = 'BDT',
    this.language = 'bn',
    this.isAdvancedMode = false,
    this.isFirstLaunch = true,
    this.monthlySavingsGoal = 20000.0,
    this.geminiApiKey = '',
    this.isCloudBackupEnabled = false,
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
    this.biometricEnabled = false,
  });
}
