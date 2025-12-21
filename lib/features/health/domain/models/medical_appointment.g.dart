// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_appointment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalAppointmentAdapter extends TypeAdapter<MedicalAppointment> {
  @override
  final int typeId = 3;

  @override
  MedicalAppointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalAppointment()
      ..id = fields[0] as int?
      ..title = fields[1] as String
      ..description = fields[2] as String?
      ..patientName = fields[3] as String
      ..location = fields[4] as String?
      ..date = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, MedicalAppointment obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.patientName)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalAppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
