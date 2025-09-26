import 'package:bdm_vendas/repositories/cliente/cliente_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/cliente.dart';

class ClienteRepositoryImpl extends ClienteRepository {
  final _firestore = FirebaseFirestore.instance;

  // Carrega a lista completa de clientes do Firestore uma única vez.
  @override
  Future<List<Cliente>> getClientes() async {
    final snapshot = await _firestore.collection('clientes').get();

    final clientes =
        snapshot.docs.map((doc) => Cliente.fromMap(doc.id, doc.data())).toList()
          ..sort(
            (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
          );

    return clientes;
  }

  // Adiciona um novo cliente
  @override
  Future<void> addCliente(String nome) {
    final nomeCapitalizado = nome[0].toUpperCase() + nome.substring(1);
    return _firestore.collection('clientes').add({
      'nome': nomeCapitalizado,
      'dataCriacao': FieldValue.serverTimestamp(), // Usa a hora do servidor
    });
  }
}
