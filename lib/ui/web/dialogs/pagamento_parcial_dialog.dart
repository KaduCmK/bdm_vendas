import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/pagamento.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PagamentoParcialDialog extends StatefulWidget {
  final Nota nota;
  final Function(Pagamento) onConfirm;

  const PagamentoParcialDialog({
    super.key,
    required this.nota,
    required this.onConfirm,
  });

  @override
  State<PagamentoParcialDialog> createState() => _PagamentoParcialDialogState();
}

class _PagamentoParcialDialogState extends State<PagamentoParcialDialog> {
  final Set<Produto> _selectedProdutos = {};
  String _paymentMethod = 'Dinheiro';

  double get _totalSelecionado =>
      _selectedProdutos.fold(0, (sum, item) => sum + item.valorUnitario);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pagamento Parcial'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.nota.produtos.length,
                itemBuilder: (context, index) {
                  final produto = widget.nota.produtos[index];
                  final isSelected = _selectedProdutos.contains(produto);
                  return CheckboxListTile(
                    title: Text(produto.nome),
                    subtitle: Text(
                      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                          .format(produto.valorUnitario),
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedProdutos.add(produto);
                        } else {
                          _selectedProdutos.remove(produto);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _paymentMethod,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _paymentMethod = newValue;
                  });
                }
              },
              items: <String>['Dinheiro', 'Crédito', 'Débito', 'Pix']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Selecionado: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_totalSelecionado)}',
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
          onPressed: _selectedProdutos.isEmpty
              ? null
              : () {
                  final pagamento = Pagamento(
                    valor: _totalSelecionado,
                    metodo: _paymentMethod,
                    data: DateTime.now(),
                    produtoIds: _selectedProdutos.map((p) => p.id!).toList(),
                  );
                  widget.onConfirm(pagamento);
                  Navigator.of(context).pop();
                },
          child: const Text('Pagar'),
        ),
      ],
    );
  }
}
