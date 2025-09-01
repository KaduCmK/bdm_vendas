import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bdm_vendas/repositories/cardapio/cardapio_repository.dart';
import 'package:logger/logger.dart';

part 'cardapio_event.dart';
part 'cardapio_state.dart';

class CardapioBloc extends Bloc<CardapioEvent, CardapioState> {
  final _logger = Logger();
  final CardapioRepository _repository;

  CardapioBloc({required CardapioRepository repository})
    : _repository = repository,
      super(CardapioInitial()) {
    on<LoadCardapioItens>(_onLoadCardapioItens);
    on<AddCardapioItem>(_onAddCardapioItem);
    on<UpdateCardapioItem>(_onUpdateCardapioItem);
    on<DeleteCardapioItem>(_onDeleteCardapioItem);
  }

  void _onLoadCardapioItens(
    LoadCardapioItens event,
    Emitter<CardapioState> emit,
  ) async {
    emit(CardapioLoading());
    try {
      final itens = await _repository.getCardapioItens();
      emit(CardapioLoaded(itens));
    } catch (e) {
      _logger.e(e);
      emit(CardapioError("Falha ao carregar o cardápio: ${e.toString()}"));
    }
  }

  void _onAddCardapioItem(
    AddCardapioItem event,
    Emitter<CardapioState> emit,
  ) async {
    try {
      await _repository.addCardapioItem(event.item);
      add(LoadCardapioItens()); // Recarrega a lista
    } catch (e) {
      emit(CardapioError("Falha ao adicionar item: ${e.toString()}"));
    }
  }

  void _onUpdateCardapioItem(
    UpdateCardapioItem event,
    Emitter<CardapioState> emit,
  ) async {
    try {
      await _repository.updateCardapioItem(event.item);
      add(LoadCardapioItens()); // Recarrega a lista
    } catch (e) {
      emit(CardapioError("Falha ao atualizar item: ${e.toString()}"));
    }
  }

  void _onDeleteCardapioItem(
    DeleteCardapioItem event,
    Emitter<CardapioState> emit,
  ) async {
    try {
      await _repository.deleteCardapioItem(event.id);
      add(LoadCardapioItens()); // Recarrega a lista
    } catch (e) {
      emit(CardapioError("Falha ao excluir item: ${e.toString()}"));
    }
  }
}
