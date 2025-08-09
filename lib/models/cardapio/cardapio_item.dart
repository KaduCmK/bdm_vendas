import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// Enum para o tipo do item, garantindo que só pode ser Comida ou Bebida
enum TipoItem {
  comida,
  bebida,
}

extension TipoItemExtension on TipoItem {
  String get displayName {
    switch (this) {
      case TipoItem.comida:
        return 'Comida';
      case TipoItem.bebida:
        return 'Bebida';
    }
  }
}

class CardapioItem extends Equatable {
  final String? id;
  final String nome;
  final String? descricao;
  final double preco;
  final TipoItem tipo; 
  final String categoria;

  const CardapioItem({
    this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.tipo,
    required this.categoria,
  });

  @override
  List<Object?> get props => [id, nome, descricao, preco, tipo, categoria];

  CardapioItem copyWith({
    String? id,
    String? nome,
    String? descricao,
    double? preco,
    TipoItem? tipo,
    String? categoria,
  }) {
    return CardapioItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'tipo': tipo.name,
      'categoria': categoria,
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
      tipo: TipoItem.values.byName(data['tipo'] ?? 'comida'),
      categoria: data['categoria'] ?? '',
    );
  }
}