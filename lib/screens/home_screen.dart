import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../providers/filter.dart';
import '../providers/lists.dart';
import '../router/app_router.dart';
import '../widgets/common/changelog_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.navigationShell,
  });
  static const routeName = '/tabs';

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _setupInteractedMessage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showChangelogIfNeeded(context);
    });
  }

  Future<void> _setupInteractedMessage() async {
    void handleMessage(RemoteMessage message) {
      final route = message.data['route'];
      final productId = message.data['product_id'];
      final releaseId = message.data['release_id'];

      if (route != null) {
        if (route == '/products' && productId != null) {
          goRouter.go('/products/$productId');
        } else if (route == '/release' && releaseId != null) {
          goRouter.go('/release/$releaseId');
        } else if (route == '/release') {
          goRouter.go('/release');
        } else if (route == '/stock') {
          goRouter.go('/stock');
        } else if (route == '/cart') {
          goRouter.go('/lists');
        } else {
          goRouter.go(route);
        }
      }
    }

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<Filter>(context, listen: false);
    if (!filters.storesLoading && filters.storeList.isEmpty) {
      filters.getStores();
    }
    if (!filters.releasesLoading && filters.releaseList.isEmpty) {
      filters.getReleases();
    }
    final listsProvider = Provider.of<ListsProvider>(context, listen: false);
    if (listsProvider.isAuthenticated && !listsProvider.listsLoaded && !listsProvider.loading) {
      listsProvider.fetchLists();
    }

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 64,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              );
            }
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.liquor_outlined, size: 22),
              selectedIcon: Icon(Icons.liquor, size: 22),
              label: 'Produkter',
            ),
            const NavigationDestination(
              icon: Icon(Icons.new_releases_outlined, size: 22),
              selectedIcon: Icon(Icons.new_releases, size: 22),
              label: 'Lanseringer',
            ),
            const NavigationDestination(
              icon: Icon(Icons.swap_vert_outlined, size: 22),
              selectedIcon: Icon(Icons.swap_vert, size: 22),
              label: 'Lager',
            ),
            const NavigationDestination(
              icon: Icon(Icons.list_alt_outlined, size: 22),
              selectedIcon: Icon(Icons.list_alt, size: 22),
              label: 'Lister',
            ),
          ],
        ),
      ),
    );
  }
}
