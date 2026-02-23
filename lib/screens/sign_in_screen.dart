import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<Auth>();
      if (_isLogin) {
        await auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await auth.createAccountWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
    } catch (e) {
      setState(() => _errorMessage = _mapAuthError(
          e is FirebaseException ? e.code : 'unknown'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<Auth>().signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _mapAuthError(
            e is FirebaseAuthException ? e.code : 'unknown'));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<Auth>().signInWithApple();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _mapAuthError(
            e is FirebaseAuthException ? e.code : 'unknown'));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(
          () => _errorMessage = 'Skriv inn e-postadressen din først.');
      return;
    }

    try {
      await context.read<Auth>().sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-post for tilbakestilling av passord er sendt.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapAuthError(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'Kunne ikke sende e-post.');
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Ugyldig e-postadresse.';
      case 'user-disabled':
        return 'Denne kontoen er deaktivert.';
      case 'user-not-found':
        return 'Ingen konto funnet med denne e-postadressen.';
      case 'wrong-password':
        return 'Feil passord.';
      case 'invalid-credential':
        return 'Feil e-post eller passord.';
      case 'email-already-in-use':
        return 'Denne e-postadressen er allerede i bruk.';
      case 'weak-password':
        return 'Passordet er for svakt. Bruk minst 6 tegn.';
      case 'operation-not-allowed':
        return 'Denne innloggingsmetoden er ikke aktivert.';
      case 'sign-in-cancelled':
        return 'Innlogging ble avbrutt.';
      case 'account-exists-with-different-credential':
        return 'En konto eksisterer allerede med en annen innloggingsmetode.';
      default:
        return 'Noe gikk galt. Prøv igjen.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Logg inn' : 'Opprett konto'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.h),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Image.asset(
                    'assets/images/logo_transparent.png',
                    width: 80.r,
                    height: 80.r,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: Text(
                  _isLogin ? 'Velkommen tilbake!' : 'Opprett din konto',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  _isLogin
                      ? 'Logg inn for å synkronisere dine data'
                      : 'Registrer deg for å komme i gang',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              _buildSocialButton(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: _googleIcon(colors),
                label: 'Fortsett med Google',
                colors: colors,
              ),
              SizedBox(height: 12.h),

              if (Platform.isIOS) ...[
                _buildSocialButton(
                  onPressed: _isLoading ? null : _handleAppleSignIn,
                  icon: Icon(Icons.apple, size: 24.r),
                  label: 'Fortsett med Apple',
                  colors: colors,
                  filled: true,
                ),
                SizedBox(height: 12.h),
              ],

              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(child: Divider(color: colors.outlineVariant)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'eller',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.outlineVariant)),
                ],
              ),
              SizedBox(height: 20.h),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'E-post',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Skriv inn e-postadressen din.';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Ugyldig e-postadresse.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleEmailAuth(),
                      decoration: InputDecoration(
                        labelText: 'Passord',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Skriv inn passordet ditt.';
                        }
                        if (!_isLogin && value.length < 6) {
                          return 'Passordet må være minst 6 tegn.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (_isLogin) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    child: Text(
                      'Glemt passord?',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(height: 8.h),
              ],

              if (_errorMessage != null) ...[
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          size: 18.r, color: colors.error),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              SizedBox(height: 8.h),
              FilledButton(
                onPressed: _isLoading ? null : _handleEmailAuth,
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, 52.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Logg inn' : 'Opprett konto',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? 'Har du ikke en konto?'
                        : 'Har du allerede en konto?',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                            }),
                    child: Text(
                      _isLogin ? 'Registrer deg' : 'Logg inn',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
    required ColorScheme colors,
    bool filled = false,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 52.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        side: filled ? BorderSide.none : BorderSide(color: colors.outline),
        backgroundColor: filled ? colors.onSurface : null,
        foregroundColor: filled ? colors.surface : colors.onSurface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _googleIcon(ColorScheme colors) {
    return SizedBox(
      width: 24.r,
      height: 24.r,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final whitePaint = Paint()..color = Colors.white;

    canvas.drawCircle(center, radius, bluePaint);
    canvas.drawCircle(center, radius * 0.58, whitePaint);

    final clipRect = Rect.fromLTWH(w * 0.48, 0, w * 0.52, h);
    canvas.save();
    canvas.clipRect(clipRect);
    canvas.drawCircle(center, radius, bluePaint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w * 0.48, h * 0.5));
    canvas.drawCircle(center, radius, redPaint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, h * 0.5, w * 0.48, h * 0.5));
    canvas.drawCircle(center, radius, yellowPaint);
    canvas.restore();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(w * 0.48, h * 0.5, w * 0.52, h * 0.5));
    canvas.drawCircle(center, radius, greenPaint);
    canvas.restore();

    canvas.drawCircle(center, radius * 0.52, whitePaint);

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.48, h * 0.38, w * 0.48, h * 0.24),
      Radius.circular(h * 0.04),
    );
    canvas.drawRRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
