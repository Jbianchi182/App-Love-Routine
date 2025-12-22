// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HomePreferencesAdapter extends TypeAdapter<HomePreferences> {
  @override
  final int typeId = 21;

  @override
  HomePreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HomePreferences()
      ..sectionOrder = (fields[0] as List).cast<String>()
      ..upcomingDaysRange = fields[1] as int
      ..pinnedModules = (fields[2] as List).cast<String>()
      ..isGridView = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, HomePreferences obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sectionOrder)
      ..writeByte(1)
      ..write(obj.upcomingDaysRange)
      ..writeByte(2)
      ..write(obj.pinnedModules)
      ..writeByte(3)
      ..write(obj.isGridView);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomePreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
