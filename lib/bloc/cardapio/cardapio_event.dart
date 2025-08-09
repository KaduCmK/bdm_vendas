part of 'cardapio_bloc.dart';

abstract class CardapioEvent extends Equatable {
  const CardapioEvent();

  @override
  List<Object> get props => [];
}

class LoadCardapioItens extends CardapioEvent {}

class AddCardapioItem extends CardapioEvent {
  final CardapioItem item;

  const AddCardapioItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateCardapioItem extends CardapioEvent {
  final CardapioItem item;

  const UpdateCardapioItem(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteCardapioItem extends CardapioEvent {
  final String id;

  const DeleteCardapioItem(this.id);

  @override
  List<Object> get props => [id];
}