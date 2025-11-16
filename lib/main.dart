import 'package:bdm_vendas/app_router.dart';
import 'package:bdm_vendas/bloc/cardapio/cardapio_bloc.dart';
import 'package:bdm_vendas/bloc/categoria/categoria_bloc.dart';
import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/firebase_options.dart';
import 'package:bdm_vendas/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAuth.instance.signInAnonymously(); // Sign in anonymously here

  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NotaBloc(repository: sl())..add(LoadNotas()),
        ),
        BlocProvider(
          create:
              (context) => ClienteBloc(repository: sl())..add(LoadClientes()),
        ),
        BlocProvider(
          create:
              (context) =>
                  CardapioBloc(repository: sl())..add(LoadCardapioItens()),
        ),
        BlocProvider(
          create:
              (context) =>
                  CategoriaBloc(repository: sl())..add(LoadCategorias()),
        ),
      ],
      child: MaterialApp.router(
        title: 'BDM-Vendas ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        routerConfig: routes,
      ),
    );
  }
}
