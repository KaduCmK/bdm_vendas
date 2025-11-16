import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/produto.dart';

abstract class NotaRepository {
  Future<List<Nota>> getNotas();
  Future<Nota> getNota(String id);
  Stream<Nota> watchNota(String id);
  Future<Nota> addNota(Nota nota);
  Future<void> updateNota(Nota nota);
  Future<void> addProdutoToNota(String notaId, Produto produto);
  Future<void> addProdutosToNota(String notaId, List<Produto> produtos);
  Future<void> removeProdutoFromNota(String notaId, Produto produto);
}