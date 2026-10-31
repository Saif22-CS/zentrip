import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/app_routes.dart';
import '../../logic/auth_controller.dart';
import 'auth_shared.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _auth = AuthController();
  final _emailCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _sent = false;

  Timer? _timer;
  int _cooldown = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _auth.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _validEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  Future<void> _send() async {
    if (_loading || _cooldown > 0) return;
    FocusScope.of(context).unfocus();
    if (!_validEmail(_emailCtrl.text)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });

    final success = await _auth.sendResetCode(email: _emailCtrl.text.trim());

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (!success) {
      final message = _auth.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
      return;
    }

    setState(() => _sent = true);
    _startCooldown();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _cooldown = 0);
      } else {
        if (mounted) setState(() => _cooldown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      heroFraction: 0.40,
      signIcon: Icons.lock_reset_rounded,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOut,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: _sent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  // ── الحالة الأولى: إدخال البريد ──
  Widget _buildForm() {
    return Column(
      key: const ValueKey('form'),
      children: [
        const AuthTitle(
          line1: 'Forgot Your Password?',
          line2: "We'll Get You Back On Track",
          subtitle:
              "Enter the email linked to your account and we'll send you a code to reset your password.",
        ),
        const SizedBox(height: 24),
        AuthInput(
          controller: _emailCtrl,
          hint: 'Enter your email',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: _error,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        const SizedBox(height: 20),
        AuthButton(label: 'Send Reset Code', loading: _loading, onTap: _send),
        const SizedBox(height: 18),
        AuthFooterLink(
          text: 'Remembered it?',
          link: 'Back to login',
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }

  // ── الحالة الثانية: تم الإرسال ──
  Widget _buildSuccess() {
    return Column(
      key: const ValueKey('success'),
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                size: 40, color: AppColors.navy),
          ),
        ),
        const SizedBox(height: 18),
        const AuthTitle(line1: 'Check Your', line2: 'Email'),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: "We've sent a reset code to\n",
            style: GoogleFonts.poppins(
                fontSize: 12.5, color: AppColors.hint, height: 1.6),
            children: [
              TextSpan(
                text: _emailCtrl.text.trim(),
                style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),
        AuthButton(
          label: 'Enter Verification Code',
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.verifyCode,
            arguments: _emailCtrl.text.trim(),
          ),
        ),
        const SizedBox(height: 16),
        _cooldown > 0
            ? Text(
                'Resend code in 0:${_cooldown.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.hint),
              )
            : AuthFooterLink(
                text: "Didn't get the email?",
                link: 'Resend',
                onTap: _send,
              ),
        const SizedBox(height: 8),
        AuthFooterLink(
          text: 'Want to try another account?',
          link: 'Back to login',
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
