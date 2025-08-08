part of 'nota_bloc.dart';

abstract class NotaState extends Equatable {
  const NotaState();

  @override
  List<Object> get props => [];
}

class NotaInitial extends NotaState {}

class NotaLoading extends NotaState {}

class NotaLoaded extends NotaState {
  final List<Nota> notas;

  const NotaLoaded(this.notas);

  @override
  List<Object> get props => [notas];
}

class NotaError extends NotaState {
  final String message;

  const NotaError(this.message);

  @override
  List<Object> get props => [message];
}