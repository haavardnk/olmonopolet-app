import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './screens/product_detail_screen.dart';
import 'screens/home_screen.dart';
import './screens/about_screen.dart';
import './providers/filter.dart';
import './providers/cart.dart';
import './providers/http_client.dart';
import './assets/color_schemes.g.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const channel = AndroidNotificationChannel(
    'olmonopolet',
    'Ølmonopolet Notifikasjoner',
    description:
        'Denne kanalen er brukt for å annonsere tilgjengelighet av nye Ølslipp og annen funksjonalitet.',
    importance: Importance.high,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 7,
    minLaunches: 10,
    remindDays: 7,
    remindLaunches: 10,
  );

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      dark: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => HttpClient(),
          ),
          ChangeNotifierProxyProvider<HttpClient, Filter>(
            create: (ctx) => Filter(),
            update: (ctx, client, previousFilter) =>
                previousFilter!..update(client.apiClient),
          ),
          ChangeNotifierProxyProvider<HttpClient, Cart>(
            create: (ctx) => Cart(),
            update: (ctx, client, previousCart) =>
                previousCart!..update(client.apiClient),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(402, 874),
          minTextAdapt: true,
          builder: (context, child) {
            Provider.of<Filter>(context, listen: false).loadFilters();

            return MaterialApp(
              localizationsDelegates: const [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              debugShowCheckedModeBanner: false,
              scrollBehavior: MyCustomScrollBehavior(),
              title: 'Ølmonopolet',
              theme: theme,
              darkTheme: darkTheme,
              home: RateMyAppBuilder(
                builder: (context) => const HomeScreen(),
                onInitialized: (context, rateMyApp) {
                  if (rateMyApp.shouldOpenDialog) {
                    rateMyApp.showStarRateDialog(
                      context,
                      title: 'Rate Ølmonopolet!',
                      message:
                          'Bruk et øyeblikk på å gi en rating til Ølmonopolet også, det hjelper veldig!',
                      actionsBuilder: (context, stars) {
                        return [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () async {
                              await rateMyApp.callEvent(
                                  RateMyAppEventType.rateButtonPressed);
                              Navigator.pop<RateMyAppDialogButton>(
                                  context, RateMyAppDialogButton.rate);
                            },
                          ),
                        ];
                      },
                      onDismissed: () => rateMyApp
                          .callEvent(RateMyAppEventType.laterButtonPressed),
                    );
                  }
                },
              ),
              routes: {
                ProductDetailScreen.routeName: (ctx) =>
                    const ProductDetailScreen(),
                AboutScreen.routeName: (ctx) => const AboutScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
