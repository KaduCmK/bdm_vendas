import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:bdm_vendas/ui/shared/currency_input_formatter.dart';
import 'package:bdm_vendas/ui/web/components/nota_card_header.dart';
import 'package:bdm_vendas/ui/web/components/nota_card_product_list.dart';
import 'package:bdm_vendas/ui/web/dialogs/fechar_conta_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotaCard extends StatelessWidget {
  final Nota nota;
  final Cliente? cliente;
  final bool isLoading;
  const NotaCard({super.key, required this.nota, this.cliente, this.isLoading = false});

  void _showFecharContaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: BlocProvider.of<NotaBloc>(context),
            child: FecharContaDialog(nota: nota),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          NotaCardHeader(cliente: cliente, nota: nota, isLoading: isLoading),
          const Divider(),
          _ProductListHeader(),
          Expanded(child: ProductList(nota: nota)),
          const Divider(),
          _AddProductRow(nota: nota),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(nota.total)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showFecharContaDialog(context),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Fechar a Conta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              'Produto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Qtd.', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Text('Preço', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Subtotal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 75),
        ],
      ),
    );
  }
}



class _AddProductRow extends StatefulWidget {
  final Nota nota;
  const _AddProductRow({required this.nota});

  @override
  State<_AddProductRow> createState() => _AddProductRowState();
}

class _AddProductRowState extends State<_AddProductRow> {
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _qtdController = TextEditingController(text: '1');

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _qtdController.dispose();
    super.dispose();
  }

  void _adicionarProduto() {
    final nome = _nomeController.text;
    final precoString = _precoController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final preco = double.tryParse(precoString) ?? 0.0;
    final qtd = int.tryParse(_qtdController.text) ?? 1;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O nome do produto não pode ser vazio!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.nota.isSplitted) {
      final produtos = List.generate(
        qtd,
        (index) => Produto(
          nome: nome,
          valorUnitario: preco,
          createdAt: DateTime.now(),
        ),
      );
      context.read<NotaBloc>().add(AddProdutos(widget.nota.id!, produtos));
    } else {
      // Mantém a lógica antiga para notas não divididas
      final novoProduto = Produto(
        nome: nome,
        valorUnitario: preco,
        createdAt: DateTime.now(),
      );
      final novosProdutos = List<Produto>.from(widget.nota.produtos)
        ..add(novoProduto);
      final notaAtualizada = widget.nota.copyWith(produtos: novosProdutos);
      context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
    }


    _nomeController.clear();
    _precoController.clear();
    _qtdController.text = '1';
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _qtdController,
              decoration: const InputDecoration(
                labelText: 'Qtd.',
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Produto',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _precoController,
              decoration: const InputDecoration(
                labelText: 'Preço',
                isDense: true,
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _adicionarProduto,
              tooltip: 'Adicionar produto à nota',
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
