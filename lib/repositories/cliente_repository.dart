import 'package:bdm_vendas/models/cliente.dart';

abstract class ClienteRepository {
  Stream<List<Cliente>> getClientes();
  Future<void> addCliente(String nome);
}