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
  final Set<String> loadingNoteIds;

  const NotaLoaded(this.notas, {this.loadingNoteIds = const {}});

  @override
  List<Object> get props => [notas, loadingNoteIds];
}

class SingleNotaLoaded extends NotaState {
  final Nota nota;
  final Set<String> loadingNoteIds;

  const SingleNotaLoaded(this.nota, {this.loadingNoteIds = const {}});

  @override
  List<Object> get props => [nota, loadingNoteIds];
}

class NotaError extends NotaState {
  final String message;

  const NotaError(this.message);

  @override
  List<Object> get props => [message];
}