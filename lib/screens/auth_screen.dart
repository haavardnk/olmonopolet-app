import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final loading = false;

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(30, 120, 30, 30),
        children: <Widget>[
          Center(
            child:
                Image.asset('assets/images/logo_transparent.png', height: 250),
          ),
          const SizedBox(
            height: 70,
          ),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
              ),
              onPressed: () async {
                try {
                  await authData.authenticate();
                } catch (error) {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      title: const Text('Feil'),
                      content: const Text(
                          'Det har oppstått en feil med innloggingen. '
                          'Sjekk internett tilkoblingen din eller prøv igjen senere.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/untappd_logo.png',
                    height: 30,
                    color: Colors.white,
                  ),
                  const Text(
                    'Logg inn med Untappd',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Column()
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          const Center(
            child: Text(
              'eller',
              style: TextStyle(fontSize: 13, color: Color(0xFFaaaaaa)),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: TextButton(
              child: const Text('Logg inn senere...'),
              onPressed: () => authData.skipLogin(true),
            ),
          ),
        ],
      ),
    );
  }
}
