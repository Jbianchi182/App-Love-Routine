// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinanceTransactionAdapter extends TypeAdapter<FinanceTransaction> {
  @override
  final int typeId = 12;

  @override
  FinanceTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinanceTransaction()
      ..id = fields[0] as int?
      ..title = fields[1] as String
      ..amount = fields[2] as double
      ..date = fields[3] as DateTime
      ..type = fields[4] as TransactionType
      ..category = fields[5] as TransactionCategory;
  }

  @override
  void write(BinaryWriter writer, FinanceTransaction obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
