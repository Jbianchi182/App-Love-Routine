import 'package:hive/hive.dart';

part 'diet_tag.g.dart';

@HiveType(typeId: 9)
enum DietTag {
  @HiveField(0)
  carbs,
  @HiveField(1)
  protein,
  @HiveField(2)
  fats,
  @HiveField(3)
  vegetables,
  @HiveField(4)
  fruits,
  @HiveField(5)
  dairy;

  String get label {
    switch (this) {
      case DietTag.carbs:
        return 'Carboidratos';
      case DietTag.protein:
        return 'Proteínas';
      case DietTag.fats:
        return 'Gorduras';
      case DietTag.vegetables:
        return 'Vegetais';
      case DietTag.fruits:
        return 'Frutas';
      case DietTag.dairy:
        return 'Laticínios';
    }
  }
}
