import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';

import './stock_change_item.dart';
import '../../helpers/api_helper.dart';
import '../../models/stock_change.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../products/pagination_indicators/first_page_error_indicator.dart';
import '../products/pagination_indicators/new_page_error_indicator.dart';
import '../products/pagination_indicators/no_items_found_indicator.dart';

class StockChangeList extends StatefulWidget {
  const StockChangeList({Key? key}) : super(key: key);

  @override
  _StockChangeListViewState createState() => _StockChangeListViewState();
}

class _StockChangeListViewState extends State<StockChangeList> {
  int _pageSize = 14;
  late DateTime lastDate;
  late PagingController<int, StockChange> _pagingController;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, StockChange>(
      getNextPageKey: (state) {
        if (state.keys == null || state.keys!.isEmpty) return 1;
        if (state.lastPageIsEmpty) return null;
        return state.keys!.last + 1;
      },
      fetchPage: (pageKey) => _fetchPage(pageKey),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      _listenerAdded = true;
      Provider.of<Filter>(context, listen: false).addListener(_onFilterChanged);
    }
  }

  void _onFilterChanged() {
    _pagingController.refresh();
  }

  Future<List<StockChange>> _fetchPage(int pageKey) async {
    final filters = Provider.of<Filter>(context, listen: false).filters;
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final newItems = await retry(
      () => ApiHelper.getStockChangeList(
          client, pageKey, _pageSize, filters.stockChangeStoreId),
    );
    return newItems;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    _pageSize = mediaQueryData.size.width ~/
                (350 + mediaQueryData.textScaleFactor * 21) >=
            2
        ? 24
        : 14;

    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Consumer<Filter>(
        builder: (context, filterProvider, child) {
          return PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) => mediaQueryData
                        .size.width <
                    600
                ? PagedListView<int, StockChange>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<StockChange>(
                      animateTransitions: true,
                      transitionDuration: const Duration(milliseconds: 300),
                      invisibleItemsThreshold: 5,
                      itemBuilder: (context, item, index) {
                        final items = state.items;
                        if (index == 0 || items == null) {
                          return StockChangeItem(stockChange: item);
                        } else {
                          return StockChangeItem(
                            stockChange: item,
                            lastDate: items[index - 1].stockUnstockAt,
                          );
                        }
                      },
                      firstPageErrorIndicatorBuilder: (_) =>
                          FirstPageErrorIndicator(
                        onTryAgain: () => _pagingController.refresh(),
                      ),
                      newPageErrorIndicatorBuilder: (_) =>
                          NewPageErrorIndicator(
                        onTap: () => _pagingController.fetchNextPage(),
                      ),
                      noItemsFoundIndicatorBuilder: (_) =>
                          const NoItemsFoundIndicator(),
                    ),
                  )
                : PagedGridView<int, StockChange>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    showNewPageProgressIndicatorAsGridChild: false,
                    showNewPageErrorIndicatorAsGridChild: false,
                    showNoMoreItemsIndicatorAsGridChild: false,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisExtent: 100 + mediaQueryData.textScaleFactor * 48,
                      crossAxisCount: mediaQueryData.size.width ~/
                                  (350 + mediaQueryData.textScaleFactor * 21) <=
                              4
                          ? mediaQueryData.size.width ~/
                              (350 + mediaQueryData.textScaleFactor * 21)
                          : 4,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<StockChange>(
                      animateTransitions: true,
                      transitionDuration: const Duration(milliseconds: 300),
                      invisibleItemsThreshold: 5,
                      itemBuilder: (context, item, index) =>
                          StockChangeItem(stockChange: item),
                      firstPageErrorIndicatorBuilder: (_) =>
                          FirstPageErrorIndicator(
                        onTryAgain: () => _pagingController.refresh(),
                      ),
                      newPageErrorIndicatorBuilder: (_) =>
                          NewPageErrorIndicator(
                        onTap: () => _pagingController.fetchNextPage(),
                      ),
                      noItemsFoundIndicatorBuilder: (_) =>
                          const NoItemsFoundIndicator(),
                    ),
                  ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    try {
      Provider.of<Filter>(context, listen: false)
          .removeListener(_onFilterChanged);
    } catch (_) {}
    _pagingController.dispose();
    super.dispose();
  }
}
