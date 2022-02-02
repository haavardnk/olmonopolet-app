import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'screens/home_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/about_screen.dart';
import './providers/filter.dart';
import './providers/auth.dart';
import './providers/cart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        backgroundColor: Colors.grey[100],
        iconTheme: IconThemeData(color: Colors.grey[800]),
        appBarTheme: AppBarTheme(
          color: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        accentColor: Colors.pink,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Filter(),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
        ],
        child: Consumer<Auth>(builder: (ctx, auth, _) {
          Provider.of<Filter>(ctx, listen: false).loadLastStore();
          return MaterialApp(
            scrollBehavior: MyCustomScrollBehavior(),
            title: 'Ølmonopolet',
            theme: theme,
            darkTheme: darkTheme,
            // theme: ThemeData(
            //   primarySwatch: Colors.pink,
            //   visualDensity: VisualDensity.adaptivePlatformDensity,
            //   pageTransitionsTheme: const PageTransitionsTheme(builders: {
            //     TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            //     TargetPlatform.android: ZoomPageTransitionsBuilder(),
            //   }),
            // ),
            home: auth.isAuthOrSkipLogin
                ? const HomeScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? const SplashScreen()
                            : const AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) =>
                  const ProductDetailScreen(),
              AboutScreen.routeName: (ctx) => const AboutScreen(),
            },
          );
        }),
      ),
    );
  }
}
