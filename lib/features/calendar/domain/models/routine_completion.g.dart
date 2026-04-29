// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_completion.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineCompletionAdapter extends TypeAdapter<RoutineCompletion> {
  @override
  final int typeId = 16;

  @override
  RoutineCompletion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoutineCompletion(
      date: fields[0] as DateTime,
      routineId: fields[1] as String,
      routineTitle: fields[2] as String,
      isCompleted: fields[3] as bool,
      scheduledTime: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RoutineCompletion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.routineId)
      ..writeByte(2)
      ..write(obj.routineTitle)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.scheduledTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineCompletionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
