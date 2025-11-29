const Map<String, String> beermonopolyStyleList = {
  'Alkoholfritt': 'non-alcoholic',
  'Annet': 'adambier,altbier,brett,burton,tan,chilli,cream ale,festbier,grape ale,'
      'happoshu,historical,honey beer,kellerbier,koji,kvass,lichtenhainer,'
      'malt beer,mild,pumpkin,rauchbier,roggenbier,root beer,rye beer,schwarzbier,'
      'smoked beer,shandy,scotch ale,scottish,steinbier,spiced / herbed,strong ale,table beer,zoigl'
      'kombucha,makgeolli,sorghum',
  'Barleywine': 'barleywine',
  'Belgisk': 'belgian',
  'Blonde': 'blonde, golden',
  'Bokk': 'bock',
  'Brown Ale': 'brown',
  'Dark Ale': 'dark ale',
  'Farmhouse Ale': 'farmhouse ale',
  'Glutenfri': 'gluten-free',
  'Hvete': 'wheat beer',
  'IPA': 'ipa',
  'Juleøl': 'winter',
  'Kölsch': 'kölsch',
  'Lager': 'lager',
  'Mjød': 'mead',
  'Old Ale': 'old / stock, traditional ale',
  'Pale Ale': 'pale ale',
  'Pilsner': 'pilsner',
  'Porter': 'porter',
  'Red Ale': 'red ale -',
  'Sider': 'cider',
  'Stout': 'stout',
  'Surøl': 'sour,wild ale,lambic,fruit beer',
};

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
};

const List<String> cartSortList = [
  'Ingen sortering',
  'Global rating - Høy til lav',
  'Global rating - Lav til høy',
  'Navn - A til Å',
  'Navn - Å til A',
  'Pris - Høy til lav',
  'Pris - Lav til høy',
  'Pris per liter - Høy til lav',
  'Pris per liter - Lav til høy',
];

const Map<String, String> productSelectionAbrevationList = {
  'Basisutvalget': 'Basis',
  'Bestillingsutvalget': 'BU',
  'Partiutvalget': 'Parti',
  'Testutvalget': 'Test',
  'Tilleggsutvalget': 'TU',
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

const List<String> styleChoiceList = [
  'Ølmonopolet',
  'Untappd',
];

const List<String> deliveryList = ['Levering til butikk', 'Levering på posten'];
