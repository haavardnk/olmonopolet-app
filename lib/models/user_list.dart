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
  final bool showQuantity;
  final bool showStore;
  final bool showVintage;
  final bool showPrices;
  final bool showNotes;
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
  final bool isFollowed;
  final String? userName;

  bool get isUntappd => untappdListId != null;
  bool get isReadOnly => isUntappd || isFollowed;

  IconData get icon {
    if (isUntappd) return Icons.cloud_download_outlined;
    if (showStore) return Icons.shopping_cart_outlined;
    if (showVintage) return Icons.inventory_2_outlined;
    if (eventDate != null) return Icons.event_outlined;
    return Icons.list;
  }

  const UserList({
    required this.id,
    required this.name,
    this.description,
    this.showQuantity = false,
    this.showStore = false,
    this.showVintage = false,
    this.showPrices = true,
    this.showNotes = true,
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
    this.isFollowed = false,
    this.userName,
  });

  factory UserList.fromJson(Map<String, dynamic> json) {
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
      showQuantity: json['show_quantity'] as bool? ?? false,
      showStore: json['show_store'] as bool? ?? false,
      showVintage: json['show_vintage'] as bool? ?? false,
      showPrices: json['show_prices'] as bool? ?? true,
      showNotes: json['show_notes'] as bool? ?? true,
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
      isFollowed: json['is_followed'] as bool? ?? false,
      userName: json['user_name'] as String?,
    );
  }

  UserList copyWith({
    int? id,
    String? name,
    String? description,
    bool? showQuantity,
    bool? showStore,
    bool? showVintage,
    bool? showPrices,
    bool? showNotes,
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
    bool? isFollowed,
    String? userName,
  }) =>
      UserList(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        showQuantity: showQuantity ?? this.showQuantity,
        showStore: showStore ?? this.showStore,
        showVintage: showVintage ?? this.showVintage,
        showPrices: showPrices ?? this.showPrices,
        showNotes: showNotes ?? this.showNotes,
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
        isFollowed: isFollowed ?? this.isFollowed,
        userName: userName ?? this.userName,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        showQuantity,
        showStore,
        showVintage,
        showPrices,
        showNotes,
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
        isFollowed,
        userName,
      ];
}

class SharedUserList extends Equatable {
  final int id;
  final String name;
  final String? description;
  final bool showQuantity;
  final bool showStore;
  final bool showVintage;
  final bool showPrices;
  final bool showNotes;
  final String? userName;
  final String? storeName;
  final String? selectedStoreId;
  final DateTime? eventDate;
  final int itemCount;
  final double? totalPrice;
  final ListStats? stats;
  final bool? isPast;
  final List<ListItem> items;
  final DateTime createdAt;
  final int? untappdListId;

  bool get isUntappd => untappdListId != null;

  const SharedUserList({
    required this.id,
    required this.name,
    this.description,
    this.showQuantity = false,
    this.showStore = false,
    this.showVintage = false,
    this.showPrices = true,
    this.showNotes = true,
    this.userName,
    this.storeName,
    this.selectedStoreId,
    this.eventDate,
    required this.itemCount,
    this.totalPrice,
    this.stats,
    this.isPast,
    required this.items,
    required this.createdAt,
    this.untappdListId,
  });

  factory SharedUserList.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List)
        .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SharedUserList(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      showQuantity: json['show_quantity'] as bool? ?? false,
      showStore: json['show_store'] as bool? ?? false,
      showVintage: json['show_vintage'] as bool? ?? false,
      showPrices: json['show_prices'] as bool? ?? true,
      showNotes: json['show_notes'] as bool? ?? true,
      userName: json['user_name'] as String?,
      storeName: json['store_name'] as String?,
      selectedStoreId: json['selected_store_id']?.toString(),
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
      untappdListId: json['untappd_list_id'] as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        showQuantity,
        showStore,
        showVintage,
        showPrices,
        showNotes,
        userName,
        storeName,
        selectedStoreId,
        eventDate,
        itemCount,
        totalPrice,
        stats,
        isPast,
        items,
        createdAt,
        untappdListId,
      ];
}
