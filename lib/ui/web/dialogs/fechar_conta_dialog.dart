import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/pagamento.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:bdm_vendas/ui/shared/currency_input_formatter.dart';
import 'package:bdm_vendas/ui/web/components/payment_method_selector.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pix_flutter/pix_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

enum PaymentMode { byItem, byValue }

class FecharContaDialog extends StatefulWidget {
  final Nota nota;
  final Cliente? cliente;
  const FecharContaDialog({super.key, required this.nota, this.cliente});

  @override
  State<FecharContaDialog> createState() => FecharContaDialogState();
}

class FecharContaDialogState extends State<FecharContaDialog> {
  final Map<String, int> _selectedQuantities = {};
  late final TextEditingController _pagadorNomeController;
  late final TextEditingController _valorAbaterController;
  String _paymentMethod = 'Dinheiro';
  late final Map<String, List<Produto>> _groupedProdutos;
  PaymentMode _paymentMode = PaymentMode.byItem;

  @override
  void initState() {
    super.initState();
    _pagadorNomeController =
        TextEditingController(text: widget.cliente?.nome ?? '');
    _valorAbaterController = TextEditingController();

    _groupedProdutos = _groupProdutos();
    // Pre-select all unpaid items
    final paidProductIds =
        widget.nota.pagamentos.expand((p) => p.produtoIds).toSet();
    final unpaidProducts =
        widget.nota.produtos.where((p) => !paidProductIds.contains(p.id));

    final unpaidGrouped = groupBy(unpaidProducts, (Produto p) => p.nome);

    for (var key in _groupedProdutos.keys) {
      _selectedQuantities[key] = unpaidGrouped[key]?.length ?? 0;
    }
  }

  @override
  void dispose() {
    _pagadorNomeController.dispose();
    _valorAbaterController.dispose();
    super.dispose();
  }

  Map<String, List<Produto>> _groupProdutos() {
    final grouped = <String, List<Produto>>{};
    // We group all products, including paid ones, to show them in the UI
    for (final produto in widget.nota.produtos) {
      if (!grouped.containsKey(produto.nome)) {
        grouped[produto.nome] = [];
      }
      grouped[produto.nome]!.add(produto);
    }
    return grouped;
  }

  double get _totalAPagar {
    if (_paymentMode == PaymentMode.byValue) {
      return double.tryParse(_valorAbaterController.text
              .replaceAll('.', '')
              .replaceAll(',', '.')) ??
          0.0;
    }
    // byItem
    double total = 0;
    _selectedQuantities.forEach((nome, quantidade) {
      if (quantidade > 0) {
        // Find an unpaid product to get the price from
        final product = _getUnpaidProductByName(nome);
        if (product != null) {
          total += product.valorUnitario * quantidade;
        }
      }
    });
    return total;
  }

  Produto? _getUnpaidProductByName(String name) {
    final paidProductIds =
        widget.nota.pagamentos.expand((p) => p.produtoIds).toSet();
    return widget.nota.produtos.firstWhereOrNull(
      (p) => p.nome == name && !paidProductIds.contains(p.id),
    );
  }

  NotaStatus _methodToStatus(String method) {
    switch (method) {
      case 'Crédito':
        return NotaStatus.pagoCredito;
      case 'Débito':
        return NotaStatus.pagoDebito;
      case 'Dinheiro':
        return NotaStatus.pagoDinheiro;
      case 'Pix':
        return NotaStatus.pagoPix;
      default:
        return NotaStatus.pagoCredito;
    }
  }

  void _confirmarPagamento() {
    final pagadorNome = _pagadorNomeController.text;

    if (_paymentMode == PaymentMode.byValue) {
      final valor = _totalAPagar;
      if (valor <= 0) return;

      final pagamento = Pagamento(
        valor: valor,
        metodo: _paymentMethod,
        data: DateTime.now(),
        produtoIds: const [], // No product IDs for value abatement
        pagadorNome: pagadorNome.isNotEmpty ? pagadorNome : null,
      );
      context.read<NotaBloc>().add(AddPagamento(widget.nota.id!, pagamento));
      Navigator.of(context).pop();
      return;
    }

    // Logic for PaymentMode.byItem
    final allPreviousPaidIds =
        widget.nota.pagamentos.expand((p) => p.produtoIds).toSet();
    final produtoIdsParaPagar = <String>{};

    _selectedQuantities.forEach((nome, quantidade) {
      if (quantidade > 0) {
        final unpaidProductsOfKind = widget.nota.produtos
            .where((p) => p.nome == nome && !allPreviousPaidIds.contains(p.id))
            .take(quantidade)
            .map((p) => p.id!);
        produtoIdsParaPagar.addAll(unpaidProductsOfKind);
      }
    });

    if (produtoIdsParaPagar.isEmpty) return;

    final allProductIds = widget.nota.produtos.map((p) => p.id!).toSet();
    final unpaidIds = allProductIds.difference(allPreviousPaidIds);
    final isClosingBill = unpaidIds.length == produtoIdsParaPagar.length &&
        unpaidIds.difference(produtoIdsParaPagar).isEmpty;

    final pagamento = Pagamento(
      valor: _totalAPagar,
      metodo: _paymentMethod,
      data: DateTime.now(),
      produtoIds: produtoIdsParaPagar.toList(),
      pagadorNome: pagadorNome.isNotEmpty ? pagadorNome : null,
    );

    if (isClosingBill) {
      final notaAtualizada = widget.nota.copyWith(
        status: _methodToStatus(_paymentMethod),
        dataFechamento: DateTime.now(),
        pagamentos: [...widget.nota.pagamentos, pagamento],
      );
      context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
    } else {
      context.read<NotaBloc>().add(AddPagamento(widget.nota.id!, pagamento));
    }

    Navigator.of(context).pop();
  }

  void _generatePixQRCode() {
    if (_totalAPagar <= 0) return;
    PixFlutter pixFlutter = PixFlutter(
      payload: Payload(
        pixKey: '+5521990935252',
        merchantName: 'Bar do Malhado',
        merchantCity: 'Rio de Janeiro',
        txid: '***',
        amount: _totalAPagar.toStringAsFixed(2),
      ),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('QR Code Pix'),
        content: SizedBox(
          height: 400,
          width: 400,
          child: QrImageView(size: 400, data: pixFlutter.getQRCode()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paidProductIds =
        widget.nota.pagamentos.expand((p) => p.produtoIds).toSet();

    return AlertDialog(
      title: const Text('Realizar Pagamento'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SegmentedButton<PaymentMode>(
                segments: const <ButtonSegment<PaymentMode>>[
                  ButtonSegment<PaymentMode>(
                      value: PaymentMode.byItem,
                      label: Text('Pagar Itens'),
                      icon: Icon(Icons.fastfood)),
                  ButtonSegment<PaymentMode>(
                      value: PaymentMode.byValue,
                      label: Text('Abater Valor'),
                      icon: Icon(Icons.remove_circle_outline)),
                ],
                selected: <PaymentMode>{_paymentMode},
                onSelectionChanged: (Set<PaymentMode> newSelection) {
                  setState(() {
                    _paymentMode = newSelection.first;
                  });
                },
              ),
            ),
            if (_paymentMode == PaymentMode.byItem)
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _groupedProdutos.entries.map((entry) {
                      final nome = entry.key;
                      final allProductsInGroup = entry.value;
                      final unpaidProductsInGroup = allProductsInGroup
                          .where((p) => !paidProductIds.contains(p.id))
                          .toList();

                      final totalQuantity = unpaidProductsInGroup.length;
                      final selectedQuantity = _selectedQuantities[nome] ?? 0;

                      if (totalQuantity == 0) return const SizedBox.shrink();

                      return SizedBox(
                        width: 150,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(nome,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                                Text('Pendente: $totalQuantity',
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (selectedQuantity > 0) {
                                            _selectedQuantities[nome] =
                                                selectedQuantity - 1;
                                          }
                                        });
                                      },
                                    ),
                                    Text('$selectedQuantity',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          if (selectedQuantity <
                                              totalQuantity) {
                                            _selectedQuantities[nome] =
                                                selectedQuantity + 1;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            if (_paymentMode == PaymentMode.byValue)
              Expanded(
                  child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Restante: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(widget.nota.totalRestante)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _valorAbaterController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Valor a Abater',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextFormField(
                controller: _pagadorNomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Pagador (Opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            PaymentMethodSelector(
              selectedMethod: _paymentMethod,
              onMethodChanged: (newValue) {
                setState(() {
                  _paymentMethod = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_paymentMethod == 'Pix')
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton.icon(
                  onPressed: _totalAPagar > 0 ? _generatePixQRCode : null,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Gerar QR Code PIX'),
                ),
              ),
            Text(
              'Total a Pagar: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_totalAPagar)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _totalAPagar > 0 ? _confirmarPagamento : null,
          child: const Text('Confirmar Pagamento'),
        ),
      ],
    );
  }
}

