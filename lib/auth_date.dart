import 'package:bdm_vendas/ui/web/screens/auth/signin_screen.dart';
import 'package:bdm_vendas/ui/web/screens/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInScreen();
        }
        return const Dashboard();
      },
    );
  }
}