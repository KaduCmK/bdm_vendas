import 'package:bdm_vendas/ui/android/solicitacoes_screen.dart';
import 'package:bdm_vendas/ui/shared/go_router_refresh_stream.dart';
import 'package:bdm_vendas/ui/shared/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final androidRouter = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isLoggingIn = state.uri.toString() == '/login';

    if (!loggedIn && !isLoggingIn) {
      return '/login';
    }

    if (loggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const SolicitacoesScreen(),
    ),
  ],
);