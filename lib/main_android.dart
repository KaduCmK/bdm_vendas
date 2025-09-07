import 'package:bdm_vendas/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SolicitacoesApp());
}

class SolicitacoesApp extends StatelessWidget {
  const SolicitacoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BDM - Solicitações',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true
      ),
      home: const Placeholder(),
    );
  }
}
