import 'package:equatable/equatable.dart';

class StockInfo {
  const StockInfo({
    required this.storeName,
    required this.quantity,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) => StockInfo(
        storeName: json['store_name'],
        quantity: json['quantity'],
      );

  final String storeName;
  final int quantity;
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.style,
    required this.price,
    required this.volume,
    this.pricePerVolume,
    this.stock,
    this.rating,
    this.checkins,
    this.abv,
    this.imageUrl,
    this.vmpUrl,
    this.untappdUrl,
    this.untappdId,
    this.country,
    this.countryCode,
    this.productSelection,
    this.labelHdUrl,
    this.ibu,
    this.description,
    this.brewery,
    this.year,
    this.color,
    this.aroma,
    this.taste,
    this.storable,
    this.foodPairing,
    this.rawMaterials,
    this.fullness,
    this.sweetness,
    this.freshness,
    this.bitterness,
    this.sugar,
    this.acid,
    this.method,
    this.allergens,
    this.alcoholUnits,
    this.allStock,
    this.valueScore,
    this.isChristmasBeer = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['vmp_id'],
        name: json['vmp_name'],
        style: json['style'] ?? json['sub_category'] ?? json['main_category'],
        stock: json['stock'],
        price: json['price'],
        volume: json['volume'],
        pricePerVolume: json['price_per_volume'],
        rating: json['rating'],
        checkins: json['checkins'],
        abv: json['abv'],
        imageUrl: json['label_sm_url'],
        vmpUrl: json['vmp_url'],
        untappdUrl: json['untpd_url'],
        untappdId: json['untpd_id'],
        country: json['country'],
        countryCode: json['country_code'],
        productSelection: json['product_selection'],
        labelHdUrl: json['label_hd_url'],
        ibu: json['ibu'] != null ? (json['ibu'] as num).toDouble() : null,
        description: json['description'],
        brewery: json['brewery'],
        year: json['year'],
        color: json['color'],
        aroma: json['aroma'],
        taste: json['taste'],
        storable: json['storable'],
        foodPairing: json['food_pairing'],
        rawMaterials: json['raw_materials'],
        fullness: json['fullness'],
        sweetness: json['sweetness'],
        freshness: json['freshness'],
        bitterness: json['bitterness'],
        sugar: json['sugar'] != null ? (json['sugar'] as num).toDouble() : null,
        acid: json['acid'] != null ? (json['acid'] as num).toDouble() : null,
        method: json['method'],
        allergens: json['allergens'],
        alcoholUnits: json['alcohol_units'] != null
            ? (json['alcohol_units'] as num).toDouble()
            : null,
        allStock: json['all_stock'] != null
            ? (json['all_stock'] as List)
                .map((s) => StockInfo.fromJson(s))
                .toList()
            : null,
        valueScore: json['value_score'] != null
            ? (json['value_score'] as num).toDouble()
            : null,
        isChristmasBeer: json['is_christmas_beer'] ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        style,
        stock,
        price,
        volume,
        pricePerVolume,
        rating,
        checkins,
        abv,
        imageUrl,
        vmpUrl,
        untappdUrl,
        untappdId,
        country,
        countryCode,
        productSelection,
      ];

  final int id;
  final String name;
  final String style;
  final double price;
  final double volume;
  final double? pricePerVolume;
  final int? stock;
  final double? rating;
  final int? checkins;
  final double? abv;
  final String? imageUrl;
  final String? vmpUrl;
  final String? untappdUrl;
  final int? untappdId;
  final String? country;
  final String? countryCode;
  final String? productSelection;
  final String? labelHdUrl;
  final double? ibu;
  final String? description;
  final String? brewery;
  final int? year;
  final String? color;
  final String? aroma;
  final String? taste;
  final String? storable;
  final String? foodPairing;
  final String? rawMaterials;
  final int? fullness;
  final int? sweetness;
  final int? freshness;
  final int? bitterness;
  final double? sugar;
  final double? acid;
  final String? method;
  final String? allergens;
  final double? alcoholUnits;
  final List<StockInfo>? allStock;
  final double? valueScore;
  final bool isChristmasBeer;
}
