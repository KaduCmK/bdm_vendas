import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Pagamento extends Equatable {
  final String? id;
  final double valor;
  final String metodo;
  final DateTime data;
  final List<String> produtoIds;

  const Pagamento({
    this.id,
    required this.valor,
    required this.metodo,
    required this.data,
    required this.produtoIds,
  });

  Pagamento copyWith({
    String? id,
    double? valor,
    String? metodo,
    DateTime? data,
    List<String>? produtoIds,
  }) {
    return Pagamento(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      metodo: metodo ?? this.metodo,
      data: data ?? this.data,
      produtoIds: produtoIds ?? this.produtoIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'valor': valor,
      'metodo': metodo,
      'data': Timestamp.fromDate(data),
      'produtoIds': produtoIds,
    };
  }

  factory Pagamento.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pagamento(
      id: doc.id,
      valor: (data['valor'] as num).toDouble(),
      metodo: data['metodo'] as String,
      data: (data['data'] as Timestamp).toDate(),
      produtoIds: List<String>.from(data['produtoIds'] as List),
    );
  }

  @override
  List<Object?> get props => [id, valor, metodo, data, produtoIds];
}
