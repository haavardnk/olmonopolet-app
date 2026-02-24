import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/product_overview_tab.dart';
import '../screens/release_tab.dart';
import '../screens/stock_change_tab.dart';
import '../screens/lists_tab.dart';
import '../screens/list_detail_screen.dart';
import '../screens/shared_list_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/profile_screen.dart';
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
              path: '/lists',
              builder: (context, state) => const ListsTab(),
              routes: [
                GoRoute(
                  path: 'shared/:token',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final token = state.pathParameters['token']!;
                    return SharedListScreen(shareToken: token);
                  },
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return ListDetailScreen(listId: id);
                  },
                  routes: [
                    GoRoute(
                      path: ':productId',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) {
                        final productId =
                            int.parse(state.pathParameters['productId']!);
                        final product = state.extra as Product?;
                        return ProductDetailScreen(
                          productId: productId,
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
    ),
    GoRoute(
      path: '/sign-in',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/profile',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
