// lib/models/nota.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:bdm_vendas/models/produto.dart';

// Enum para o status da nota
enum NotaStatus { emAberto, pagoCredito, pagoDebito, pagoPix, pagoDinheiro }

extension NotaStatusExtension on NotaStatus {
  String get displayName {
    switch (this) {
      case NotaStatus.emAberto:
        return 'Em Aberto';
      case NotaStatus.pagoCredito:
        return 'Crédito';
      case NotaStatus.pagoDebito:
        return 'Débito';
      case NotaStatus.pagoPix:
        return 'Pix';
      case NotaStatus.pagoDinheiro:
        return 'Dinheiro';
    }
  }
}

class Nota extends Equatable {
  final String? id;
  final DateTime dataCriacao;
  final List<Produto> produtos;
  final String clienteId;
  final NotaStatus status;

  const Nota({
    this.id,
    required this.dataCriacao,
    this.produtos = const [],
    required this.clienteId,
    this.status = NotaStatus.emAberto,
  });

  double get total => produtos.fold(0, (soma, item) => soma + item.subtotal);

  Nota copyWith({
    String? id,
    DateTime? dataCriacao,
    List<Produto>? produtos,
    String? clienteId,
    NotaStatus? status,
  }) {
    return Nota(
      id: id ?? this.id,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      produtos: produtos ?? this.produtos,
      clienteId: clienteId ?? this.clienteId,
      status: status ?? this.status,
    );
  }

  // Converte a nota para um formato que o Firestore entende
  Map<String, dynamic> toMap() {
    return {
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'produtos': produtos.map((p) => p.toMap()).toList(),
      'clienteId': clienteId,
      'status': status.toString(), // <<< A MÁGICA ACONTECE AQUI
    };
  }

  // Cria uma nota a partir dos dados do Firestore
  factory Nota.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Nota(
      id: doc.id,
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
      produtos: (data['produtos'] as List? ?? [])
          .map((p) => Produto.fromMap(p))
          .toList(),
      clienteId: data['clienteId'],
      // <<< E AQUI, NA VOLTA >>>
      status: NotaStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => NotaStatus.emAberto,
      ),
    );
  }

  @override
  List<Object?> get props => [id, dataCriacao, produtos, clienteId, status];
}