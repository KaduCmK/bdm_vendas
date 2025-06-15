import 'package:bdm_vendas/repositories/cliente_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';

class ClienteRepositoryImpl extends ClienteRepository {
  final _firestore = FirebaseFirestore.instance;

  // Pega uma "foto" em tempo real da coleção de clientes
  @override
  Stream<List<Cliente>> getClientes() {
    return _firestore
        .collection('clientes')
        .orderBy('nome') // Opcional: ordena por nome
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Cliente.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Adiciona um novo cliente
  @override
  Future<void> addCliente(String nome) {
    return _firestore.collection('clientes').add({
      'nome': nome,
      'dataCriacao': FieldValue.serverTimestamp(), // Usa a hora do servidor
    });
  }
}