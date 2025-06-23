import 'package:bdm_vendas/ui/web/screens/dashboard.dart';
import 'package:go_router/go_router.dart';

final routes = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder:
          (context, state) => Dashboard(),
    ),
  ],
);
