import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class Auth with ChangeNotifier {
  final AuthService _authService = AuthService();
  late final StreamSubscription<User?> _authSubscription;
  User? _user;
  bool _initialized = false;

  Auth() {
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen((user) {
      _user = user;
      _initialized = true;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get initialized => _initialized;
  String get displayName =>
      _user?.displayName ?? _user?.email?.split('@').first ?? '';
  String? get email => _user?.email;
  String? get photoUrl => _user?.photoURL;

  List<String> get providers =>
      _user?.providerData.map((p) => p.providerId).toList() ?? [];

  bool get hasGoogleProvider => providers.contains('google.com');
  bool get hasAppleProvider => providers.contains('apple.com');
  bool get hasEmailProvider => providers.contains('password');

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> signInWithApple() async {
    await _authService.signInWithApple();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _authService.signInWithEmail(email, password);
  }

  Future<void> createAccountWithEmail(String email, String password) async {
    await _authService.createAccountWithEmail(email, password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
  }

  Future<void> reauthenticateWithGoogle() async {
    await _authService.reauthenticateWithGoogle();
  }

  Future<void> reauthenticateWithApple() async {
    await _authService.reauthenticateWithApple();
  }

  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _user?.getIdToken(forceRefresh) ?? Future.value(null);

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
