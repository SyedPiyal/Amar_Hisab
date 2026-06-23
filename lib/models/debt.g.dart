// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 4;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      id: fields[0] as String,
      personName: fields[1] as String,
      amount: fields[2] as double,
      remainingAmount: fields[3] as double,
      type: fields[4] as String,
      date: fields[5] as DateTime,
      dueDate: fields[6] as DateTime?,
      note: fields[7] as String?,
      accountId: fields[8] as String?,
      status: fields[9] as String,
      phoneNumber: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.remainingAmount)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.dueDate)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.accountId)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.phoneNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
