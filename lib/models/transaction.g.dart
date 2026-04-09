// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 1;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      accountId: fields[4] as String,
      type: fields[5] as String,
      category: fields[6] as String,
      creditAccountId: fields[7] as String?,
      debitAccountId: fields[8] as String?,
      isSplit: fields[9] as bool,
      splitDetails: (fields[10] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.accountId)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.creditAccountId)
      ..writeByte(8)
      ..write(obj.debitAccountId)
      ..writeByte(9)
      ..write(obj.isSplit)
      ..writeByte(10)
      ..write(obj.splitDetails);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
