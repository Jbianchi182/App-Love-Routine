// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_meal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DietMealAdapter extends TypeAdapter<DietMeal> {
  @override
  final int typeId = 2;

  @override
  DietMeal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DietMeal()
      ..id = fields[0] as int?
      ..name = fields[1] as String
      ..description = fields[2] as String?
      ..foodItems = (fields[3] as List).cast<String>()
      ..tags = (fields[4] as List).cast<DietTag>()
      ..calories = fields[5] as double?;
  }

  @override
  void write(BinaryWriter writer, DietMeal obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.foodItems)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.calories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietMealAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
