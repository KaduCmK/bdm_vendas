import 'package:bdm_vendas/app_router.dart';
import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/firebase_options.dart';
import 'package:bdm_vendas/repositories/cliente_repository.dart';
import 'package:bdm_vendas/repositories/nota_repository.dart';
import 'package:bdm_vendas/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
          create:
              (context) =>
                  NotaBloc(repository: sl<NotaRepository>())..add(LoadNotas()),
        ),
        BlocProvider(
          create:
              (context) =>
                  ClienteBloc(repository: sl<ClienteRepository>())
                    ..add(LoadClientes()),
        ),
      ],
      child: MaterialApp.router(
        title: 'BDM-Vendas ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: routes,
      ),
    );
  }
}
