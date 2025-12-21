// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DietTagAdapter extends TypeAdapter<DietTag> {
  @override
  final int typeId = 9;

  @override
  DietTag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DietTag.carbs;
      case 1:
        return DietTag.protein;
      case 2:
        return DietTag.fats;
      case 3:
        return DietTag.vegetables;
      case 4:
        return DietTag.fruits;
      case 5:
        return DietTag.dairy;
      default:
        return DietTag.carbs;
    }
  }

  @override
  void write(BinaryWriter writer, DietTag obj) {
    switch (obj) {
      case DietTag.carbs:
        writer.writeByte(0);
        break;
      case DietTag.protein:
        writer.writeByte(1);
        break;
      case DietTag.fats:
        writer.writeByte(2);
        break;
      case DietTag.vegetables:
        writer.writeByte(3);
        break;
      case DietTag.fruits:
        writer.writeByte(4);
        break;
      case DietTag.dairy:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DietTagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
