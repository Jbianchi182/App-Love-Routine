// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineAdapter extends TypeAdapter<Routine> {
  @override
  final int typeId = 0;

  @override
  Routine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Routine()
      ..id = fields[0] as int?
      ..title = fields[1] as String
      ..description = fields[2] as String?
      ..startDate = fields[3] as DateTime
      ..endDate = fields[4] as DateTime?
      ..time = fields[5] as DateTime
      ..recurrence = fields[6] as RecurrenceType
      ..customDaysOfWeek = (fields[7] as List?)?.cast<int>()
      ..interval = fields[8] as int?
      ..status = fields[9] as RoutineStatus
      ..history = (fields[10] as List).cast<RoutineHistoryEntry>()
      ..cardStyle = fields[11] as String?;
  }

  @override
  void write(BinaryWriter writer, Routine obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.time)
      ..writeByte(6)
      ..write(obj.recurrence)
      ..writeByte(7)
      ..write(obj.customDaysOfWeek)
      ..writeByte(8)
      ..write(obj.interval)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.history)
      ..writeByte(11)
      ..write(obj.cardStyle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RoutineHistoryEntryAdapter extends TypeAdapter<RoutineHistoryEntry> {
  @override
  final int typeId = 1;

  @override
  RoutineHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineHistoryEntry()
      ..timestamp = fields[0] as DateTime
      ..details = fields[1] as String
      ..previousStatus = fields[2] as RoutineStatus?
      ..newStatus = fields[3] as RoutineStatus?;
  }

  @override
  void write(BinaryWriter writer, RoutineHistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.details)
      ..writeByte(2)
      ..write(obj.previousStatus)
      ..writeByte(3)
      ..write(obj.newStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
