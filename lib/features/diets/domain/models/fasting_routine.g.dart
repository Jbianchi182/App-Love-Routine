// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_routine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FastingRoutineAdapter extends TypeAdapter<FastingRoutine> {
  @override
  final int typeId = 23;

  @override
  FastingRoutine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FastingRoutine()
      ..id = fields[0] as int?
      ..name = fields[1] as String
      ..fastingHours = fields[2] as int
      ..startTime = fields[3] as DateTime
      ..isActive = fields[4] as bool
      ..recurrence = fields[5] as RecurrenceType
      ..customDaysOfWeek = (fields[6] as List?)?.cast<int>()
      ..customDaysOfMonth = (fields[7] as List?)?.cast<int>()
      ..startDate = fields[8] as DateTime;
  }

  @override
  void write(BinaryWriter writer, FastingRoutine obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fastingHours)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.recurrence)
      ..writeByte(6)
      ..write(obj.customDaysOfWeek)
      ..writeByte(7)
      ..write(obj.customDaysOfMonth)
      ..writeByte(8)
      ..write(obj.startDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingRoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
