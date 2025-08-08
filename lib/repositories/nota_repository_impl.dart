import 'package:bdm_vendas/repositories/nota_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nota.dart';

class NotaRepositoryImpl extends NotaRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Nota>> getNotas() async {
    final snapshot = await _firestore
        .collection('notas')
        .orderBy('dataCriacao', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => Nota.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> addNota(Nota nota) {
    return _firestore.collection('notas').add(nota.toMap());
  }
}