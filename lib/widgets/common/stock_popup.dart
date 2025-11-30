import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../../services/api.dart';

List<StockInfo> sortStockListByStores(
    List<StockInfo> stockList, List storeList) {
  final storeNames = storeList.map((e) => e.name).toList();
  Map<String, int> order = {
    for (var key in storeNames) key: storeNames.indexOf(key)
  };
  final filteredList =
      stockList.where((s) => order.containsKey(s.storeName)).toList();
  filteredList
      .sort((a, b) => order[a.storeName]!.compareTo(order[b.storeName]!));
  return filteredList;
}

void showStockPopup({
  required BuildContext context,
  required int productId,
  String? productName,
  List<StockInfo>? preloadedStock,
}) {
  final filters = Provider.of<Filter>(context, listen: false);
  final client = Provider.of<HttpClient>(context, listen: false).apiClient;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (context) => GestureDetector(
      onTap: () => Navigator.pop(context),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Icon(Icons.store_outlined, size: 20.r),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lagerstatus',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (productName != null) ...[
                              SizedBox(height: 2.h),
                              Text(
                                productName,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          size: 24.r,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant),
                Expanded(
                  child: _StockListContent(
                    productId: productId,
                    preloadedStock: preloadedStock,
                    filters: filters,
                    client: client,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _StockListContent extends StatefulWidget {
  const _StockListContent({
    required this.productId,
    required this.filters,
    required this.client,
    required this.scrollController,
    this.preloadedStock,
  });

  final int productId;
  final List<StockInfo>? preloadedStock;
  final Filter filters;
  final dynamic client;
  final ScrollController scrollController;

  @override
  State<_StockListContent> createState() => _StockListContentState();
}

class _StockListContentState extends State<_StockListContent> {
  List<StockInfo> _stockList = [];

  @override
  Widget build(BuildContext context) {
    if (widget.preloadedStock != null && widget.filters.storeList.isNotEmpty) {
      _stockList = sortStockListByStores(
          widget.preloadedStock!, widget.filters.storeList);
      return _buildStockList(context);
    }

    return FutureBuilder<List<StockInfo>>(
      future: ApiHelper.getProductStock(widget.client, widget.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 24.r,
              height: 24.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasData &&
            snapshot.data!.isNotEmpty &&
            widget.filters.storeList.isNotEmpty) {
          _stockList =
              sortStockListByStores(snapshot.data!, widget.filters.storeList);
        }

        return _buildStockList(context);
      },
    );
  }

  Widget _buildStockList(BuildContext context) {
    if (_stockList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48.r,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 12.h),
            Text(
              'Ikke på lager i dine butikker',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: _stockList.length,
      separatorBuilder: (context, _) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      itemBuilder: (context, index) {
        final stock = _stockList[index];
        return FadeIn(
          duration: Duration(milliseconds: 150 + (index * 30)),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18.r,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    stock.storeName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: stock.quantity > 5
                        ? Colors.green.withValues(alpha: 0.15)
                        : stock.quantity > 0
                            ? Colors.orange.withValues(alpha: 0.15)
                            : Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${stock.quantity} stk',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: stock.quantity > 5
                          ? Colors.green.shade700
                          : stock.quantity > 0
                              ? Colors.orange.shade700
                              : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
