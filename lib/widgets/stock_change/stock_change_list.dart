import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';

import './stock_change_item.dart';
import '../../services/api.dart';
import '../../models/stock_change.dart';
import '../../providers/auth.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../products/pagination_indicators/first_page_error_indicator.dart';
import '../products/pagination_indicators/new_page_error_indicator.dart';
import '../products/pagination_indicators/no_items_found_indicator.dart';

class StockChangeList extends StatefulWidget {
  const StockChangeList({super.key});

  @override
  StockChangeListViewState createState() => StockChangeListViewState();
}

class StockChangeListViewState extends State<StockChangeList> {
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
      Provider.of<Auth>(context, listen: false).addListener(_onAuthChanged);
    }
  }

  void _onFilterChanged() {
    if (mounted) {
      _pagingController.refresh();
    }
  }

  void _onAuthChanged() {
    if (mounted) {
      _pagingController.refresh();
    }
  }

  Future<List<StockChange>> _fetchPage(int pageKey) async {
    final filters = Provider.of<Filter>(context, listen: false).filters;
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final auth = Provider.of<Auth>(context, listen: false);
    final token = auth.isSignedIn ? await auth.getIdToken() : null;
    return retry(
      () => ApiHelper.getStockChangeList(
        client,
        store: filters.stockChangeStoreId,
        page: pageKey,
        pageSize: _pageSize,
        token: token,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _pageSize = 1.sw ~/ 371.r >= 2 ? 24 : 14;

    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Consumer<Filter>(
        builder: (context, filterProvider, child) {
          return PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) => 1.sw < 600
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
                      mainAxisExtent: 148.r,
                      crossAxisCount: 1.sw ~/ 371.r <= 4 ? 1.sw ~/ 371.r : 4,
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
      Provider.of<Auth>(context, listen: false)
          .removeListener(_onAuthChanged);
    } catch (_) {}
    _pagingController.dispose();
    super.dispose();
  }
}
