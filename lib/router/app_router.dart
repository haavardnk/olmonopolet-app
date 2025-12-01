import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/product_overview_tab.dart';
import '../screens/release_tab.dart';
import '../screens/stock_change_tab.dart';
import '../screens/cart_tab.dart';
import '../screens/product_detail_screen.dart';
import '../models/product.dart';
import '../models/release.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/products',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return HomeScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/products',
              builder: (context, state) => const ProductOverviewTab(),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final product = state.extra as Product?;
                    return ProductDetailScreen(
                      productId: id,
                      product: product,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/releases',
              builder: (context, state) => const ReleaseTab(),
              routes: [
                GoRoute(
                  path: ':name',
                  builder: (context, state) {
                    final name = Uri.decodeComponent(
                        state.pathParameters['name']!.replaceAll('-', ' '));
                    final release = state.extra as Release?;
                    return ProductOverviewTab(
                      release: release,
                      releaseName: release == null ? name : null,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: ':id',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        final product = state.extra as Product?;
                        return ProductDetailScreen(
                          productId: id,
                          product: product,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stock',
              builder: (context, state) => const StockChangeTab(),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final product = state.extra as Product?;
                    return ProductDetailScreen(
                      productId: id,
                      product: product,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartTab(),
              routes: [
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    final product = state.extra as Product?;
                    return ProductDetailScreen(
                      productId: id,
                      product: product,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
