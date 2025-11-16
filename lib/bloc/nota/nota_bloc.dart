import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:equatable/equatable.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/repositories/nota/nota_repository.dart';
import 'package:logger/logger.dart';

part 'nota_event.dart';
part 'nota_state.dart';

class NotaBloc extends Bloc<NotaEvent, NotaState> {
  final Logger _logger = Logger();
  final NotaRepository _repository;
  StreamSubscription? _notaSubscription;

  NotaBloc({required NotaRepository repository})
      : _repository = repository,
        super(NotaInitial()) {
    on<LoadNotas>(_onLoadNotas);
    on<LoadNota>(_onLoadNota);
    on<WatchNota>(_onWatchNota);
    on<_NotaUpdated>(_onNotaUpdated);
    on<AddNota>(_onAddNota);
    on<UpdateNota>(_onUpdateNota);
    on<AddProduto>(_onAddProduto);
    on<AddProdutos>(_onAddProdutos);
    on<RemoveProduto>(_onRemoveProduto);
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
      final nota = await _repository.getNota(event.notaId);
      emit(SingleNotaLoaded(nota));
    } catch (e) {
      emit(NotaError("Falha ao carregar nota: ${e.toString()}"));
    }
  }

  void _onWatchNota(WatchNota event, Emitter<NotaState> emit) async {
    emit(NotaLoading());
    _notaSubscription?.cancel();
    _notaSubscription = _repository.watchNota(event.notaId).listen(
      (nota) {
        add(_NotaUpdated(nota));
      },
      onError: (e) {
        _logger.e(e);
        emit(NotaError("Falha ao carregar nota: ${e.toString()}"));
      },
    );
  }

  void _onNotaUpdated(_NotaUpdated event, Emitter<NotaState> emit) {
    emit(SingleNotaLoaded(event.nota));
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

  void _onAddProduto(AddProduto event, Emitter<NotaState> emit) async {
    try {
      await _repository.addProdutoToNota(event.notaId, event.produto);
      add(LoadNotas());
    } catch (e) {
      _logger.e(e.toString());
      emit(NotaError("Falha ao adicionar produto: ${e.toString()}"));
    }
  }

  void _onAddProdutos(AddProdutos event, Emitter<NotaState> emit) async {
    try {
      await _repository.addProdutosToNota(event.notaId, event.produtos);
      add(LoadNotas());
    } catch (e) {
      _logger.e(e.toString());
      emit(NotaError("Falha ao adicionar produtos: ${e.toString()}"));
    }
  }

  void _onRemoveProduto(RemoveProduto event, Emitter<NotaState> emit) async {
    try {
      await _repository.removeProdutoFromNota(event.notaId, event.produto);
      add(LoadNotas());
    } catch (e) {
      _logger.e(e.toString());
      emit(NotaError("Falha ao remover produto: ${e.toString()}"));
    }
  }
}
