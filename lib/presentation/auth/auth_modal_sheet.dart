import 'package:flutter/material.dart';
import 'auth_screen.dart';

export 'auth_screen.dart';

/// Wrapper for backwards compatibility
class AuthModalSheet extends StatelessWidget {
  final bool isRegisterInitial;
  final VoidCallback onSuccess;

  const AuthModalSheet({
    super.key,
    required this.isRegisterInitial,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      isRegisterInitial: isRegisterInitial,
      onSuccess: onSuccess,
    );
  }
}
