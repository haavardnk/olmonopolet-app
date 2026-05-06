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
  event,
  untappd;

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
      case ListType.untappd:
        return 'Untappd';
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
      case ListType.untappd:
        return Icons.cloud_download_outlined;
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
        productId: (json['product_id'] ?? json['product'])?.toString() ?? '',
        quantity: (json['quantity'] as int?) ?? 1,
        year: json['year'] as int?,
        notes: json['notes'] as String?,
        sortOrder: (json['sort_order'] as int?) ?? 0,
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
  final bool showQuantity;
  final bool showStore;
  final bool showVintage;
  final bool showPrices;
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
  final int? untappdListId;
  final String? untappdUsername;
  final DateTime? lastSynced;
  final String? syncStatus;

  bool get isUntappd => untappdListId != null;
  bool get isReadOnly => isUntappd;

  const UserList({
    required this.id,
    required this.name,
    this.description,
    required this.listType,
    this.showQuantity = false,
    this.showStore = false,
    this.showVintage = false,
    this.showPrices = true,
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
    this.untappdListId,
    this.untappdUsername,
    this.lastSynced,
    this.syncStatus,
  });

  factory UserList.fromJson(Map<String, dynamic> json) {
    final listType = ListType.fromApi(json['list_type'] as String);
    final productIds = json['product_ids'] != null
        ? (json['product_ids'] as List).map((e) => e.toString()).toList()
        : <String>[];

    List<ListItem>? items;
    if (json['untappd_list_id'] != null) {
      items = [
        for (var i = 0; i < productIds.length; i++)
          ListItem(
            id: i,
            productId: productIds[i],
            quantity: 1,
            sortOrder: i,
            createdAt: DateTime.now(),
          ),
      ];
    } else if (json['items'] != null) {
      items = (json['items'] as List)
          .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return UserList(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      listType: listType,
      showQuantity: json['show_quantity'] as bool? ?? false,
      showStore: json['show_store'] as bool? ?? false,
      showVintage: json['show_vintage'] as bool? ?? false,
      showPrices: json['show_prices'] as bool? ?? true,
      selectedStoreId: json['selected_store_id']?.toString(),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : null,
      sortOrder: (json['sort_order'] as int?) ?? 0,
      shareToken: json['share_token'] as String,
      itemCount: (json['item_count'] as int?) ?? 0,
      productIds: productIds,
      totalPrice: json['total_price'] != null
          ? (json['total_price'] as num).toDouble()
          : null,
      stats: json['stats'] != null
          ? ListStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      isPast: json['is_past'] as bool?,
      items: items,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      untappdListId: json['untappd_list_id'] as int?,
      untappdUsername: json['untappd_username'] as String?,
      lastSynced: json['last_synced'] != null
          ? DateTime.parse(json['last_synced'] as String)
          : null,
      syncStatus: json['sync_status'] as String?,
    );
  }

  UserList copyWith({
    int? id,
    String? name,
    String? description,
    ListType? listType,
    bool? showQuantity,
    bool? showStore,
    bool? showVintage,
    bool? showPrices,
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
    int? untappdListId,
    String? untappdUsername,
    DateTime? lastSynced,
    String? syncStatus,
  }) =>
      UserList(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        listType: listType ?? this.listType,
        showQuantity: showQuantity ?? this.showQuantity,
        showStore: showStore ?? this.showStore,
        showVintage: showVintage ?? this.showVintage,
        showPrices: showPrices ?? this.showPrices,
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
        untappdListId: untappdListId ?? this.untappdListId,
        untappdUsername: untappdUsername ?? this.untappdUsername,
        lastSynced: lastSynced ?? this.lastSynced,
        syncStatus: syncStatus ?? this.syncStatus,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        listType,
        showQuantity,
        showStore,
        showVintage,
        showPrices,
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
        untappdListId,
        untappdUsername,
        lastSynced,
        syncStatus,
      ];
}

class SharedUserList extends Equatable {
  final int id;
  final String name;
  final String? description;
  final ListType listType;
  final bool showQuantity;
  final bool showStore;
  final bool showVintage;
  final bool showPrices;
  final String? userName;
  final String? storeName;
  final DateTime? eventDate;
  final int itemCount;
  final double? totalPrice;
  final ListStats? stats;
  final bool? isPast;
  final List<ListItem> items;
  final DateTime createdAt;

  bool get isUntappd => listType == ListType.untappd;

  const SharedUserList({
    required this.id,
    required this.name,
    this.description,
    required this.listType,
    this.showQuantity = false,
    this.showStore = false,
    this.showVintage = false,
    this.showPrices = true,
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

  factory SharedUserList.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List)
        .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SharedUserList(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      listType: ListType.fromApi(json['list_type'] as String),
      showQuantity: json['show_quantity'] as bool? ?? false,
      showStore: json['show_store'] as bool? ?? false,
      showVintage: json['show_vintage'] as bool? ?? false,
      showPrices: json['show_prices'] as bool? ?? true,
      userName: json['user_name'] as String?,
      storeName: json['store_name'] as String?,
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : null,
      itemCount: (json['item_count'] as int?) ?? items.length,
      totalPrice: json['total_price'] != null
          ? (json['total_price'] as num).toDouble()
          : null,
      stats: json['stats'] != null
          ? ListStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      isPast: json['is_past'] as bool?,
      items: items,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        listType,
        showQuantity,
        showStore,
        showVintage,
        showPrices,
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
