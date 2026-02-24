import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

const monthAbbreviations = [
  'jan',
  'feb',
  'mar',
  'apr',
  'mai',
  'jun',
  'jul',
  'aug',
  'sep',
  'okt',
  'nov',
  'des',
];

enum ListType {
  standard,
  shopping,
  cellar,
  event;

  String get label {
    switch (this) {
      case ListType.standard:
        return 'Standard';
      case ListType.shopping:
        return 'Handleliste';
      case ListType.cellar:
        return 'Kjeller';
      case ListType.event:
        return 'Arrangement';
    }
  }

  IconData get icon {
    switch (this) {
      case ListType.standard:
        return Icons.list;
      case ListType.shopping:
        return Icons.shopping_cart_outlined;
      case ListType.cellar:
        return Icons.inventory_2_outlined;
      case ListType.event:
        return Icons.event_outlined;
    }
  }

  String get apiValue => name;

  static ListType fromApi(String value) {
    return ListType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ListType.standard,
    );
  }
}

class ListStats extends Equatable {
  final int totalBottles;
  final double totalValue;
  final int? oldestYear;
  final int? newestYear;

  const ListStats({
    required this.totalBottles,
    required this.totalValue,
    this.oldestYear,
    this.newestYear,
  });

  factory ListStats.fromJson(Map<String, dynamic> json) => ListStats(
        totalBottles: json['total_bottles'] as int,
        totalValue: (json['total_value'] as num).toDouble(),
        oldestYear: json['oldest_year'] as int?,
        newestYear: json['newest_year'] as int?,
      );

  @override
  List<Object?> get props => [totalBottles, totalValue, oldestYear, newestYear];
}

class ListItem extends Equatable {
  final int id;
  final String productId;
  final int quantity;
  final int? year;
  final String? notes;
  final int sortOrder;
  final DateTime createdAt;

  const ListItem({
    required this.id,
    required this.productId,
    required this.quantity,
    this.year,
    this.notes,
    required this.sortOrder,
    required this.createdAt,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
        id: json['id'] as int,
        productId: json['product_id'].toString(),
        quantity: json['quantity'] as int,
        year: json['year'] as int?,
        notes: json['notes'] as String?,
        sortOrder: json['sort_order'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  ListItem copyWith({
    int? id,
    String? productId,
    int? quantity,
    int? year,
    String? notes,
    int? sortOrder,
    DateTime? createdAt,
  }) =>
      ListItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        year: year ?? this.year,
        notes: notes ?? this.notes,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, productId, quantity, year, notes, sortOrder, createdAt];
}

class UserList extends Equatable {
  final int id;
  final String name;
  final String? description;
  final ListType listType;
  final String? selectedStoreId;
  final DateTime? eventDate;
  final int sortOrder;
  final String shareToken;
  final int itemCount;
  final List<String> productIds;
  final double? totalPrice;
  final ListStats? stats;
  final bool? isPast;
  final List<ListItem>? items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserList({
    required this.id,
    required this.name,
    this.description,
    required this.listType,
    this.selectedStoreId,
    this.eventDate,
    required this.sortOrder,
    required this.shareToken,
    required this.itemCount,
    required this.productIds,
    this.totalPrice,
    this.stats,
    this.isPast,
    this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        listType: ListType.fromApi(json['list_type'] as String),
        selectedStoreId: json['selected_store_id']?.toString(),
        eventDate: json['event_date'] != null
            ? DateTime.parse(json['event_date'] as String)
            : null,
        sortOrder: json['sort_order'] as int,
        shareToken: json['share_token'] as String,
        itemCount: json['item_count'] as int,
        productIds: json['product_ids'] != null
            ? (json['product_ids'] as List).map((e) => e.toString()).toList()
            : [],
        totalPrice: json['total_price'] != null
            ? (json['total_price'] as num).toDouble()
            : null,
        stats: json['stats'] != null
            ? ListStats.fromJson(json['stats'] as Map<String, dynamic>)
            : null,
        isPast: json['is_past'] as bool?,
        items: json['items'] != null
            ? (json['items'] as List)
                .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  UserList copyWith({
    int? id,
    String? name,
    String? description,
    ListType? listType,
    String? selectedStoreId,
    DateTime? eventDate,
    int? sortOrder,
    String? shareToken,
    int? itemCount,
    List<String>? productIds,
    double? totalPrice,
    ListStats? stats,
    bool? isPast,
    List<ListItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserList(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        listType: listType ?? this.listType,
        selectedStoreId: selectedStoreId ?? this.selectedStoreId,
        eventDate: eventDate ?? this.eventDate,
        sortOrder: sortOrder ?? this.sortOrder,
        shareToken: shareToken ?? this.shareToken,
        itemCount: itemCount ?? this.itemCount,
        productIds: productIds ?? this.productIds,
        totalPrice: totalPrice ?? this.totalPrice,
        stats: stats ?? this.stats,
        isPast: isPast ?? this.isPast,
        items: items ?? this.items,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        listType,
        selectedStoreId,
        eventDate,
        sortOrder,
        shareToken,
        itemCount,
        productIds,
        totalPrice,
        stats,
        isPast,
        items,
        createdAt,
        updatedAt,
      ];
}

class SharedUserList extends Equatable {
  final int id;
  final String name;
  final String? description;
  final ListType listType;
  final String? userName;
  final String? storeName;
  final DateTime? eventDate;
  final int itemCount;
  final double? totalPrice;
  final ListStats? stats;
  final bool? isPast;
  final List<ListItem> items;
  final DateTime createdAt;

  const SharedUserList({
    required this.id,
    required this.name,
    this.description,
    required this.listType,
    this.userName,
    this.storeName,
    this.eventDate,
    required this.itemCount,
    this.totalPrice,
    this.stats,
    this.isPast,
    required this.items,
    required this.createdAt,
  });

  factory SharedUserList.fromJson(Map<String, dynamic> json) => SharedUserList(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        listType: ListType.fromApi(json['list_type'] as String),
        userName: json['user_name'] as String?,
        storeName: json['store_name'] as String?,
        eventDate: json['event_date'] != null
            ? DateTime.parse(json['event_date'] as String)
            : null,
        itemCount: json['item_count'] as int,
        totalPrice: json['total_price'] != null
            ? (json['total_price'] as num).toDouble()
            : null,
        stats: json['stats'] != null
            ? ListStats.fromJson(json['stats'] as Map<String, dynamic>)
            : null,
        isPast: json['is_past'] as bool?,
        items: (json['items'] as List)
            .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        listType,
        userName,
        storeName,
        eventDate,
        itemCount,
        totalPrice,
        stats,
        isPast,
        items,
        createdAt,
      ];
}
