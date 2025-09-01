import 'dart:async';

import 'package:bdm_vendas/ui/web/screens/auth/signin_screen.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/cardapio_screen.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/cardapio_tipoitem_screen.dart';
import 'package:bdm_vendas/ui/web/screens/dashboard.dart';
import 'package:bdm_vendas/ui/web/screens/view_nota/view_nota_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routes = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;
    final String location = state.uri.toString();

    final isLoggingIn = location == '/login';
    final isPublicPage = location.startsWith('/cardapio') || location.startsWith('/view-nota');

    // Se o usuário não estiver logado e não estiver indo para uma página pública, redireciona pro login
    if (!loggedIn && !isLoggingIn && !isPublicPage) {
      return '/login';
    }

    // Se o usuário estiver logado e tentando acessar a tela de login, vai pro dashboard
    if (loggedIn && isLoggingIn) {
      return '/';
    }

    // Nenhum redirecionamento necessário
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const SignInScreen()),
    GoRoute(
      path: '/cardapio',
      builder: (context, state) => const CardapioScreen(),
      routes: [
        GoRoute(
          path: ':tipo',
          pageBuilder: (context, state) {
            final tipoItem = state.pathParameters['tipo']!;

            return CustomTransitionPage(
              key: state.pageKey,
              child: CardapioTipoitemScreen(tipoItemTitulo: tipoItem),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.ease).animate(animation),
                  child: child,
                );
              },
            );
          },
        ),
      ],
    ),
    GoRoute(path: '/view-nota/:notaId', builder: (context, state) {
      final notaId = state.pathParameters['notaId']!;
      return ViewNotaScreen(notaId: notaId);
    }),
    GoRoute(path: '/', builder: (context, state) => Dashboard()),
  ],
);
