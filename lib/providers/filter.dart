import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store.dart';
import '../helpers/api_helper.dart';
import '../helpers/location_helper.dart';

class Filter with ChangeNotifier {
  String search = '';
  String storeId = '';
  String style = '';
  String productSelection = '';
  String priceHigh = '';
  String priceLow = '';
  String sortBy = '-rating';
  int checkIn = 0;

  List<String> selectedStores = [];
  List<Store> storeList = [];

  RangeValues priceRange = const RangeValues(0, 500);

  String sortIndex = 'Global rating - Høy til lav';
  Map<String, String> sortList = {
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
  Map<String, String> sortListAuth = {
    'Alkohol - Høy til lav': '-abv',
    'Alkohol - Lav til høy': 'abv',
    'Bryggeri - Stigende': 'brewery',
    'Bryggeri - Synkende': '-brewery',
    'Dato lagt til - Nyeste først': '-created_at',
    'Dato lagt til - Eldste først': 'created_at',
    'Din rating - Høy til lav': '-checkin__rating',
    'Din rating - Lav til høy': 'checkin__rating',
    'Global rating - Høy til lav': '-rating',
    'Global rating - Lav til høy': 'rating',
    'Navn - A til Å': 'vmp_name',
    'Navn - Å til A': '-vmp_name',
    'Pris - Høy til lav': '-price',
    'Pris - Lav til høy': 'price',
    'Pris per liter - Høy til lav': '-price_per_volume',
    'Pris per liter - Lav til høy': 'price_per_volume',
  };

  List<bool> styleSelectedList = List<bool>.filled(23, false);
  List<Map<String, String>> styleList = [
    {
      'Annet': 'adambier,altbier,brett,burton,tan,chilli,cream ale,festbier,grape ale,'
          'happoshu,historical,honey beer,kellerbier,koji,kvass,lichtenhainer,'
          'malt beer,mild,pumpkin,rauchbier,roggenbier,root beer,rye beer,schwarzbier,'
          'smoked beer,shandy,scotch ale,scottish,steinbier,spiced / herbed,strong ale,table beer,zoigl'
    },
    {'Barleywine': 'barleywine'},
    {'Belgisk': 'belgian'},
    {'Blonde': 'blonde'},
    {'Bokk': 'bock'},
    {'Brown Ale': 'brown'},
    {'Dark Ale': 'dark ale'},
    {'Farmhouse Ale': 'farmhouse ale'},
    {'Glutenfri': 'gluten-free'},
    {'Hvete': 'wheat beer'},
    {'IPA': 'ipa'},
    {'Juleøl': 'winter'},
    {'Kölsch': 'kölsch'},
    {'Lager': 'lager'},
    {'Mjød': 'mead'},
    {'Old Ale': 'old ale, traditional ale'},
    {'Pale Ale': 'pale ale'},
    {'Pilsner': 'pilsner'},
    {'Porter': 'porter'},
    {'Red Ale': 'red ale -'},
    {'Sider': 'cider'},
    {'Stout': 'stout'},
    {'Surøl': 'sour,wild ale,lambic,fruit beer'},
  ];

  List<bool> productSelectionSelectedList = List<bool>.filled(5, false);
  List<Map<String, String>> productSelectionList = [
    {'Basisutvalget': 'basisutvalget'},
    {'Bestillingsutvalget': 'bestillingsutvalget'},
    {'Partiutvalget': 'partiutvalget'},
    {'Spesialutvalget': 'spesialutvalg'},
    {'Tilleggsutvalget': 'tilleggsutvalget'},
  ];

  List<String> checkinList = [
    'Alle Produkt',
    'Innsjekket',
    'Ikke innsjekket',
  ];

  Filter get filters {
    return this;
  }

  bool storesLoading = false;
  Future<List<Store>> getStores() async {
    if (storeList.isNotEmpty && storeList.length > 1 && !storesLoading) {
      return storeList;
    }
    try {
      storesLoading = true;
      var stores = await ApiHelper.getStoreList();
      storeList = stores;
      storeList = await LocationHelper.calculateStoreDistance(storeList);
      storeList.sort((a, b) => a.distance!.compareTo(b.distance!));
      storesLoading = false;
      notifyListeners();
      return storeList;
    } catch (error) {
      storesLoading = false;
      notifyListeners();
      return storeList;
    }
  }

  void setPriceRange(RangeValues range) {
    priceRange = range;
    if (priceRange.end == 500) {
      priceHigh = '';
      priceLow = priceRange.start.toString();
    } else {
      priceHigh = priceRange.end.toString();
      priceLow = priceRange.start.toString();
    }
    notifyListeners();
  }

  void setSortBy(String index) {
    sortIndex = index;
    sortBy = sortListAuth[index]!;
    notifyListeners();
  }

  void setStyle(int index, bool boolean) {
    styleSelectedList[index] = boolean;
    var temporaryStyle = '';
    styleSelectedList.asMap().forEach(
      (index, value) {
        if (value) {
          if (temporaryStyle.isNotEmpty) {
            temporaryStyle += ',';
          }
          temporaryStyle += styleList[index].values.first;
        }
      },
    );
    style = temporaryStyle;
    notifyListeners();
  }

  void setProductSelection(int index, bool boolean) {
    productSelectionSelectedList[index] = boolean;
    var temporaryProductSelection = '';
    productSelectionSelectedList.asMap().forEach(
      (index, value) {
        if (value) {
          if (temporaryProductSelection.isNotEmpty) {
            temporaryProductSelection += ',';
          }
          temporaryProductSelection += productSelectionList[index].values.first;
        }
      },
    );
    productSelection = temporaryProductSelection;
    notifyListeners();
  }

  void setCheckin(int index) {
    checkIn = index;
    notifyListeners();
  }

  void setSearch(String text) {
    search = text;
    notifyListeners();
  }

  void setStore() {
    if (selectedStores.isEmpty) {
      storeId = '';
    } else {
      String temporaryStores = '';
      selectedStores.forEach((storeName) {
        if (temporaryStores.isNotEmpty) {
          temporaryStores += ',';
        }
        temporaryStores +=
            storeList.firstWhere((element) => element.name == storeName).id;
      });
      storeId = temporaryStores;
    }
    notifyListeners();
    saveLastStore();
  }

  void saveLastStore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('storeId', storeId);
    prefs.setStringList('selectedStores', selectedStores);
  }

  Future<void> loadLastStore() async {
    final prefs = await SharedPreferences.getInstance();
    storeId = prefs.getString('storeId') ?? '';
    selectedStores = prefs.getStringList('selectedStores') ?? [];
    notifyListeners();
  }

  void resetFilters() {
    styleSelectedList = List<bool>.filled(23, false);
    productSelectionSelectedList = List<bool>.filled(5, false);
    priceRange = const RangeValues(0, 500);
    sortIndex = 'Global rating - Høy til lav';
    storeId = '';
    selectedStores = [];
    style = '';
    productSelection = '';
    priceHigh = '';
    priceLow = '';
    sortBy = '-rating';
    checkIn = 0;
    notifyListeners();
    saveLastStore();
  }
}
