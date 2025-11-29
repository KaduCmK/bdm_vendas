import 'dart:async';

import 'package:bdm_vendas/models/pagamento.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:bdm_vendas/repositories/nota/nota_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nota.dart';

class NotaRepositoryImpl extends NotaRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<bool> _isSplitted(String notaId) async {
    final doc = await _firestore.collection('notas').doc(notaId).get();
    if (!doc.exists) {
      return false;
    }
    return doc.data()!['isSplitted'] ?? false;
  }

  @override
  Future<List<Nota>> getNotas() async {
    final snapshot = await _firestore
        .collection('notas')
        .orderBy('dataCriacao', descending: true)
        .get();

    final futures = snapshot.docs.map((doc) async {
      var nota = Nota.fromMap(doc);
      if (nota.isSplitted) {
        try {
          final produtosSnapshot =
              await doc.reference.collection('produtos').get();
          final produtos = produtosSnapshot.docs
              .map((produtoDoc) => Produto.fromMap(produtoDoc.data()))
              .toList();

          final pagamentosSnapshot =
              await doc.reference.collection('pagamentos').get();
          final pagamentos = pagamentosSnapshot.docs
              .map((pagamentoDoc) => Pagamento.fromMap(pagamentoDoc))
              .toList();

          nota = nota.copyWith(produtos: produtos, pagamentos: pagamentos);
        } catch (e) {
          // Log the error or handle it gracefully
          // For now, we'll just return the nota without the sub-collections
          print('Error fetching sub-collections for nota ${nota.id}: $e');
        }
      }
      return nota;
    }).toList();

    return Future.wait(futures);
  }

  @override
  Future<Nota> getNota(String id) async {
    final doc = await _firestore.collection('notas').doc(id).get();
    if (!doc.exists) {
      throw Exception('Nota não encontrada.');
    }

    var nota = Nota.fromMap(doc);
    if (nota.isSplitted) {
      try {
        final produtosSnapshot =
            await doc.reference.collection('produtos').get();
        final produtos = produtosSnapshot.docs
            .map((produtoDoc) => Produto.fromMap(produtoDoc.data()))
            .toList();

        final pagamentosSnapshot =
            await doc.reference.collection('pagamentos').get();
        final pagamentos = pagamentosSnapshot.docs
            .map((pagamentoDoc) => Pagamento.fromMap(pagamentoDoc))
            .toList();

        nota = nota.copyWith(produtos:produtos, pagamentos: pagamentos);
      } catch (e) {
        // Log the error or handle it gracefully
        // For now, we'll just return the nota without the sub-collections
        print('Error fetching sub-collections for nota ${nota.id}: $e');
      }
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
        try {
          final produtosSnapshot =
              await doc.reference.collection('produtos').get();
          final produtos = produtosSnapshot.docs
              .map((produtoDoc) => Produto.fromMap(produtoDoc.data()))
              .toList();

          final pagamentosSnapshot =
              await doc.reference.collection('pagamentos').get();
          final pagamentos = pagamentosSnapshot.docs
              .map((pagamentoDoc) => Pagamento.fromMap(pagamentoDoc))
              .toList();

          nota = nota.copyWith(produtos: produtos, pagamentos: pagamentos);
        } catch (e) {
          // Log the error or handle it gracefully
          // For now, we'll just return the nota without the sub-collections
          print('Error fetching sub-collections for nota ${nota.id}: $e');
        }
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
  Future<void> addProdutoToNota(String notaId, Produto produto) async {
    if (await _isSplitted(notaId)) {
      final produtoRef = _firestore
          .collection('notas')
          .doc(notaId)
          .collection('produtos')
          .doc();
      return produtoRef.set(produto.copyWith(id: produtoRef.id).toMap());
    }

    final nota = await getNota(notaId);
    final produtos = nota.produtos..add(produto);
    return updateNota(nota.copyWith(produtos: produtos));
  }

  @override
  Future<void> addProdutosToNota(
      String notaId, List<Produto> produtos) async {
    if (await _isSplitted(notaId)) {
      final batch = _firestore.batch();
      final notaRef = _firestore.collection('notas').doc(notaId);

      for (var produto in produtos) {
        final produtoRef = notaRef.collection('produtos').doc();
        batch.set(produtoRef, produto.copyWith(id: produtoRef.id).toMap());
      }

      return batch.commit();
    }

    final nota = await getNota(notaId);
    final newProdutos = nota.produtos..addAll(produtos);
    return updateNota(nota.copyWith(produtos: newProdutos));
  }

  @override
  Future<void> removeProdutoFromNota(String notaId, Produto produto) async {
    if (await _isSplitted(notaId)) {
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
      return;
    }

    final nota = await getNota(notaId);
    final produtos = nota.produtos;
    final index = produtos.lastIndexWhere((p) => p.nome == produto.nome);
    if (index != -1) {
      produtos.removeAt(index);
    }
    return updateNota(nota.copyWith(produtos: produtos));
  }

  @override
  Future<void> deleteNota(String notaId) async {
    final notaRef = _firestore.collection('notas').doc(notaId);
    final produtosSnapshot = await notaRef.collection('produtos').get();

    final batch = _firestore.batch();
    for (var doc in produtosSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    await notaRef.delete();
  }

  @override
  Future<void> addPagamentoToNota(String notaId, Pagamento pagamento) {
    return _firestore.collection('notas').doc(notaId).collection('pagamentos').add(pagamento.toMap());
  }
}
