import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Categoria extends Equatable {
  final String? id;
  final String nome;
  final TipoItem tipo;

  const Categoria({
    this.id,
    required this.nome,
    required this.tipo
  });

  @override
  List<Object?> get props => [id, nome, tipo];

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo.name,
    };
  }

  factory Categoria.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Categoria(
      id: doc.id,
      nome: data['nome'] ?? '',
      tipo: TipoItem.values.byName(data['tipo'] ?? 'comida'),
    );
  }
}