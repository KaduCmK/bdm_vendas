import 'package:equatable/equatable.dart';

class Produto extends Equatable {
  final String? id;
  final String nome;
  final int quantidade;
  final double valorUnitario;

  const Produto({
    this.id,
    this.nome = '',
    this.quantidade = 1,
    this.valorUnitario = 0.0,
  });

  // Calcula o subtotal do produto
  double get subtotal => quantidade * valorUnitario;

  Produto copyWith({
    String? id,
    String? nome,
    int? quantidade,
    double? valorUnitario,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      valorUnitario: valorUnitario ?? this.valorUnitario,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'] ?? '',
      quantidade: map['quantidade'] ?? 1,
      valorUnitario: (map['valorUnitario'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, nome, quantidade, valorUnitario];
}