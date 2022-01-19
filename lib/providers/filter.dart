import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/store.dart';
import '../helpers/api_helper.dart';
import '../helpers/location_helper.dart';

class Filter with ChangeNotifier {
  String search = '';
  String storeId = '';
  String storeName = 'Alle Butikker';
  String style = '';
  String priceHigh = '';
  String priceLow = '';
  String sortBy = '-rating';

  Store allStores = Store(id: '', name: 'Alle Butikker');
  List<Store> storeList = [];

  RangeValues priceRange = const RangeValues(0, 500);

  String sortIndex = 'Rating - Høy til lav';
  Map<String, String> sortList = {
    'Alkohol - Høy til lav': '-abv',
    'Alkohol - Lav til høy': 'abv',
    'Bryggeri - Stigende': 'brewery',
    'Bryggeri - Synkende': '-brewery',
    'Dato lagt til - Nyeste først': '-created_at',
    'Dato lagt til - Eldste først': 'created_at',
    'Navn - A til Å': 'vmp_name',
    'Navn - Å til A': '-vmp_name',
    'Pris - Høy til lav': '-price',
    'Pris - Lav til høy': 'price',
    'Rating - Høy til lav': '-rating',
    'Rating - Lav til høy': 'rating',
  };

  List<bool> styleSelectedList = List<bool>.filled(16, false);
  List<Map<String, String>> styleList = [
    {'Barleywine': 'barleywine'},
    {'Belgisk': 'belgian'},
    {'Blonde': 'blonde'},
    {'Bokk': 'Bock'},
    {'Brown': 'brown'},
    {'Gluten Fri': 'gluten-free'},
    {'IPA': 'ipa'},
    {'Juleøl': 'winter'},
    {'Lager': 'lager'},
    {'Mjød': 'mead'},
    {'Pale Ale': 'pale ale'},
    {'Pilsner': 'pilsner'},
    {'Porter': 'porter'},
    {'Sider': 'cider'},
    {'Stout': 'stout'},
    {'Surøl': 'sour,wild ale,lambic,fruit beer'},
  ];

  Filter get filters {
    return this;
  }

  Future<List<Store>> getStores() async {
    if (storeList.isNotEmpty && storeList.length > 1) {
      return storeList;
    }
    try {
      var stores = await ApiHelper.getStoreList();
      storeList = stores;
      storeList = await LocationHelper.calculateStoreDistance(storeList);
      storeList.sort((a, b) => a.distance!.compareTo(b.distance!));
    } catch (error) {
      print(error);
      return storeList;
    }
    storeList.insert(0, allStores);
    return storeList;
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
    sortBy = sortList[index]!;
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

  void setSearch(String text) {
    search = text;
    notifyListeners();
  }

  void setStore(String storeId) {
    if (storeId.isEmpty) {
      storeName = 'Alle Butikker';
    } else {
      storeName = storeList.firstWhere((element) => element.id == storeId).name;
    }
    notifyListeners();
    saveLastStore();
  }

  void saveLastStore() async {
    final prefs = await SharedPreferences.getInstance();
    final storeData = json.encode({
      'storeName': storeName,
      'storeId': storeId,
    });
    prefs.setString('storeData', storeData);
  }

  Future<void> loadLastStore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('storeData')) {
      final extractedStoreData = json.decode(prefs.getString('storeData')!);
      storeId = extractedStoreData['storeId'];
      storeName = extractedStoreData['storeName'];
    } else {
      storeId = '';
      storeName = 'Alle Butikker';
    }
    notifyListeners();
  }

  void resetFilters() {
    styleSelectedList = List<bool>.filled(16, false);
    priceRange = const RangeValues(0, 500);
    sortIndex = 'Rating - Høy til lav';
    storeId = '';
    storeName = 'Alle Butikker';
    style = '';
    priceHigh = '';
    priceLow = '';
    sortBy = '-rating';
    notifyListeners();
  }
}
