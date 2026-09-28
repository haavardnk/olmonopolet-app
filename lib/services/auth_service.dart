import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final Future<void> _googleSignInReady =
      GoogleSignIn.instance.initialize();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<GoogleSignInAccount?> _authenticateWithGoogle() async {
    await _googleSignInReady;
    try {
      return await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _authenticateWithGoogle();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Google-innlogging ble avbrutt.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);

    final displayName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].where((n) => n != null && n.isNotEmpty).join(' ');

    if (displayName.isNotEmpty &&
        (userCredential.user?.displayName == null ||
            userCredential.user!.displayName!.isEmpty)) {
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();
    }

    return userCredential;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccountWithEmail(
    String email,
    String password,
  ) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _googleSignInReady;
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
  }

  Future<void> reauthenticateWithGoogle() async {
    final googleUser = await _authenticateWithGoogle();
    if (googleUser == null) return;
    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );
    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  Future<void> reauthenticateWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [],
      nonce: nonce,
    );
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    await _auth.currentUser?.reauthenticateWithCredential(oauthCredential);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  const FirebaseAuthException({required this.code, required this.message});

  @override
  String toString() => message;
}
