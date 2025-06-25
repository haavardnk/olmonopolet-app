import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../helpers/app_launcher.dart';
import '../../screens/about_screen.dart';
import '../../utils/environment.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late AdaptiveThemeMode? _themeMode = AdaptiveThemeMode.light;
  void _getTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _themeMode = savedThemeMode;
    });
  }

  @override
  void initState() {
    _getTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 3,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 70),
          ListTile(
            trailing: Icon(
              _themeMode == AdaptiveThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            title: Text(
              _themeMode == AdaptiveThemeMode.dark ? 'Lys modus' : 'Mørk modus',
            ),
            onTap: () {
              if (_themeMode == AdaptiveThemeMode.dark) {
                _themeMode = AdaptiveThemeMode.light;
                AdaptiveTheme.of(context).setLight();
              } else {
                _themeMode = AdaptiveThemeMode.dark;
                AdaptiveTheme.of(context).setDark();
              }
            },
          ),
          const Divider(),
          ListTile(
            trailing: const Icon(Icons.facebook),
            title: const Text('Følg på Facebook'),
            onTap: () {
              AppLauncher.launchFacebook();
            },
          ),
          const Divider(),
          ListTile(
            trailing: const Icon(Icons.email),
            title: const Text('Gi tilbakemelding'),
            onTap: () {
              launchUrl(Uri.parse('mailto:${Environment.feedbackEmail}'));
            },
          ),
          const Divider(),
          ListTile(
            trailing: const Icon(Icons.info),
            title: const Text('Om'),
            onTap: () {
              pushScreen(
                context,
                settings: const RouteSettings(name: AboutScreen.routeName),
                screen: const AboutScreen(),
              );
            },
          ),
        ],
      ),
    );
  }
}
