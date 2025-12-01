import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../providers/filter.dart';
import '../providers/cart.dart';
import '../router/app_router.dart';

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
  }

  Future<void> _setupInteractedMessage() async {
    void handleMessage(RemoteMessage message) {
      final route = message.data['route'];
      final productId = message.data['product_id'];
      final releaseId = message.data['release_id'];

      if (route != null) {
        if (route == '/products' && productId != null) {
          goRouter.go('/products/$productId');
        } else if (route == '/releases' && releaseId != null) {
          goRouter.go('/releases/$releaseId');
        } else if (route == '/releases') {
          goRouter.go('/releases');
        } else if (route == '/stock') {
          goRouter.go('/stock');
        } else if (route == '/cart') {
          goRouter.go('/cart');
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
    Provider.of<Cart>(context, listen: false).fetchAndSetCart();
    final filters = Provider.of<Filter>(context, listen: false);
    if (!filters.storesLoading && filters.storeList.isEmpty) {
      filters.getStores();
    }
    if (!filters.releasesLoading && filters.releaseList.isEmpty) {
      filters.getReleases();
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
            NavigationDestination(
              icon: Consumer<Cart>(
                builder: (_, cart, __) => Badge(
                  label: Text(cart.itemCount.toString()),
                  isLabelVisible: cart.itemCount > 0,
                  child: const Icon(Icons.receipt_long_outlined, size: 22),
                ),
              ),
              selectedIcon: Consumer<Cart>(
                builder: (_, cart, __) => Badge(
                  label: Text(cart.itemCount.toString()),
                  isLabelVisible: cart.itemCount > 0,
                  child: const Icon(Icons.receipt_long, size: 22),
                ),
              ),
              label: 'Handleliste',
            ),
          ],
        ),
      ),
    );
  }
}
