class CardStyles {
  // Key -> Asset Path (assuming png/jpg in assets/images/cards/)
  // User should rename their files to match these or we update this map
  static const Map<String, String> styles = {
    'default': 'assets/images/cards/estrelas.jpg',
    'abacate': 'assets/images/cards/abacate.jpg',
    'abacate_02': 'assets/images/cards/abacate 02.jpg',
    'aventura': 'assets/images/cards/aventura.jpg',
    'burger': 'assets/images/cards/burger.jpg',
    'cafe': 'assets/images/cards/cafe.jpg',
    'cafe_03': 'assets/images/cards/cafe 03.jpg',
    'cafe_04': 'assets/images/cards/cafe 04.jpg',
    'cafe_05': 'assets/images/cards/cafe 05.jpg',
    'calendario': 'assets/images/cards/calendario.jpg',
    'casa': 'assets/images/cards/casa.jpg',
    'cozinha': 'assets/images/cards/cozinha.jpg',
    'dinheiro': 'assets/images/cards/dinheiro.jpg',
    'estrelas': 'assets/images/cards/estrelas.jpg',
    'festas': 'assets/images/cards/festas.jpg',
    'festas_02': 'assets/images/cards/festas 02.jpg',
    'flores': 'assets/images/cards/flores.jpg',
    'flores_02': 'assets/images/cards/flores 02.jpg',
    'hobbies': 'assets/images/cards/hobbies.jpg',
    'kawaii': 'assets/images/cards/kawaii.jpg',
    'lanches': 'assets/images/cards/lanches.jpg',
    'laranja': 'assets/images/cards/laranja.jpg',
    'lazer': 'assets/images/cards/lazer.jpg',
    'leite': 'assets/images/cards/leite.jpg',
    'limpeza': 'assets/images/cards/limpeza.jpg',
    'morango': 'assets/images/cards/morango.jpg',
    'morango_02': 'assets/images/cards/morango 02.jpg',
    'morango_03': 'assets/images/cards/morango 03.jpg',
    'paes': 'assets/images/cards/paes.jpg',
    'peixes': 'assets/images/cards/peixes.jpg',
    'pessego': 'assets/images/cards/pessego.jpg',
    'pessego_02': 'assets/images/cards/pessego 02.jpg',
    'sobremesa': 'assets/images/cards/sobremesa.jpg',
    'sushi': 'assets/images/cards/sushi.jpg',
    'tacos': 'assets/images/cards/tacos.jpg',
    'tecnologia': 'assets/images/cards/tecnologia.jpg',
    'viagem': 'assets/images/cards/viagem.jpg',
  };

  static String getAsset(String? key) {
    if (key == null || !styles.containsKey(key)) {
      return styles['default']!;
    }
    return styles[key]!;
  }
}
