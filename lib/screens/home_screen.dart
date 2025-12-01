import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'product_overview_tab.dart';
import 'release_tab.dart';
import 'stock_change_tab.dart';
import 'cart_tab.dart';
import '../providers/filter.dart';
import '../providers/cart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/tabs';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PersistentTabController _controller = PersistentTabController();

  Future<void> setupInteractedMessage(
      PersistentTabController controller) async {
    void handleMessage(RemoteMessage message) {
      if (message.data['route'] == '/releases') {
        controller.jumpToTab(1);
      }
    }

    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  @override
  Widget build(BuildContext context) {
    setupInteractedMessage(_controller);
    Provider.of<Cart>(context, listen: false).fetchAndSetCart();
    final filters = Provider.of<Filter>(context, listen: false);
    if (!filters.storesLoading && filters.storeList.isEmpty) {
      filters.getStores();
    }
    if (!filters.releasesLoading && filters.releaseList.isEmpty) {
      filters.getReleases();
    }

    List<PersistentTabConfig> tabs = [
      PersistentTabConfig(
        screen: const ProductOverviewTab(),
        item: ItemConfig(
          icon: const Icon(Icons.liquor),
          activeForegroundColor: Theme.of(context).colorScheme.primary,
          inactiveForegroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveBackgroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Produkter',
        ),
      ),
      PersistentTabConfig(
        screen: const ReleaseTab(),
        item: ItemConfig(
          icon: const Icon(Icons.new_releases_outlined),
          activeForegroundColor: Theme.of(context).colorScheme.primary,
          inactiveForegroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveBackgroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Lanseringer',
        ),
      ),
      PersistentTabConfig(
        screen: const StockChangeTab(),
        item: ItemConfig(
          icon: const Icon(Icons.swap_vert),
          activeForegroundColor: Theme.of(context).colorScheme.primary,
          inactiveForegroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveBackgroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Lager inn/ut',
        ),
      ),
      PersistentTabConfig(
        screen: const CartTab(),
        item: ItemConfig(
          icon: Consumer<Cart>(
            builder: (_, cart, __) => Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              child: const Icon(Icons.receipt_long),
            ),
          ),
          activeForegroundColor: Theme.of(context).colorScheme.primary,
          inactiveForegroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          inactiveBackgroundColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          title: 'Handleliste',
        ),
      ),
    ];

    return PersistentTabView(
      controller: _controller,
      tabs: tabs,
      resizeToAvoidBottomInset: true,
      avoidBottomPadding: true,
      navBarOverlap: const NavBarOverlap.none(),
      backgroundColor: Theme.of(context).canvasColor,
      navBarBuilder: (navBarConfig) => Style6BottomNavBar(
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: Theme.of(context).canvasColor,
        ),
      ),
    );
  }
}
