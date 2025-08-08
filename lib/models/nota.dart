import 'package:bdm_vendas/models/produto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Nota extends Equatable {
  final String? id;
  final DateTime dataCriacao;
  final List<Produto> produtos;
  final String clienteId;

  const Nota({
    this.id,
    required this.dataCriacao,
    this.produtos = const [],
    required this.clienteId,
  });

  // Calcula o total da nota
  double get total => produtos.fold(0, (soma, item) => soma + item.subtotal);

  Nota copyWith({
    String? id,
    DateTime? dataCriacao,
    List<Produto>? produtos,
    String? clienteId,
  }) {
    return Nota(
      id: id ?? this.id,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      produtos: produtos ?? this.produtos,
      clienteId: clienteId ?? this.clienteId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dataCriacao': dataCriacao,
      'produtos': produtos.map((p) => p.toMap()).toList(),
      'clienteId': clienteId,
    };
  }

  factory Nota.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Nota(
      id: doc.id,
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
      produtos:
          (data['produtos'] as List).map((p) => Produto.fromMap(p)).toList(),
      clienteId: data['clienteId'],
    );
  }

  @override
  List<Object?> get props => [id, dataCriacao, produtos, clienteId];
}
