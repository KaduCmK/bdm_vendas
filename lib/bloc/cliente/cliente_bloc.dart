import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/repositories/cliente/cliente_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteBloc extends Bloc<ClienteEvent, ClienteState> {
  final Logger _logger = Logger();
  final ClienteRepository _repository;

  ClienteBloc({required ClienteRepository repository})
    : _repository = repository,
      super(ClienteInitial()) {
    on<LoadClientes>(_onLoadClientes);
    on<AddCliente>(_onAddCliente);
  }

  void _onLoadClientes(LoadClientes event, Emitter<ClienteState> emit) async {
    emit(ClienteLoading());
    try {
      final clientes = await _repository.getClientes();
      emit(ClienteLoaded(clientes));
    } catch (e) {
      emit(ClienteError("Falha ao carregar clientes: ${e.toString()}"));
    }
  }

  void _onAddCliente(AddCliente event, Emitter<ClienteState> emit) async {
    try {
      emit(ClienteLoading());
      await _repository.addCliente(event.nome);
      final newClientes = await _repository.getClientes();

      emit(ClienteLoaded(newClientes));
    } catch (e) {
      _logger.e(e.toString());
      emit(ClienteError("Falha ao adicionar cliente: ${e.toString()}"));
    }
  }
}
