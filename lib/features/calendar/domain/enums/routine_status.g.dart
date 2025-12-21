// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoutineStatusAdapter extends TypeAdapter<RoutineStatus> {
  @override
  final int typeId = 7;

  @override
  RoutineStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RoutineStatus.pending;
      case 1:
        return RoutineStatus.completedOnTime;
      case 2:
        return RoutineStatus.completedLate;
      case 3:
        return RoutineStatus.notCompleted;
      case 4:
        return RoutineStatus.canceled;
      default:
        return RoutineStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, RoutineStatus obj) {
    switch (obj) {
      case RoutineStatus.pending:
        writer.writeByte(0);
        break;
      case RoutineStatus.completedOnTime:
        writer.writeByte(1);
        break;
      case RoutineStatus.completedLate:
        writer.writeByte(2);
        break;
      case RoutineStatus.notCompleted:
        writer.writeByte(3);
        break;
      case RoutineStatus.canceled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
