import 'package:bdm_vendas/repositories/nota/nota_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nota.dart';

class NotaRepositoryImpl extends NotaRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Nota>> getNotas() async {
    final snapshot =
        await _firestore
            .collection('notas')
            .orderBy('dataCriacao', descending: true)
            .get();

    return snapshot.docs.map((doc) => Nota.fromMap(doc)).toList();
  }

  @override
  Future<Nota> getNota(String id) async {
    final doc = await _firestore.collection('notas').doc(id).get();
    if (!doc.exists) {
      throw Exception('Nota não encontrada.');
    }
    
    return Nota.fromMap(doc);
  }

  @override
  Future<void> addNota(Nota nota) {
    return _firestore.collection('notas').add(nota.toMap());
  }

  @override
  Future<void> updateNota(Nota nota) {
    if (nota.id == null) {
      throw Exception('Nota não possui um ID válido.');
    }

    return _firestore.collection('notas').doc(nota.id).update(nota.toMap());
  }
}
