import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_image/shimmer_image.dart';

import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context);
    return Drawer(
      elevation: 20,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 70),
          if (authData.isAuth)
            Column(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundImage: NetworkImage(authData.userAvatarUrl),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  authData.userName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          const Divider(),
          authData.isAuth
              ? ListTile(
                  trailing: const Icon(Icons.exit_to_app),
                  title: const Text('Logg ut'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                    authData.logout();
                  },
                )
              : ListTile(
                  trailing: const Icon(Icons.exit_to_app),
                  title: const Text('Logg inn'),
                  onTap: () {
                    authData.skipLogin(false);
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/powered_by_untappd.png',
                  width: 100,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
