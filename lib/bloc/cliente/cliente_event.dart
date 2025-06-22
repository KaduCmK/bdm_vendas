part of 'cliente_bloc.dart';

abstract class ClienteEvent extends Equatable {
  const ClienteEvent();

  @override
  List<Object> get props => [];
}

class LoadClientes extends ClienteEvent {}

class AddCliente extends ClienteEvent {
  final String nome;

  const AddCliente(this.nome);

  @override
  List<Object> get props => [nome];
}
