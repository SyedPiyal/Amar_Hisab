// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      currency: fields[0] as String,
      language: fields[1] as String,
      isAdvancedMode: fields[2] as bool,
      isFirstLaunch: fields[3] as bool,
      monthlySavingsGoal: fields[4] as double,
      geminiApiKey: fields[5] as String,
      isCloudBackupEnabled: fields[6] as bool,
      darkModeEnabled: fields[7] as bool,
      notificationsEnabled: fields[8] as bool,
      biometricEnabled: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.isAdvancedMode)
      ..writeByte(3)
      ..write(obj.isFirstLaunch)
      ..writeByte(4)
      ..write(obj.monthlySavingsGoal)
      ..writeByte(5)
      ..write(obj.geminiApiKey)
      ..writeByte(6)
      ..write(obj.isCloudBackupEnabled)
      ..writeByte(7)
      ..write(obj.darkModeEnabled)
      ..writeByte(8)
      ..write(obj.notificationsEnabled)
      ..writeByte(9)
      ..write(obj.biometricEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
