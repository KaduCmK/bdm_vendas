import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Enum para o tipo do item, garantindo que só pode ser Comida ou Bebida
enum TipoItem { comida, bebida }

extension TipoItemExtension on TipoItem {
  String get displayName {
    switch (this) {
      case TipoItem.comida:
        return 'Comidas';
      case TipoItem.bebida:
        return 'Bebidas';
    }
  }
}

class CardapioItem extends Equatable {
  final String? id;
  final String nome;
  final String? descricao;
  final double preco;
  final TipoItem tipo;
  final DocumentReference categoriaId;

  const CardapioItem({
    this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.tipo,
    required this.categoriaId,
  });

  @override
  List<Object?> get props => [id, nome, descricao, preco, tipo, categoriaId];

  CardapioItem copyWith({
    String? id,
    String? nome,
    String? descricao,
    double? preco,
    TipoItem? tipo,
    DocumentReference? categoriaId,
  }) {
    return CardapioItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      tipo: tipo ?? this.tipo,
      categoriaId: categoriaId ?? this.categoriaId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipo': tipo.name,
      'categoriaId': categoriaId,
    };
  }

  factory CardapioItem.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CardapioItem(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      preco: (data['preco'] ?? 0.0).toDouble(),
      // Converte a string de volta para o enum
      tipo: TipoItem.values.byName(data['tipo'] ?? 'comidas'),
      categoriaId: data['categoriaId'] ?? '',
    );
  }
}
