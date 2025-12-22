class CardStyles {
  // Key -> Asset Path (assuming png/jpg in assets/images/cards/)
  // User should rename their files to match these or we update this map
  static const Map<String, String> styles = {
    'default': 'assets/images/cards/estrelas 01.jpg',
    'coffee': 'assets/images/cards/cafe 01.jpg',
    'gym': 'assets/images/cards/abacate 01.jpg',
    'shopping': 'assets/images/cards/morango 01.jpg',
    'work': 'assets/images/cards/cafe 02.jpg',
    'nature': 'assets/images/cards/pessego 01.jpg',
    'abstract': 'assets/images/cards/estrelas 01.jpg',
  };

  static String getAsset(String? key) {
    if (key == null || !styles.containsKey(key)) {
      return styles['default']!;
    }
    return styles[key]!;
  }
}
