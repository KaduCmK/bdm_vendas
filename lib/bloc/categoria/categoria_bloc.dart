// categoria_bloc.dart
import 'package:bdm_vendas/models/cardapio/categoria.dart';
import 'package:bdm_vendas/repositories/categoria/categoria_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'categoria_event.dart';
part 'categoria_state.dart';

class CategoriaBloc extends Bloc<CategoriaEvent, CategoriaState> {
  final CategoriaRepository _repository;

  CategoriaBloc({required CategoriaRepository repository})
      : _repository = repository,
        super(CategoriaInitial()) {
    on<LoadCategorias>(_onLoadCategorias);
    on<AddCategoria>(_onAddCategoria);
    on<DeleteCategoria>(_onDeleteCategoria);
  }

  Future<void> _onLoadCategorias(LoadCategorias event, Emitter<CategoriaState> emit) async {
    emit(CategoriaLoading());
    try {
      final categorias = await _repository.getCategorias();
      emit(CategoriaLoaded(categorias));
    } catch (e) {
      emit(CategoriaError("Falha ao carregar categorias: ${e.toString()}"));
    }
  }

  Future<void> _onAddCategoria(AddCategoria event, Emitter<CategoriaState> emit) async {
    await _repository.addCategoria(event.categoria);
    add(LoadCategorias());
  }

  Future<void> _onDeleteCategoria(DeleteCategoria event, Emitter<CategoriaState> emit) async {
    await _repository.deleteCategoria(event.id);
    add(LoadCategorias());
  }
}