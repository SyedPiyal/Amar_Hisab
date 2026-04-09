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

  AppSettings({
    this.currency = 'BDT',
    this.language = 'bn',
    this.isAdvancedMode = false,
    this.isFirstLaunch = true,
  });
}
