// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentCardAdapter extends TypeAdapter<PaymentCard> {
  @override
  final int typeId = 15;

  @override
  PaymentCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentCard(
      lastFourDigits: fields[0] as String,
      brand: fields[1] as String,
      isCredit: fields[2] as bool,
      nickname: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentCard obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.lastFourDigits)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.isCredit)
      ..writeByte(3)
      ..write(obj.nickname);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
