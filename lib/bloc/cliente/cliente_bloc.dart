import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/repositories/cliente_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'cliente_event.dart';
part 'cliente_state.dart';

class ClienteBloc extends Bloc<ClienteEvent, ClienteState> {
  final ClienteRepository _repository;

  // Lista temporária pra simular o banco de dados
  final List<Cliente> _mockClientes = [
    Cliente(
      id: '1',
      nome: 'Barbearia do Zé',
      dataCriacao: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Cliente(
      id: '2',
      nome: 'Mercearia da Maria',
      dataCriacao: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  ClienteBloc({required ClienteRepository repository})
    : _repository = repository,
      super(ClienteInitial()) {
    on<LoadClientes>(_onLoadClientes);
    on<AddCliente>(_onAddCliente);
  }

  void _onLoadClientes(LoadClientes event, Emitter<ClienteState> emit) async {
    emit(ClienteLoading());
    try {
      // TODO: Substituir a lógica mock pela chamada real ao Firebase
      // final clientes = await _clienteRepository.getClientes();
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simula latência da rede
      emit(ClienteLoaded(List.from(_mockClientes)));
    } catch (e) {
      emit(ClienteError("Falha ao carregar clientes: ${e.toString()}"));
    }
  }

  void _onAddCliente(AddCliente event, Emitter<ClienteState> emit) async {
    final currentState = state;
    if (currentState is ClienteLoaded) {
      emit(ClienteLoading());
      // TODO: Substituir a lógica mock pela chamada real ao Firebase
      /*
      await FirebaseFirestore.instance.collection('clientes').add({
        'nome': event.nome,
        'dataCriacao': Timestamp.now(),
      });
      */
      final novoCliente = Cliente(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: event.nome,
        dataCriacao: DateTime.now(),
      );
      _mockClientes.add(novoCliente);
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Simula latência

      emit(ClienteLoaded(List.from(_mockClientes)));
    }
  }
}
