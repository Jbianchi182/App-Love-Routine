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
      ..calories = fields[5] as double?
      ..recurrence = fields[6] as RecurrenceType
      ..customDaysOfWeek = (fields[7] as List?)?.cast<int>()
      ..startDate = fields[8] as DateTime
      ..endDate = fields[9] as DateTime?
      ..time = fields[10] as DateTime
      ..customDaysOfMonth = (fields[11] as List?)?.cast<int>();
  }

  @override
  void write(BinaryWriter writer, DietMeal obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.recurrence)
      ..writeByte(7)
      ..write(obj.customDaysOfWeek)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.time)
      ..writeByte(11)
      ..write(obj.customDaysOfMonth);
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
