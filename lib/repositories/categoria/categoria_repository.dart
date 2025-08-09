
import 'package:bdm_vendas/models/cardapio/categoria.dart';

abstract class CategoriaRepository {
  Future<List<Categoria>> getCategorias();
  Future<void> addCategoria(Categoria categoria);
  Future<void> deleteCategoria(String id);
}