import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_list.dart';
import '../providers/auth.dart';
import '../providers/filter.dart';
import '../providers/http_client.dart';
import '../utils/store_utils.dart';
import '../providers/lists.dart';
import '../services/api.dart';
import '../widgets/common/error_state.dart';
import '../widgets/lists/cellar_stats.dart';
import '../widgets/lists/list_actions.dart';
import '../widgets/lists/list_item_row.dart';
import '../widgets/lists/shopping_total_bar.dart';
import '../widgets/common/store_picker.dart';

class ListDetailScreen extends StatefulWidget {
  final int listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  Map<String, Product> _products = {};
  Map<String, int> _stockStatus = {};
  bool _stockChecked = false;
  bool _productsLoading = false;
  late final ListsProvider _listsProvider;

  @override
  void initState() {
    super.initState();
    _listsProvider = Provider.of<ListsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadList();
    });
  }

  Future<void> _loadList() async {
    await _listsProvider.fetchListDetail(widget.listId);
    if (mounted) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    final items = _listsProvider.activeList?.items;
    if (items == null || items.isEmpty) return;

    setState(() => _productsLoading = true);

    final productIds = items.map((i) => i.productId).toSet().toList();
    final idsStr = productIds.join(',');

    try {
      final client = Provider.of<HttpClient>(context, listen: false).apiClient;
      final auth = Provider.of<Auth>(context, listen: false);
      final token = auth.isSignedIn ? await auth.getIdToken() : null;
      final products = await ApiHelper.getProductsByIds(
        client,
        idsStr,
        token: token,
      );
      if (products != null && mounted) {
        final map = <String, Product>{};
        for (final p in products) {
          map[p.id.toString()] = p;
        }
        setState(() {
          _products = map;
          _productsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _productsLoading = false);
    }

    if (mounted) _checkStockStatus();
  }

  Future<void> _checkStockStatus() async {
    final list = _listsProvider.activeList;
    if (list == null) return;
    final storeId = list.selectedStoreId;
    if (storeId == null || storeId.isEmpty) {
      if (_stockChecked || _stockStatus.isNotEmpty) {
        setState(() {
          _stockStatus = {};
          _stockChecked = false;
        });
      }
      return;
    }

    final items = list.items;
    if (items == null || items.isEmpty) return;

    final productIds = items.map((i) => i.productId).toSet().join(',');
    try {
      final client = Provider.of<HttpClient>(context, listen: false).apiClient;
      final response = await ApiHelper.checkStock(client, productIds, storeId);
      if (!mounted) return;
      final status = <String, int>{};
      for (final entry in response) {
        final id = entry['vmp_id'].toString();
        final stock = entry['stock'] as int? ?? 0;
        status[id] = stock;
      }
      setState(() {
        _stockStatus = status;
        _stockChecked = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _stockChecked = true);
      }
    }
  }

  Future<void> _editList(UserList list) async {
    if (!mounted) return;
    await ListActions.edit(context, list, _listsProvider);
  }

  Future<void> _deleteList(UserList list) async {
    if (!mounted) return;
    final success = await ListActions.delete(context, list, _listsProvider);
    if (success && mounted) context.pop();
  }

  Future<void> _selectStore(UserList list) async {
    final filters = Provider.of<Filter>(context, listen: false);
    if (filters.storeList.isEmpty) {
      await filters.getStores();
      if (filters.storeList.isEmpty) return;
    }

    final selected = await showStorePicker(
      context,
      stores: filters.storeList,
      selectedStoreId: list.selectedStoreId,
      allowClear: list.selectedStoreId != null,
    );

    if (selected == null || !mounted) return;

    await _listsProvider.updateList(
      list.id,
      selectedStoreId: selected.id.isEmpty ? '' : selected.id,
    );
    await _loadList();
    _checkStockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listsProvider.clearActiveList();
    });
    super.dispose();
  }

  double _calculateTotal(UserList list) {
    if (list.totalPrice != null) return list.totalPrice!;
    final items = list.items ?? [];
    double total = 0;
    for (final item in items) {
      final product = _products[item.productId];
      if (product != null) {
        total += product.price * item.quantity;
      }
    }
    return total;
  }

  int _inStockCount(UserList list) {
    final items = list.items ?? [];
    int count = 0;
    for (final item in items) {
      if (_stockStatus.containsKey(item.productId)) count++;
    }
    return count;
  }

  int _totalUnits(UserList list) {
    final items = list.items ?? [];
    int total = 0;
    for (final item in items) {
      total += item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListsProvider>(
      builder: (context, listsProvider, _) {
        final list = listsProvider.activeList;

        if (listsProvider.loading && list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Liste')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (listsProvider.error != null && list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Liste')),
            body: ErrorState(message: listsProvider.error!, onRetry: _loadList),
          );
        }

        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Liste')),
            body: const Center(child: Text('Listen ble ikke funnet')),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(list),
          body: _buildBody(list, listsProvider),
          bottomNavigationBar: list.listType == ListType.shopping
              ? ShoppingTotalBar(
                  totalPrice: _calculateTotal(list),
                  itemCount: list.items?.length ?? list.itemCount,
                  totalUnits: _totalUnits(list),
                  inStockCount: _stockChecked ? _inStockCount(list) : null,
                )
              : null,
        );
      },
    );
  }

  AppBar _buildAppBar(UserList list) {
    return AppBar(
      title: Text(list.name),
      actions: [
        IconButton(
          onPressed: () => ListActions.share(list),
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Del',
        ),
        PopupMenuButton<String>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          onSelected: (value) {
            if (value == 'edit') _editList(list);
            if (value == 'delete') _deleteList(list);
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 12),
                  Text('Rediger'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 12),
                  Text('Slett'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(UserList list, ListsProvider listsProvider) {
    final items = list.items ?? [];

    if (items.isEmpty && !_productsLoading) {
      return RefreshIndicator(
        onRefresh: _loadList,
        child: _buildEmptyState(list),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadList,
      child: Column(
        children: [
          _buildListHeader(list),
          Expanded(
            child: _productsLoading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedReorderableListView<ListItem>(
                    items: items,
                    padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
                    buildDefaultDragHandles: false,
                    enterTransition: [
                      FadeIn(duration: const Duration(milliseconds: 200)),
                    ],
                    exitTransition: [
                      FadeIn(duration: const Duration(milliseconds: 200)),
                    ],
                    insertDuration: const Duration(milliseconds: 200),
                    removeDuration: const Duration(milliseconds: 200),
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      final ids = items.map((i) => i.id).toList();
                      final movedId = ids.removeAt(oldIndex);
                      ids.insert(newIndex, movedId);
                      listsProvider.reorderItems(list.id, ids);
                    },
                    isSameItem: (a, b) => a.id == b.id,
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.transparent,
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = _products[item.productId];
                      final bool? inStock =
                          list.selectedStoreId != null &&
                              list.selectedStoreId!.isNotEmpty &&
                              _stockChecked
                          ? _stockStatus.containsKey(item.productId)
                          : null;
                      final int? stockCount = _stockStatus[item.productId];
                      return ListItemRow(
                        key: ValueKey(item.id),
                        item: item,
                        product: product,
                        listType: list.listType,
                        dragIndex: index,
                        inStock: inStock,
                        stockCount: stockCount,
                        onRemove: () =>
                            listsProvider.removeItemFromList(list.id, item.id),
                        onQuantityChanged: (qty) => listsProvider
                            .updateListItem(list.id, item.id, quantity: qty),
                        onYearChanged: (year) => listsProvider.updateListItem(
                          list.id,
                          item.id,
                          year: year,
                        ),
                        onNotesChanged: (notes) => listsProvider.updateListItem(
                          list.id,
                          item.id,
                          notes: notes,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(UserList list) {
    final colors = Theme.of(context).colorScheme;
    final isShopping = list.listType == ListType.shopping;
    final hasStore =
        list.selectedStoreId != null && list.selectedStoreId!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (list.description != null && list.description!.isNotEmpty) ...[
            Text(
              list.description!,
              style: TextStyle(fontSize: 13.sp, color: colors.onSurfaceVariant),
            ),
            SizedBox(height: 10.h),
          ],
          if (isShopping) ...[_buildStoreSelector(list, colors, hasStore)],
          if (list.eventDate != null) ...[_buildEventCard(list, colors)],
          if (list.listType == ListType.cellar && list.items != null) ...[
            CellarStatsWidget(stats: _computeCellarStats(list.items!)),
          ],
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildStoreSelector(UserList list, ColorScheme colors, bool hasStore) {
    final storeName = hasStore
        ? lookupStoreName(context, list.selectedStoreId)
        : null;

    return GestureDetector(
      onTap: () => _selectStore(list),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: hasStore
              ? colors.primaryContainer.withValues(alpha: 0.3)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasStore
                ? colors.primary.withValues(alpha: 0.3)
                : colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: hasStore
                    ? colors.primary.withValues(alpha: 0.15)
                    : colors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasStore ? Icons.store : Icons.add_business_outlined,
                size: 18.r,
                color: hasStore ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasStore ? (storeName ?? 'Butikk') : 'Velg butikk',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: hasStore
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    hasStore
                        ? 'Trykk for å endre butikk'
                        : 'Se lagerstatus for dine produkter',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.r,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(UserList list, ColorScheme colors) {
    final isPast = list.isPast == true;
    final date = list.eventDate!;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isPast
            ? colors.errorContainer.withValues(alpha: 0.2)
            : colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPast
              ? colors.error.withValues(alpha: 0.2)
              : colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isPast
                  ? colors.error.withValues(alpha: 0.15)
                  : colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event,
              size: 18.r,
              color: isPast ? colors.error : colors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}. ${monthAbbreviations[date.month - 1]} ${date.year}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  isPast ? 'Arrangementet er passert' : 'Kommende arrangement',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isPast
                        ? colors.error.withValues(alpha: 0.8)
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isPast)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Passert',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ListStats _computeCellarStats(List<ListItem> items) {
    int totalBottles = 0;
    double totalValue = 0;
    int? oldestYear;
    int? newestYear;
    for (final item in items) {
      totalBottles += item.quantity;
      final product = _products[item.productId];
      if (product != null) {
        totalValue += product.price * item.quantity;
      }
      if (item.year != null) {
        if (oldestYear == null || item.year! < oldestYear) {
          oldestYear = item.year;
        }
        if (newestYear == null || item.year! > newestYear) {
          newestYear = item.year;
        }
      }
    }
    return ListStats(
      totalBottles: totalBottles,
      totalValue: totalValue,
      oldestYear: oldestYear,
      newestYear: newestYear,
    );
  }

  Widget _buildEmptyState(UserList list) {
    final colors = Theme.of(context).colorScheme;
    final isShopping = list.listType == ListType.shopping;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _buildListHeader(list),
        SizedBox(height: 60.h),
        Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isShopping
                      ? Icons.shopping_cart_outlined
                      : Icons.playlist_add,
                  size: 48.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Listen er tom',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                'Legg til produkter fra produktsiden.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
