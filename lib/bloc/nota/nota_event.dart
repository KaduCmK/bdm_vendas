part of 'nota_bloc.dart';

abstract class NotaEvent extends Equatable {
  const NotaEvent();

  @override
  List<Object> get props => [];
}

class LoadNotas extends NotaEvent {}

class LoadNota extends NotaEvent {
  final String notaId;

  const LoadNota(this.notaId);

  @override
  List<Object> get props => [notaId];
}

class WatchNota extends NotaEvent {
  final String notaId;

  const WatchNota(this.notaId);

  @override
  List<Object> get props => [notaId];
}
class _NotaUpdated extends NotaEvent {
  final Nota nota;

  const _NotaUpdated(this.nota);

  @override
  List<Object> get props => [nota];
}

class AddNota extends NotaEvent {
  final Nota nota;

  const AddNota(this.nota);

  @override
  List<Object> get props => [nota];
}

class UpdateNota extends NotaEvent {
  final Nota nota;

  const UpdateNota(this.nota);

  @override
  List<Object> get props => [nota];
}

class AddProduto extends NotaEvent {
  final String notaId;
  final Produto produto;

  const AddProduto(this.notaId, this.produto);

  @override
  List<Object> get props => [notaId, produto];
}

class AddProdutos extends NotaEvent {
  final String notaId;
  final List<Produto> produtos;

  const AddProdutos(this.notaId, this.produtos);

  @override
  List<Object> get props => [notaId, produtos];
}

class RemoveProduto extends NotaEvent {
  final String notaId;
  final Produto produto;

  const RemoveProduto(this.notaId, this.produto);

  @override
  List<Object> get props => [notaId, produto];
}
