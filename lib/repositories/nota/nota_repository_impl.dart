import 'dart:async';

import 'package:bdm_vendas/models/produto.dart';
import 'package:bdm_vendas/repositories/nota/nota_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nota.dart';

class NotaRepositoryImpl extends NotaRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Nota>> getNotas() async {
    final snapshot = await _firestore
        .collection('notas')
        .orderBy('dataCriacao', descending: true)
        .get();

    final notas = await Future.wait(snapshot.docs.map((doc) async {
      var nota = Nota.fromMap(doc);
      if (nota.isSplitted) {
        final produtosSnapshot =
            await doc.reference.collection('produtos').get();
        final produtos = produtosSnapshot.docs
            .map((produtoDoc) => Produto.fromMap(produtoDoc.data()))
            .toList();
        nota = nota.copyWith(produtos: produtos);
      }
      return nota;
    }).toList());

    return notas;
  }

  @override
  Future<Nota> getNota(String id) async {
    final doc = await _firestore.collection('notas').doc(id).get();
    if (!doc.exists) {
      throw Exception('Nota não encontrada.');
    }

    var nota = Nota.fromMap(doc);
    if (nota.isSplitted) {
      final produtosSnapshot = await doc.reference.collection('produtos').get();
      final produtos = produtosSnapshot.docs
          .map((produtoDoc) => Produto.fromMap(produtoDoc.data()))
          .toList();
      nota = nota.copyWith(produtos: produtos);
    }

    return nota;
  }

  @override
  Stream<Nota> watchNota(String id) {
    return _firestore.collection('notas').doc(id).snapshots().asyncMap((doc) async {
      if (!doc.exists) {
        throw Exception('Nota não encontrada.');
      }
      var nota = Nota.fromMap(doc);
      if (nota.isSplitted) {
        final produtosSnapshot =
            await doc.reference.collection('produtos').get();
        final produtos = produtosSnapshot.docs
            .map((produtoDoc) => Produto.fromMap(produtoDoc.data()))
            .toList();
        nota = nota.copyWith(produtos: produtos);
      }
      return nota;
    });
  }

  @override
  Future<Nota> addNota(Nota nota) async {
    final docRef = await _firestore.collection('notas').add(nota.toMap());
    if (nota.isSplitted) {
      final batch = _firestore.batch();
      for (var produto in nota.produtos) {
        final produtoRef = docRef.collection('produtos').doc();
        batch.set(produtoRef, produto.copyWith(id: produtoRef.id).toMap());
      }
      await batch.commit();
    }
    return nota.copyWith(id: docRef.id);
  }

  @override
  Future<void> updateNota(Nota nota) {
    if (nota.id == null) {
      throw Exception('Nota não possui um ID válido.');
    }

    return _firestore.collection('notas').doc(nota.id).update(nota.toMap());
  }

  @override
  Future<void> addProdutoToNota(String notaId, Produto produto) {
    final produtoRef =
        _firestore.collection('notas').doc(notaId).collection('produtos').doc();
    return produtoRef.set(produto.copyWith(id: produtoRef.id).toMap());
  }

  @override
  Future<void> addProdutosToNota(String notaId, List<Produto> produtos) {
    final batch = _firestore.batch();
    final notaRef = _firestore.collection('notas').doc(notaId);

    for (var produto in produtos) {
      final produtoRef = notaRef.collection('produtos').doc();
      batch.set(produtoRef, produto.copyWith(id: produtoRef.id).toMap());
    }

    return batch.commit();
  }

  @override
  Future<void> removeProdutoFromNota(String notaId, Produto produto) async {
    final query = _firestore
        .collection('notas')
        .doc(notaId)
        .collection('produtos')
        .where('nome', isEqualTo: produto.nome)
        .orderBy('createdAt', descending: true)
        .limit(1);

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }
}