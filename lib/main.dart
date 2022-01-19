import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import './screens/tabs_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './providers/filter.dart';
import './providers/auth.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Filter(),
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        Provider.of<Filter>(ctx, listen: false).loadLastStore();
        return MaterialApp(
          scrollBehavior: MyCustomScrollBehavior(),
          title: 'Ølmonopolet',
          theme: ThemeData(
            primarySwatch: Colors.pink,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
            }),
          ),
          home: auth.isAuthOrSkipLogin
              ? const TabsScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
        );
      }),
    );
  }
}
