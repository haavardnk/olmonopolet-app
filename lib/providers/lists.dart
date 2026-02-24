import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as p;

import '../models/user_list.dart';
import '../services/list_api.dart';
import '../providers/auth.dart';

class ListsProvider with ChangeNotifier {
  late http.Client _client;
  Auth? _auth;

  List<UserList> _lists = [];
  UserList? _activeList;
  bool _loading = false;
  bool _listsLoaded = false;
  String? _error;

  void update(http.Client client, Auth auth) {
    final wasSignedIn = _auth?.isSignedIn ?? false;
    final isNowSignedIn = auth.isSignedIn;
    _client = client;
    _auth = auth;

    if (wasSignedIn && !isNowSignedIn) {
      _lists = [];
      _activeList = null;
      _listsLoaded = false;
      _error = null;
      notifyListeners();
    }
  }

  List<UserList> get lists => [..._lists];
  UserList? get activeList => _activeList;
  bool get loading => _loading;
  bool get listsLoaded => _listsLoaded;
  String? get error => _error;

  bool get isAuthenticated => _auth?.isSignedIn ?? false;

  Future<String?> get _token async {
    if (_auth == null || !_auth!.isSignedIn) return null;
    return _auth!.getIdToken();
  }

  bool isProductInAnyList(int productId) {
    final pid = productId.toString();
    return _lists.any((list) => list.productIds.contains(pid));
  }

  List<UserList> getListsContainingProduct(int productId) {
    final pid = productId.toString();
    return _lists.where((list) => list.productIds.contains(pid)).toList();
  }

  Future<void> fetchLists() async {
    final token = await _token;
    if (token == null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _lists = await ListApi.fetchLists(_client, token);
      _lists.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _listsLoaded = true;
      _error = null;
    } catch (e) {
      _error = 'Kunne ikke laste lister';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchListDetail(int listId) async {
    final token = await _token;
    if (token == null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _activeList = await ListApi.fetchList(_client, token, listId);
      _error = null;
    } catch (e) {
      _error = 'Kunne ikke laste listen';
    }

    _loading = false;
    notifyListeners();
  }

  Future<UserList?> createList({
    required String name,
    String? description,
    required ListType listType,
    DateTime? eventDate,
  }) async {
    final token = await _token;
    if (token == null) return null;

    try {
      final newList = await ListApi.createList(
        _client,
        token,
        name: name,
        description: description,
        listType: listType,
        eventDate: eventDate,
      );
      _lists.add(newList);
      _lists.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      notifyListeners();
      return newList;
    } catch (e) {
      _error = 'Kunne ikke opprette listen';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateList(
    int listId, {
    String? name,
    String? description,
    ListType? listType,
    String? selectedStoreId,
    DateTime? eventDate,
  }) async {
    final token = await _token;
    if (token == null) return false;

    try {
      final updated = await ListApi.updateList(
        _client,
        token,
        listId,
        name: name,
        description: description,
        listType: listType,
        selectedStoreId: selectedStoreId,
        eventDate: eventDate,
      );
      final index = _lists.indexWhere((l) => l.id == listId);
      if (index >= 0) {
        _lists[index] = updated;
      }
      if (_activeList?.id == listId) {
        _activeList = updated.copyWith(items: _activeList?.items);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Kunne ikke oppdatere listen';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteList(int listId) async {
    final token = await _token;
    if (token == null) return false;

    try {
      await ListApi.deleteList(_client, token, listId);
      _lists.removeWhere((l) => l.id == listId);
      if (_activeList?.id == listId) {
        _activeList = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Kunne ikke slette listen';
      notifyListeners();
      return false;
    }
  }

  Future<void> reorderLists(List<int> listIds) async {
    final token = await _token;
    if (token == null) return;

    final oldLists = [..._lists];
    _lists = listIds
        .map((id) => _lists.firstWhere((l) => l.id == id))
        .toList();
    notifyListeners();

    try {
      await ListApi.reorderLists(_client, token, listIds);
    } catch (e) {
      _lists = oldLists;
      notifyListeners();
    }
  }

  Future<bool> addItemToList(
    int listId,
    String productId, {
    int quantity = 1,
    int? year,
    String? notes,
  }) async {
    final token = await _token;
    if (token == null) return false;

    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex >= 0) {
      _lists[listIndex] = _lists[listIndex].copyWith(
        productIds: [..._lists[listIndex].productIds, productId],
        itemCount: _lists[listIndex].itemCount + 1,
      );
      notifyListeners();
    }

    try {
      final item = await ListApi.addItem(
        _client,
        token,
        listId,
        productId: productId,
        quantity: quantity,
        year: year,
        notes: notes,
      );
      if (_activeList?.id == listId && _activeList?.items != null) {
        _activeList = _activeList!.copyWith(
          items: [..._activeList!.items!, item],
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (listIndex >= 0) {
        _lists[listIndex] = _lists[listIndex].copyWith(
          productIds: _lists[listIndex].productIds
              .where((id) => id != productId)
              .toList(),
          itemCount: _lists[listIndex].itemCount - 1,
        );
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> removeItemFromList(int listId, int itemId) async {
    final token = await _token;
    if (token == null) return false;

    ListItem? removedItem;
    int? removedIndex;
    if (_activeList?.id == listId && _activeList?.items != null) {
      removedIndex =
          _activeList!.items!.indexWhere((i) => i.id == itemId);
      if (removedIndex >= 0) {
        removedItem = _activeList!.items![removedIndex];
        final newItems = [..._activeList!.items!]..removeAt(removedIndex);
        _activeList = _activeList!.copyWith(items: newItems);
      }
    }

    final listIndex = _lists.indexWhere((l) => l.id == listId);
    String? removedProductId;
    if (listIndex >= 0 && removedItem != null) {
      removedProductId = removedItem.productId;
      _lists[listIndex] = _lists[listIndex].copyWith(
        productIds: _lists[listIndex].productIds
            .where((id) => id != removedProductId)
            .toList(),
        itemCount: _lists[listIndex].itemCount - 1,
      );
    }
    notifyListeners();

    try {
      await ListApi.removeItem(_client, token, listId, itemId);
      return true;
    } catch (e) {
      if (removedItem != null && removedIndex != null) {
        if (_activeList?.id == listId && _activeList?.items != null) {
          final restored = [..._activeList!.items!]
            ..insert(removedIndex, removedItem);
          _activeList = _activeList!.copyWith(items: restored);
        }
        if (listIndex >= 0 && removedProductId != null) {
          _lists[listIndex] = _lists[listIndex].copyWith(
            productIds: [..._lists[listIndex].productIds, removedProductId],
            itemCount: _lists[listIndex].itemCount + 1,
          );
        }
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> updateListItem(
    int listId,
    int itemId, {
    int? quantity,
    int? year,
    String? notes,
  }) async {
    final token = await _token;
    if (token == null) return false;

    try {
      final updated = await ListApi.updateItem(
        _client,
        token,
        listId,
        itemId,
        quantity: quantity,
        year: year,
        notes: notes,
      );
      if (_activeList?.id == listId && _activeList?.items != null) {
        final items = _activeList!.items!
            .map((i) => i.id == itemId ? updated : i)
            .toList();
        _activeList = _activeList!.copyWith(items: items);
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> reorderItems(int listId, List<int> itemIds) async {
    final token = await _token;
    if (token == null) return;

    if (_activeList?.id == listId && _activeList?.items != null) {
      final oldItems = [..._activeList!.items!];
      final reordered = itemIds
          .map((id) => oldItems.firstWhere((i) => i.id == id))
          .toList();
      _activeList = _activeList!.copyWith(items: reordered);
      notifyListeners();

      try {
        await ListApi.reorderItems(_client, token, listId, itemIds);
      } catch (e) {
        _activeList = _activeList!.copyWith(items: oldItems);
        notifyListeners();
      }
    }
  }

  Future<bool> toggleProductInList(int listId, int productId) async {
    final pid = productId.toString();
    final listIndex = _lists.indexWhere((l) => l.id == listId);
    if (listIndex < 0) return false;

    final list = _lists[listIndex];
    if (list.productIds.contains(pid)) {
      if (_activeList?.id == listId && _activeList?.items != null) {
        final item = _activeList!.items!
            .cast<ListItem?>()
            .firstWhere((i) => i!.productId == pid, orElse: () => null);
        if (item == null) return false;
        return removeItemFromList(listId, item.id);
      }
      await fetchListDetail(listId);
      if (_activeList?.items != null) {
        final item = _activeList!.items!
            .cast<ListItem?>()
            .firstWhere((i) => i!.productId == pid, orElse: () => null);
        if (item == null) return false;
        return removeItemFromList(listId, item.id);
      }
      return false;
    } else {
      return addItemToList(listId, pid);
    }
  }

  void clearActiveList() {
    _activeList = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> migrateCartIfNeeded() async {
    final token = await _token;
    if (token == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('cartMigrated') == true) return;

    final dbPath = await sql.getDatabasesPath();
    final cartDbPath = p.join(dbPath, 'cart.db');

    if (!await sql.databaseExists(cartDbPath)) {
      await prefs.setBool('cartMigrated', true);
      return;
    }

    List<Map<String, dynamic>> cartItems;
    try {
      final db = await sql.openDatabase(cartDbPath);
      cartItems = await db.query('cart');
      await db.close();
    } catch (_) {
      await prefs.setBool('cartMigrated', true);
      return;
    }

    if (cartItems.isEmpty) {
      await prefs.setBool('cartMigrated', true);
      await sql.deleteDatabase(cartDbPath);
      return;
    }

    UserList newList;
    try {
      newList = await ListApi.createList(
        _client,
        token,
        name: 'Handleliste',
        listType: ListType.shopping,
      );
    } catch (_) {
      return;
    }

    _lists.add(newList);
    notifyListeners();

    for (final item in cartItems) {
      final productId = item['id']?.toString();
      final quantity = item['quantity'] as int? ?? 1;
      if (productId == null) continue;

      try {
        await ListApi.addItem(
          _client,
          token,
          newList.id,
          productId: productId,
          quantity: quantity,
        );
      } catch (_) {}
    }

    await fetchListDetail(newList.id);
    await fetchLists();

    await prefs.setBool('cartMigrated', true);
    await sql.deleteDatabase(cartDbPath);

    prefs.remove('cartStoreId');
    prefs.remove('cartSortIndex');
    prefs.remove('cartSelectedStores');
    prefs.remove('useOverviewStoreSelection');
    prefs.remove('greyNoStock');
    prefs.remove('hideNoStock');
  }
}
