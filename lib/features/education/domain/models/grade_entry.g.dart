// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeEntryAdapter extends TypeAdapter<GradeEntry> {
  @override
  final int typeId = 6;

  @override
  GradeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradeEntry()
      ..id = fields[0] as int?
      ..name = fields[1] as String
      ..score = fields[2] as double
      ..weight = fields[3] as double?
      ..date = fields[4] as DateTime
      ..subjectId = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, GradeEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.subjectId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
