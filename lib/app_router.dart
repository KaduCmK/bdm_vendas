import 'package:bdm_vendas/auth_date.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/cardapio_screen.dart';
import 'package:go_router/go_router.dart';

final routes = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => AuthGate()),
    GoRoute(
      path: '/cardapio',
      builder: (context, state) => const CardapioScreen(),
    ),
  ],
);
