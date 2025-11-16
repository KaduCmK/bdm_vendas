import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Produto extends Equatable {
  final String? id;
  final String nome;
  final double valorUnitario;
  final DateTime createdAt;

  const Produto({
    this.id,
    this.nome = '',
    this.valorUnitario = 0.0,
    required this.createdAt,
  });

  // Calcula o subtotal do produto
  double get subtotal => valorUnitario;

  Produto copyWith({
    String? id,
    String? nome,
    double? valorUnitario,
    DateTime? createdAt,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valorUnitario': valorUnitario,
      'createdAt': createdAt,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'] ?? '',
      valorUnitario: (map['valorUnitario'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, nome, valorUnitario, createdAt];
}