// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grading_scheme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradingSchemeAdapter extends TypeAdapter<GradingScheme> {
  @override
  final int typeId = 20;

  @override
  GradingScheme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GradingScheme()
      ..name = fields[0] as String
      ..formula = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, GradingScheme obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.formula);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradingSchemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
