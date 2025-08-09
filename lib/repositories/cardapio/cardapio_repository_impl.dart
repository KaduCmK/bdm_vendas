import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bdm_vendas/repositories/cardapio/cardapio_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardapioRepositoryImpl extends CardapioRepository {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'cardapio';

  @override
  Future<List<CardapioItem>> getCardapioItens() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => CardapioItem.fromMap(doc)).toList();
  }

  @override
  Future<void> addCardapioItem(CardapioItem item) {
    return _firestore.collection(_collection).add(item.toMap());
  }

  @override
  Future<void> updateCardapioItem(CardapioItem item) {
    return _firestore.collection(_collection).doc(item.id).update(item.toMap());
  }

  @override
  Future<void> deleteCardapioItem(String id) {
    return _firestore.collection(_collection).doc(id).delete();
  }
}