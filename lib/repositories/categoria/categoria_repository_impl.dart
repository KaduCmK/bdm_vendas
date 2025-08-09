import 'package:bdm_vendas/models/cardapio/categoria.dart';
import 'package:bdm_vendas/repositories/categoria/categoria_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaRepositoryImpl extends CategoriaRepository {
  final _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'categorias';

  @override
  Future<List<Categoria>> getCategorias() async {
    final snapshot = await _firestore.collection(_collectionPath).orderBy('nome').get();
    return snapshot.docs.map((doc) => Categoria.fromMap(doc)).toList();
  }

  @override
  Future<void> addCategoria(Categoria categoria) {
    return _firestore.collection(_collectionPath).add(categoria.toMap());
  }

  @override
  Future<void> deleteCategoria(String id) {
    return _firestore.collection(_collectionPath).doc(id).delete();
  }
}