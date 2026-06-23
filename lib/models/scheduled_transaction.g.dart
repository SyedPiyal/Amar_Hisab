// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduledTransactionAdapter extends TypeAdapter<ScheduledTransaction> {
  @override
  final int typeId = 6;

  @override
  ScheduledTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduledTransaction(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      accountId: fields[3] as String,
      type: fields[4] as String,
      category: fields[5] as String,
      frequency: fields[6] as String,
      nextDueDate: fields[7] as DateTime,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduledTransaction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.accountId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.frequency)
      ..writeByte(7)
      ..write(obj.nextDueDate)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
