import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String? id;
  final String nome;
  final DateTime dataCriacao;

  Cliente({
    this.id,
    required this.nome,
    required this.dataCriacao,
  });

  factory Cliente.fromMap(String id, Map<String, dynamic> data) {
    return Cliente(
      id: id,
      nome: data['nome'],
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
    };
  }
}