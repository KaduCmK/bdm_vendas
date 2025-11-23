import 'package:bdm_vendas/models/pagamento.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

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
  final DateTime? dataFechamento;
  final List<Produto> produtos;
  final String clienteId;
  final NotaStatus status;
  final bool isSplitted;
  final List<Pagamento> pagamentos;

  const Nota({
    this.id,
    required this.dataCriacao,
    this.dataFechamento,
    this.produtos = const [],
    required this.clienteId,
    this.status = NotaStatus.emAberto,
    this.isSplitted = true,
    this.pagamentos = const [],
  });

  double get total => produtos.fold(0, (soma, item) => soma + item.subtotal);
  double get totalPago => pagamentos.fold(0, (soma, item) => soma + item.valor);
  double get totalRestante => total - totalPago;

  Nota copyWith({
    String? id,
    DateTime? dataCriacao,
    DateTime? dataFechamento,
    List<Produto>? produtos,
    String? clienteId,
    NotaStatus? status,
    bool? isSplitted,
    List<Pagamento>? pagamentos,
  }) {
    return Nota(
      id: id ?? this.id,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      produtos: produtos ?? this.produtos,
      clienteId: clienteId ?? this.clienteId,
      status: status ?? this.status,
      isSplitted: isSplitted ?? this.isSplitted,
      pagamentos: pagamentos ?? this.pagamentos,
    );
  }

  // Converte a nota para um formato que o Firestore entende
  Map<String, dynamic> toMap() {
    return {
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'dataFechamento':
          dataFechamento != null ? Timestamp.fromDate(dataFechamento!) : null,
      if (!isSplitted) 'produtos': produtos.map((p) => p.toMap()).toList(),
      'clienteId': clienteId,
      'status': status.toString(),
      'isSplitted': isSplitted,
      'version': 2,
    };
  }

  // Cria uma nota a partir dos dados do Firestore
  factory Nota.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isSplitted = data['isSplitted'] ?? false;

    List<Produto> produtos = [];
    if (data.containsKey('produtos')) {
      produtos = (data['produtos'] as List)
          .map((p) => Produto.fromMap(p))
          .toList();
    }

    return Nota(
      id: doc.id,
      dataCriacao: (data['dataCriacao'] as Timestamp).toDate(),
      dataFechamento: (data['dataFechamento'] as Timestamp?)?.toDate(),
      produtos: produtos, // Use the potentially populated list
      clienteId: data['clienteId'],
      status: NotaStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => NotaStatus.emAberto,
      ),
      isSplitted: isSplitted,
      pagamentos: const [], // Pagamentos are still loaded separately
    );
  }

  @override
  List<Object?> get props => [
        id,
        dataCriacao,
        dataFechamento,
        produtos,
        clienteId,
        status,
        isSplitted,
        pagamentos,
      ];
}
