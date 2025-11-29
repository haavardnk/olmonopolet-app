import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';

import '../../helpers/api_helper.dart';
import './product_item.dart';
import '../../models/product.dart';
import '../../models/release.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import './pagination_indicators/first_page_error_indicator.dart';
import './pagination_indicators/new_page_error_indicator.dart';
import './pagination_indicators/no_items_found_indicator.dart';

class ProductList extends StatefulWidget {
  final Release? release;

  const ProductList({Key? key, this.release}) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductList> {
  int _pageSize = 14;
  late PagingController<int, Product> _pagingController;
  bool _listenerAdded = false;
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Product>(
      getNextPageKey: (state) {
        if (state.keys == null || state.keys!.isEmpty) return 1;
        if (state.lastPageIsEmpty) return null;
        return state.keys!.last + 1;
      },
      fetchPage: (pageKey) async {
        final result = await _fetchPage(pageKey);
        if (pageKey == 1) {
          _initialLoadComplete = true;
        }
        return result;
      },
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
    if (_initialLoadComplete) {
      _pagingController.refresh();
    }
  }

  Future<List<Product>> _fetchPage(int pageKey) async {
    final filters = Provider.of<Filter>(context, listen: false).filters;
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final newItems = await retry(
      () => ApiHelper.getProductList(
          client, pageKey, filters, _pageSize, widget.release),
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
                ? PagedListView<int, Product>.separated(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<Product>(
                      animateTransitions: true,
                      transitionDuration: const Duration(milliseconds: 300),
                      invisibleItemsThreshold: 5,
                      itemBuilder: (context, item, index) => ProductItem(
                        product: item,
                        release: widget.release,
                      ),
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
                    separatorBuilder: (context, index) => const Divider(
                      height: 0,
                    ),
                  )
                : PagedGridView<int, Product>(
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
                    builderDelegate: PagedChildBuilderDelegate<Product>(
                      animateTransitions: true,
                      transitionDuration: const Duration(milliseconds: 300),
                      invisibleItemsThreshold: 5,
                      itemBuilder: (context, item, index) => ProductItem(
                        product: item,
                        release: widget.release,
                      ),
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
