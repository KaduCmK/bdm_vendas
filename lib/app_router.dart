import 'package:bdm_vendas/ui/web/screens/dashboard.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final routes = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => Dashboard()),
    GoRoute(
      path: '/cardapio',
      builder: (context, state) => Placeholder(child: Text('Cardapio')),
    ),
  ],
);
