// lib/service_locator.dart
import 'package:bdm_vendas/repositories/cliente_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:bdm_vendas/repositories/cliente_repository_impl.dart';

// Cria uma instância global do GetIt
final sl = GetIt.instance;

void setupLocator() {
  // --- Repositórios ---
  sl.registerLazySingleton<ClienteRepository>(() => ClienteRepositoryImpl());
}
