import 'dart:io';
import 'dart:ui' as ui;

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:beermonopoly/main.dart';
import 'package:beermonopoly/providers/auth.dart';

final String _outputDir = Platform.isAndroid
    ? '${Directory.systemTemp.path}/beermonopoly_screenshots'
    : '/tmp/beermonopoly_screenshots';

Future<void> saveScreenshot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await binding.takeScreenshot(name);

  final renderObject = tester.binding.rootElement!.renderObject!;
  final layer = renderObject.debugLayer! as OffsetLayer;
  final image = await layer.toImage(renderObject.paintBounds);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;

  final suffix = Platform.isAndroid ? '_android' : '_ios';
  final dir = Directory(_outputDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File('$_outputDir/$name$suffix.png');
  file.writeAsBytesSync(bytes.buffer.asUint8List());
  // ignore: avoid_print
  print('Screenshot saved: ${file.path}');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Store Screenshots', () {
    testWidgets('capture all screenshots', (tester) async {
      await dotenv.load(fileName: '.env');
      await Firebase.initializeApp();

      SharedPreferences.setMockInitialValues({
        'changelog_seen_version': '3.0.1',
        'rateMyApp_launchTimes': 0,
      });

      const testEmail = String.fromEnvironment('TEST_EMAIL');
      const testPassword = String.fromEnvironment('TEST_PASSWORD');
      if (testEmail.isEmpty || testPassword.isEmpty) {
        fail(
          'Pass credentials via --dart-define: '
          '--dart-define=TEST_EMAIL=... --dart-define=TEST_PASSWORD=...',
        );
      }

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Force dark mode
      final themeContext = tester.element(find.byType(MaterialApp).first);
      AdaptiveTheme.of(themeContext).setDark();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Dismiss any remaining popups (bottom sheets / dialogs)
      final bottomSheets = find.byType(BottomSheet);
      if (bottomSheets.evaluate().isNotEmpty) {
        await tester.tapAt(const Offset(0, 0));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      final auth = tester.element(find.byType(MaterialApp).first).read<Auth>();
      await auth.signInWithEmail(testEmail, testPassword);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 1. Set category filter to Øl, then take products overview
      final filterIconForCategory = find.byIcon(Icons.tune);
      if (filterIconForCategory.evaluate().isNotEmpty) {
        await tester.tap(filterIconForCategory.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final olChip = find.text('Øl');
        if (olChip.evaluate().isNotEmpty) {
          await tester.tap(olChip.first, warnIfMissed: false);
          await tester.pumpAndSettle();
        }

        // Close the filter sheet
        await tester.tapAt(const Offset(0, 0));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      if (Platform.isAndroid) {
        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
      }

      await saveScreenshot(binding, tester, '01-Oversikt');

      // 2. Filter sheet
      final filterIcon = find.byIcon(Icons.tune);
      if (filterIcon.evaluate().isNotEmpty) {
        await tester.tap(filterIcon.first, warnIfMissed: false);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await saveScreenshot(binding, tester, '02-Filter');
        await tester.tapAt(const Offset(0, 0));
        await tester.pumpAndSettle();
      }

      // 3. Tap first product for detail
      final productTaps = find.byType(InkWell);
      if (productTaps.evaluate().length > 2) {
        await tester.tap(productTaps.at(2));
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await saveScreenshot(binding, tester, '03-Detaljer');

        final context = tester.element(find.byType(Scaffold).last);
        GoRouter.of(context).pop();
        await tester.pumpAndSettle();
      }

      // 4. Release tab
      final releaseTab = find.text('Lanseringer');
      if (releaseTab.evaluate().isNotEmpty) {
        await tester.tap(releaseTab.last);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await saveScreenshot(binding, tester, '04-Lanseringer');
      }

      // 5. Stock changes tab
      final stockTab = find.text('Lager');
      if (stockTab.evaluate().isNotEmpty) {
        await tester.tap(stockTab.last);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Tap the "Velg butikk" button in the center of the screen
        final selectStoreButton = find.text('Velg butikk');
        if (selectStoreButton.evaluate().isNotEmpty) {
          await tester.tap(selectStoreButton.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(seconds: 3));

          // Search for a store to narrow down the list
          final searchField = find.byType(TextField);
          if (searchField.evaluate().isNotEmpty) {
            await tester.enterText(searchField.first, 'Grünerløkka');
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }

          // Tap the first store in the filtered list
          final storeTiles = find.byType(ListTile);
          if (storeTiles.evaluate().isNotEmpty) {
            await tester.tap(storeTiles.first, warnIfMissed: false);
            await tester.pumpAndSettle(const Duration(seconds: 5));
          }
        }
        await saveScreenshot(binding, tester, '05-Lager');
      }

      // 6. Lists tab
      final listsTab = find.text('Lister');
      if (listsTab.evaluate().isNotEmpty) {
        await tester.tap(listsTab.last);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await saveScreenshot(binding, tester, '06-Lister');

        // 7. List detail — tap first list
        final firstListName = find.text('Handleliste');
        if (firstListName.evaluate().isNotEmpty) {
          await tester.tap(firstListName.first, warnIfMissed: false);
          await tester.pumpAndSettle(const Duration(seconds: 3));
          await saveScreenshot(binding, tester, '07-Listedetaljer');

          final listContext = tester.element(find.byType(Scaffold).last);
          GoRouter.of(listContext).pop();
          await tester.pumpAndSettle();
        }
      }

      // 8. Sign-in screen (sign out first, then navigate)
      await auth.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final productsTab = find.text('Produkter');
      if (productsTab.evaluate().isNotEmpty) {
        await tester.tap(productsTab.last);
        await tester.pumpAndSettle();
      }

      // Open drawer to find profile/sign-in
      await tester.dragFrom(
        tester.getTopLeft(find.byType(Scaffold).first),
        const Offset(300, 0),
      );
      await tester.pumpAndSettle();

      final signInLink = find.textContaining('Logg inn');
      if (signInLink.evaluate().isNotEmpty) {
        await tester.tap(signInLink.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await saveScreenshot(binding, tester, '08-Logginn');
      }
    });
  });
}
