// lib/service_locator.dart
import 'package:bdm_vendas/repositories/cardapio/cardapio_repository.dart';
import 'package:bdm_vendas/repositories/cardapio/cardapio_repository_impl.dart';
import 'package:bdm_vendas/repositories/categoria/categoria_repository.dart';
import 'package:bdm_vendas/repositories/categoria/categoria_repository_impl.dart';
import 'package:bdm_vendas/repositories/cliente/cliente_repository.dart';
import 'package:bdm_vendas/repositories/nota/nota_repository.dart';
import 'package:bdm_vendas/repositories/nota/nota_repository_impl.dart';
import 'package:get_it/get_it.dart';
import 'package:bdm_vendas/repositories/cliente/cliente_repository_impl.dart';

// Cria uma instância global do GetIt
final sl = GetIt.instance;

void setupLocator() {
  // --- Repositórios ---
  sl.registerLazySingleton<ClienteRepository>(() => ClienteRepositoryImpl());
  sl.registerLazySingleton<NotaRepository>(() => NotaRepositoryImpl());
  sl.registerLazySingleton<CardapioRepository>(() => CardapioRepositoryImpl());
  sl.registerLazySingleton<CategoriaRepository>(() => CategoriaRepositoryImpl());
}
