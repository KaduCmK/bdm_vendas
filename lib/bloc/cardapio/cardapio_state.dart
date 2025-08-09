part of 'cardapio_bloc.dart';

abstract class CardapioState extends Equatable {
  const CardapioState();

  @override
  List<Object> get props => [];
}

class CardapioInitial extends CardapioState {}

class CardapioLoading extends CardapioState {}

class CardapioLoaded extends CardapioState {
  final List<CardapioItem> itens;

  const CardapioLoaded(this.itens);

  @override
  List<Object> get props => [itens];
}

class CardapioError extends CardapioState {
  final String message;

  const CardapioError(this.message);

  @override
  List<Object> get props => [message];
}