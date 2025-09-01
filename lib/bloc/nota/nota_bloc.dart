import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/repositories/nota/nota_repository.dart';
import 'package:logger/logger.dart';

part 'nota_event.dart';
part 'nota_state.dart';

class NotaBloc extends Bloc<NotaEvent, NotaState> {
  final Logger _logger = Logger();
  final NotaRepository _repository;

  NotaBloc({required NotaRepository repository})
    : _repository = repository,
      super(NotaInitial()) {
    on<LoadNotas>(_onLoadNotas);
    on<LoadNota>(_onLoadNota);
    on<AddNota>(_onAddNota);
    on<UpdateNota>(_onUpdateNota);
  }

  void _onLoadNotas(LoadNotas event, Emitter<NotaState> emit) async {
    emit(NotaLoading());
    try {
      final notas = await _repository.getNotas();
      emit(NotaLoaded(notas));
    } catch (e) {
      emit(NotaError("Falha ao carregar notas: ${e.toString()}"));
    }
  }

  void _onLoadNota(LoadNota event, Emitter<NotaState> emit) async {
    emit(NotaLoading());
    try {
      final notas = await _repository.getNota(event.notaId);
      emit(SingleNotaLoaded(notas));
    } catch (e) {
      emit(NotaError("Falha ao carregar notas: ${e.toString()}"));
    }
  }

  void _onAddNota(AddNota event, Emitter<NotaState> emit) async {
    try {
      emit(NotaLoading());
      await _repository.addNota(event.nota);
      final newNotas = await _repository.getNotas();

      emit(NotaLoaded(newNotas));
    } catch (e) {
      _logger.e(e.toString());
      emit(NotaError("Falha ao adicionar nota: ${e.toString()}"));
    }
  }

  // Adicione este método
  void _onUpdateNota(UpdateNota event, Emitter<NotaState> emit) async {
    try {
      await _repository.updateNota(event.nota);
      final notas = await _repository.getNotas();
      emit(NotaLoaded(notas));
    } catch (e) {
      _logger.e(e.toString());
      emit(NotaError("Falha ao atualizar nota: ${e.toString()}"));
    }
  }
}
