import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:retry/retry.dart';

import '../providers/http_client.dart';
import '../widgets/drawer/app_drawer.dart';
import '../widgets/release/release_item.dart';
import '../widgets/products/pagination_indicators/first_page_error_indicator.dart';
import '../widgets/products/pagination_indicators/new_page_error_indicator.dart';
import '../models/release.dart';
import '../services/api.dart';

class ReleaseTab extends StatefulWidget {
  const ReleaseTab({super.key});

  @override
  State<ReleaseTab> createState() => _ReleaseTabState();
}

class _ReleaseTabState extends State<ReleaseTab> {
  static const int _pageSize = 15;
  late PagingController<int, Release> _pagingController;

  @override
  void initState() {
    initializeDateFormatting('nb_NO', null);
    super.initState();
    _pagingController = PagingController<int, Release>(
      getNextPageKey: (state) {
        if (state.keys == null || state.keys!.isEmpty) return 1;
        if (state.lastPageIsEmpty) return null;
        return state.keys!.last + 1;
      },
      fetchPage: (pageKey) => _fetchPage(pageKey),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pagingController.fetchNextPage();
      }
    });
  }

  Future<List<Release>> _fetchPage(int pageKey) async {
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final releases = await retry(
      () =>
          ApiHelper.getReleaseList(client, page: pageKey, pageSize: _pageSize),
    );
    if (releases.isNotEmpty && releases.length < _pageSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _pagingController.value = _pagingController.value.copyWith(
            hasNextPage: false,
          );
        }
      });
    }
    return releases;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FittedBox(
          fit: BoxFit.contain,
          child: Text('Nyhetslanseringer'),
        ),
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() {
          _pagingController.refresh();
          _pagingController.fetchNextPage();
        }),
        child: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, Release>.separated(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<Release>(
              animateTransitions: true,
              transitionDuration: const Duration(milliseconds: 300),
              invisibleItemsThreshold: 5,
              itemBuilder: (context, item, index) => ReleaseItem(release: item),
              firstPageErrorIndicatorBuilder: (_) => FirstPageErrorIndicator(
                onTryAgain: () {
                  _pagingController.refresh();
                  _pagingController.fetchNextPage();
                },
              ),
              newPageErrorIndicatorBuilder: (_) => NewPageErrorIndicator(
                onTap: () => _pagingController.fetchNextPage(),
              ),
              noItemsFoundIndicatorBuilder: (_) => Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100.h),
                  child: Text(
                    'Ingen lanseringer funnet',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            separatorBuilder: (context, index) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
