const Map<String, String> sortList = {
  'Alkohol - Høy til lav': '-abv',
  'Alkohol - Lav til høy': 'abv',
  'Bryggeri - Stigende': 'brewery',
  'Bryggeri - Synkende': '-brewery',
  'Dato lagt til - Nyeste først': '-created_at',
  'Dato lagt til - Eldste først': 'created_at',
  'Global rating - Høy til lav': '-rating',
  'Global rating - Lav til høy': 'rating',
  'Navn - A til Å': 'vmp_name',
  'Navn - Å til A': '-vmp_name',
  'Pris - Høy til lav': '-price',
  'Pris - Lav til høy': 'price',
  'Pris per liter - Høy til lav': '-price_per_volume',
  'Pris per liter - Lav til høy': 'price_per_volume',
  'Pris per alkoholenhet - Høy til lav': '-price_per_alcohol_unit',
  'Pris per alkoholenhet - Lav til høy': 'price_per_alcohol_unit',
};

const Map<String, String> productSelectionAbbreviationList = {
  'Basisutvalget': 'Basis',
  'Bestillingsutvalget': 'BU',
  'Partiutvalget': 'Parti',
  'Testutvalget': 'Test',
  'Tilleggsutvalget': 'TU',
  'Spesialutvalg': 'Spesial',
  'Spesialbestilling': 'Spesial',
};

// Longer abbreviations for release list items
const Map<String, String> productSelectionReleaseAbbreviationList = {
  'Basisutvalget': 'Basis',
  'Bestillingsutvalget': 'Bestilling',
  'Partiutvalget': 'Parti',
  'Testutvalget': 'Test',
  'Tilleggsutvalget': 'Tillegg',
  'Spesialutvalg': 'Spesial',
  'Spesialbestilling': 'Spesial',
};

const Map<String, String> productSelectionDisplayNameList = {
  'Spesialutvalg': 'Spesialutvalget',
};

const List<Map<String, String>> productSelectionList = [
  {'Basisutvalget': 'basisutvalget'},
  {'Bestillingsutvalget': 'bestillingsutvalget'},
  {'Partiutvalget': 'partiutvalget'},
  {'Spesialutvalget': 'spesialutvalg'},
  {'Tilleggsutvalget': 'tilleggsutvalget'},
];

const List<Map<String, String>> excludeAllergensList = [
  {'Gluten': 'gluten, bygg, spelt, hvete, havre, rug'},
  {'Laktose': 'laktose, melk'},
  {'Nøtter': 'nøtter, peanøtt, hasselnøtt, valnøtt, nøtt'},
  {'Sulfitt': 'sulfitt'},
];

const List<String> deliveryList = ['Levering til butikk', 'Levering på posten'];

const List<Map<String, String>> mainCategoryList = [
  {'Øl': 'øl'},
  {'Mjød': 'mjød'},
  {'Sider': 'sider'},
];
