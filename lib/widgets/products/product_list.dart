import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:retry/retry.dart';

import '../../services/api.dart';
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

  const ProductList({super.key, this.release});

  @override
  ProductListViewState createState() => ProductListViewState();
}

class ProductListViewState extends State<ProductList> {
  static const int _defaultPageSize = 14;
  int _pageSize = _defaultPageSize;
  late PagingController<int, Product> _pagingController;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Product>(
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pagingController.fetchNextPage();
        }
      });
    }
  }

  void _onFilterChanged() {
    if (mounted) {
      _pagingController.refresh();
      _pagingController.fetchNextPage();
    }
  }

  Future<List<Product>> _fetchPage(int pageKey) async {
    final filters = Provider.of<Filter>(context, listen: false).filters;
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final newItems = await retry(
      () => ApiHelper.getProductList(
          client, pageKey, filters, _pageSize, widget.release),
    );
    if (newItems.isNotEmpty && newItems.length < _pageSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pagingController.value = _pagingController.value.copyWith(
            hasNextPage: false,
          );
        }
      });
    }
    return newItems;
  }

  @override
  Widget build(BuildContext context) {
    _pageSize = 1.sw ~/ 371.r >= 2 ? 24 : 14;

    return RefreshIndicator(
      onRefresh: () => Future.sync(() {
        _pagingController.refresh();
        _pagingController.fetchNextPage();
      }),
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => 1.sw < 600
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
                    onTryAgain: () {
                      _pagingController.refresh();
                      _pagingController.fetchNextPage();
                    },
                  ),
                  newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
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
                  mainAxisExtent: 148.r,
                  crossAxisCount: 1.sw ~/ 371.r <= 4 ? 1.sw ~/ 371.r : 4,
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
                    onTryAgain: () {
                      _pagingController.refresh();
                      _pagingController.fetchNextPage();
                    },
                  ),
                  newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                    onTap: () => _pagingController.fetchNextPage(),
                  ),
                  noItemsFoundIndicatorBuilder: (_) =>
                      const NoItemsFoundIndicator(),
                ),
              ),
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
