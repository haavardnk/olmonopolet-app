import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product.dart';
import '../models/user_list.dart';
import '../providers/auth.dart';
import '../providers/filter.dart';
import '../providers/http_client.dart';
import '../utils/store_utils.dart';
import '../providers/lists.dart';
import '../services/api.dart';
import '../utils/crash_reporter.dart';
import '../widgets/common/error_state.dart';
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

    final productIds = items
        .map((i) => i.productId)
        .where((id) => id.isNotEmpty && id != 'null')
        .toSet()
        .toList();
    if (productIds.isEmpty) {
      setState(() => _productsLoading = false);
      return;
    }
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
    } catch (e, st) {
      CrashReporter.recordError(e, st);
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
    } catch (e, st) {
      CrashReporter.recordError(e, st);
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
      _listsProvider.fetchLists();
    });
    super.dispose();
  }

  double _calculateTotal(UserList list) {
    final items = list.items ?? [];
    if (_products.isNotEmpty && items.isNotEmpty) {
      double total = 0;
      for (final item in items) {
        final product = _products[item.productId];
        if (product != null) {
          total += product.price * item.quantity;
        }
      }
      return total;
    }
    return list.totalPrice ?? 0;
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
          bottomNavigationBar: list.showStore
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
    final isUntappd = list.isUntappd;
    return AppBar(
      title: Text(list.name),
      actions: [
        if (!isUntappd)
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
            if (!isUntappd)
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
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline),
                  const SizedBox(width: 12),
                  Text(isUntappd ? 'Avslutt abonnement' : 'Slett'),
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
    final isUntappd = list.isUntappd;

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
                    onReorder: isUntappd
                        ? (_, _) {}
                        : (oldIndex, newIndex) {
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
                        showQuantity: list.showQuantity,
                        showStore: list.showStore,
                        showVintage: list.showVintage,
                        showPrices: list.showPrices,
                        dragIndex: isUntappd ? null : index,
                        inStock: inStock,
                        stockCount: stockCount,
                        isReadOnly: isUntappd,
                        onRemove: () =>
                            listsProvider.removeItemFromList(list.id, item.id),
                        onQuantityChanged: isUntappd
                            ? null
                            : (qty) => listsProvider.updateListItem(
                                list.id, item.id,
                                quantity: qty),
                        onYearChanged: isUntappd
                            ? null
                            : (year) => listsProvider.updateListItem(
                                  list.id,
                                  item.id,
                                  year: year,
                                ),
                        onNotesChanged: isUntappd
                            ? null
                            : (notes) => listsProvider.updateListItem(
                                  list.id,
                                  item.id,
                                  notes: notes,
                                ),
                        onTastedToggled: (updated) {
                          setState(() {
                            _products[updated.id.toString()] = updated;
                          });
                        },
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
    final hasStore =
        list.selectedStoreId != null && list.selectedStoreId!.isNotEmpty;
    final hasMetadata = list.eventDate != null ||
        (list.showVintage && (list.items?.isNotEmpty ?? false));

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
          if (list.isUntappd) ...[
            _buildUntappdHeader(list, colors),
            SizedBox(height: 6.h),
          ],
          if (list.showStore) ...[
            _buildStoreSelector(list, colors, hasStore),
            SizedBox(height: 6.h),
          ],
          if (hasMetadata) ...[
            _buildMetadataChips(list, colors),
            SizedBox(height: 4.h),
          ],
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildMetadataChips(UserList list, ColorScheme colors) {
    final chips = <Widget>[];

    if (list.eventDate != null) {
      final isPast = list.isPast == true;
      final date = list.eventDate!;
      final label = isPast
          ? 'Passert · ${date.day}. ${monthAbbreviations[date.month - 1]}'
          : '${date.day}. ${monthAbbreviations[date.month - 1]} ${date.year}';
      chips.add(_buildInfoChip(
        Icons.event,
        label,
        isPast ? colors.errorContainer.withValues(alpha: 0.5) : colors.primaryContainer.withValues(alpha: 0.5),
        isPast ? colors.error : colors.primary,
        colors,
      ));
    }

    if (list.showVintage && list.items != null && list.items!.isNotEmpty) {
      final stats = _computeCellarStats(list.items!);
      chips.add(_buildInfoChip(
        Icons.inventory_2_outlined,
        '${stats.totalBottles} flasker',
        colors.surfaceContainerHighest,
        colors.primary,
        colors,
      ));
      // Don't duplicate value when showStore=true — the bottom bar already shows it
      if (!list.showStore && stats.totalValue > 0) {
        chips.add(_buildInfoChip(
          Icons.payments_outlined,
          'Kr ${stats.totalValue.toStringAsFixed(0)}',
          colors.surfaceContainerHighest,
          colors.primary,
          colors,
        ));
      }
      if (stats.oldestYear != null || stats.newestYear != null) {
        final yearRange = (stats.oldestYear != null && stats.newestYear != null)
            ? (stats.oldestYear == stats.newestYear
                ? '${stats.oldestYear}'
                : '${stats.oldestYear} – ${stats.newestYear}')
            : '${stats.oldestYear ?? stats.newestYear}';
        chips.add(_buildInfoChip(
          Icons.calendar_today_outlined,
          yearRange,
          colors.surfaceContainerHighest,
          colors.primary,
          colors,
        ));
      }
    }

    return Wrap(spacing: 6.w, runSpacing: 6.h, children: chips);
  }

  Widget _buildInfoChip(
    IconData icon,
    String text,
    Color bg,
    Color iconColor,
    ColorScheme colors,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: iconColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
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
    final isShopping = list.showStore;
    final isUntappd = list.isUntappd;

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
                  isUntappd
                      ? Icons.cloud_download_outlined
                      : isShopping
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
                isUntappd
                    ? 'Ingen produkter fra denne Untappd-listen finnes på Vinmonopolet.'
                    : 'Legg til produkter fra produktsiden.',
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

  Widget _buildUntappdHeader(UserList list, ColorScheme colors) {
    final lastSynced = list.lastSynced?.toLocal();
    final syncedText = lastSynced != null
        ? 'Sist synkronisert: ${lastSynced.day}. ${monthAbbreviations[lastSynced.month - 1]} ${lastSynced.year}, ${lastSynced.hour.toString().padLeft(2, '0')}:${lastSynced.minute.toString().padLeft(2, '0')}'
        : 'Aldri synkronisert';

    return Column(
      children: [
        GestureDetector(
          onTap: list.untappdUsername != null && list.untappdListId != null
              ? () => launchUrl(
                    Uri.parse(
                      'https://untappd.com/user/${list.untappdUsername}/lists/${list.untappdListId}',
                    ),
                  )
              : null,
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_download_outlined,
                    size: 18.r,
                    color: colors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (list.untappdUsername != null)
                        Text(
                          'Importert fra @${list.untappdUsername}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      SizedBox(height: 1.h),
                      Text(
                        syncedText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Neste automatiske synkronisering ved midnatt',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (list.untappdUsername != null && list.untappdListId != null)
                  Icon(
                    Icons.open_in_new,
                    size: 18.r,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
