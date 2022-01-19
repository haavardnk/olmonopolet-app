import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../helpers/api_helper.dart';
import './product_item.dart';
import '../../models/product.dart';
import '../../providers/filter.dart';
import '../../providers/auth.dart';
import './pagination_indicators/first_page_error_indicator.dart';
import './pagination_indicators/new_page_error_indicator.dart';
import './pagination_indicators/no_items_found_indicator.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({Key? key}) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  static const _pageSize = 15;
  final PagingController<int, Product> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      final filters = Provider.of<Filter>(context, listen: false).filters;
      final authToken = Provider.of<Auth>(context, listen: false).token;
      _fetchPage(pageKey, filters, authToken);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey, Filter filters, String apiToken) async {
    try {
      final newItems =
          await ApiHelper.getProductList(pageKey, filters, apiToken);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => _pagingController.refresh(),
      ),
      child: Consumer<Filter>(
        builder: (context, value, _) {
          _pagingController.refresh();
          return PagedListView<int, Product>.separated(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Product>(
              itemBuilder: (context, item, index) => ProductItem(
                product: item,
              ),
              firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
                onTryAgain: () => _pagingController.refresh(),
              ),
              newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                onTap: () => _pagingController.retryLastFailedRequest(),
              ),
              noItemsFoundIndicatorBuilder: (_) =>
                  const NoItemsFoundIndicator(),
            ),
            separatorBuilder: (context, index) => Divider(
              height: 0,
              color: Colors.grey[400],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
