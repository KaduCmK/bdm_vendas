import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';

abstract class CardapioRepository {
  Future<List<CardapioItem>> getCardapioItens();
  Future<void> addCardapioItem(CardapioItem item);
  Future<void> updateCardapioItem(CardapioItem item);
  Future<void> deleteCardapioItem(String id);
}
