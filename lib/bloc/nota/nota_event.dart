part of 'nota_bloc.dart';

abstract class NotaEvent extends Equatable {
  const NotaEvent();

  @override
  List<Object> get props => [];
}

class LoadNotas extends NotaEvent {}

class AddNota extends NotaEvent {
  final Nota nota;

  const AddNota(this.nota);

  @override
  List<Object> get props => [nota];
}