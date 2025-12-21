enum DietTag {
  carbs,
  protein,
  fats,
  vegetables,
  fruits,
  dairy;

  String get label {
    switch (this) {
      case DietTag.carbs: return 'Carboidratos';
      case DietTag.protein: return 'Proteínas';
      case DietTag.fats: return 'Gorduras';
      case DietTag.vegetables: return 'Vegetais';
      case DietTag.fruits: return 'Frutas';
      case DietTag.dairy: return 'Laticínios';
    }
  }
}
