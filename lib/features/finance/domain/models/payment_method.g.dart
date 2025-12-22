// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 22;

  @override
  PaymentMethod read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentMethod(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as String,
      colorValue: fields[3] as int,
      limit: fields[4] as double?,
      closingDay: fields[5] as int?,
      dueDay: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.limit)
      ..writeByte(5)
      ..write(obj.closingDay)
      ..writeByte(6)
      ..write(obj.dueDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
