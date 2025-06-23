import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Nota extends Equatable {
  final String? id;
  final DateTime dataCriacao;
  final List<String> produtos;
  final String clienteId;

  const Nota({
    this.id,
    required this.dataCriacao,
    required this.produtos,
    required this.clienteId,
  });

  Nota copyWith({
    String? id,
    DateTime? dataCriacao,
    List<String>? produtos,
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
      'produtos': produtos,
      'clienteId': clienteId,
    };
  }

  factory Nota.fromMap(Map<String, dynamic> data) {
    return Nota(
      id: data['id'],
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
      produtos: List<String>.from(data['produtos']),
      clienteId: data['clienteId'],
    );
  }

  @override
  List<Object?> get props => [id, dataCriacao, produtos, clienteId];
}
