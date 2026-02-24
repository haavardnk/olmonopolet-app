import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_list.dart';
import '../providers/http_client.dart';
import '../services/list_api.dart';
import '../utils/list_helpers.dart';
import '../widgets/common/error_state.dart';
import '../widgets/lists/cellar_stats.dart';
import '../widgets/lists/list_item_row.dart';
import '../widgets/lists/shopping_total_bar.dart';

class SharedListScreen extends StatefulWidget {
  final String shareToken;

  const SharedListScreen({super.key, required this.shareToken});

  @override
  State<SharedListScreen> createState() => _SharedListScreenState();
}

class _SharedListScreenState extends State<SharedListScreen> {
  SharedUserList? _list;
  Map<String, Product> _products = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSharedList());
  }

  Future<void> _loadSharedList() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client =
          Provider.of<HttpClient>(context, listen: false).apiClient;
      final list = await ListApi.fetchSharedList(client, widget.shareToken);
      if (!mounted) return;
      setState(() => _list = list);
      await _loadProducts();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Kunne ikke laste listen');
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadProducts() async {
    if (_list == null || _list!.items.isEmpty) return;

    try {
      final map = await loadProductsForItems(context, _list!.items);
      if (map != null && mounted) {
        setState(() => _products = map);
      }
    } catch (_) {}
  }

  double _calculateTotal() {
    if (_list == null) return 0;
    return calculateListTotal(
      items: _list!.items,
      products: _products,
      precomputedTotal: _list!.totalPrice,
    );
  }

  int _totalUnits() {
    if (_list == null) return 0;
    int total = 0;
    for (final item in _list!.items) {
      total += item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delt liste')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _list == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delt liste')),
        body: ErrorState(
          message: _error ?? 'Listen ble ikke funnet',
          onRetry: _loadSharedList,
        ),
      );
    }

    final list = _list!;

    return Scaffold(
      appBar: AppBar(title: Text(list.name)),
      body: _buildBody(list),
      bottomNavigationBar: list.listType == ListType.shopping
          ? ShoppingTotalBar(
              totalPrice: _calculateTotal(),
              itemCount: list.items.length,
              totalUnits: _totalUnits(),
            )
          : null,
    );
  }

  Widget _buildBody(SharedUserList list) {
    if (list.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadSharedList,
        child: _buildEmptyState(list),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSharedList,
      child: Column(
        children: [
          _buildListHeader(list),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
              itemCount: list.items.length,
              itemBuilder: (context, index) {
                final item = list.items[index];
                return ListItemRow(
                  key: ValueKey(item.id),
                  item: item,
                  product: _products[item.productId],
                  listType: list.listType,
                  onRemove: () {},
                  routePrefix: '/lists/shared',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader(SharedUserList list) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Column(
        children: [
          if (list.userName != null) ...[
            _buildInfoCard(list, colors),
            SizedBox(height: 10.h),
          ],
          if (list.description != null && list.description!.isNotEmpty) ...[
            Text(
              list.description!,
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          if (list.listType == ListType.cellar && list.stats != null) ...[
            CellarStatsWidget(stats: list.stats!),
          ],
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildInfoCard(SharedUserList list, ColorScheme colors) {
    final isPast = list.isPast == true;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 18.r,
                  color: colors.secondary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delt av ${list.userName}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '${list.itemCount} produkter',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (list.storeName != null && list.listType == ListType.shopping) ...[
            Divider(
              height: 20.h,
              color: colors.secondary.withValues(alpha: 0.2),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.store,
                    size: 18.r,
                    color: colors.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.storeName!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Valgt butikk',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (list.eventDate != null) ...[
            Divider(
              height: 20.h,
              color: colors.secondary.withValues(alpha: 0.2),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isPast
                        ? colors.error.withValues(alpha: 0.15)
                        : colors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event,
                    size: 18.r,
                    color: isPast ? colors.error : colors.secondary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${list.eventDate!.day}. ${monthAbbreviations[list.eventDate!.month - 1]} ${list.eventDate!.year}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        isPast
                            ? 'Arrangementet er passert'
                            : 'Kommende arrangement',
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(SharedUserList list) {
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
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Denne delte listen har ingen produkter ennå.',
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
