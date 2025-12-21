// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionCategoryAdapter extends TypeAdapter<TransactionCategory> {
  @override
  final int typeId = 11;

  @override
  TransactionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategory.salary;
      case 1:
        return TransactionCategory.food;
      case 2:
        return TransactionCategory.transport;
      case 3:
        return TransactionCategory.health;
      case 4:
        return TransactionCategory.entertainment;
      case 5:
        return TransactionCategory.education;
      case 6:
        return TransactionCategory.others;
      case 7:
        return TransactionCategory.housing;
      case 8:
        return TransactionCategory.bills;
      default:
        return TransactionCategory.salary;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategory obj) {
    switch (obj) {
      case TransactionCategory.salary:
        writer.writeByte(0);
        break;
      case TransactionCategory.food:
        writer.writeByte(1);
        break;
      case TransactionCategory.transport:
        writer.writeByte(2);
        break;
      case TransactionCategory.health:
        writer.writeByte(3);
        break;
      case TransactionCategory.entertainment:
        writer.writeByte(4);
        break;
      case TransactionCategory.education:
        writer.writeByte(5);
        break;
      case TransactionCategory.others:
        writer.writeByte(6);
        break;
      case TransactionCategory.housing:
        writer.writeByte(7);
        break;
      case TransactionCategory.bills:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
