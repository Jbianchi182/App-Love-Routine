// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_trip.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingTripAdapter extends TypeAdapter<ShoppingTrip> {
  @override
  final int typeId = 14;

  @override
  ShoppingTrip read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingTrip(
      date: fields[0] as DateTime,
      totalAmount: fields[1] as double,
      items: (fields[2] as List).cast<ShoppingItem>(),
      paymentMethodId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingTrip obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.totalAmount)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.paymentMethodId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingTripAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
