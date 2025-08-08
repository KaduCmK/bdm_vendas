import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <<< IMPORTE ESTE PACOTE
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// <<< CLASSE DO FORMATADOR ADICIONADA AQUI >>>
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove tudo que não for dígito
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    double value = double.parse(newText);

    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    String newString = formatter.format(value / 100);

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class NotaCard extends StatefulWidget {
  final Nota nota;
  final Cliente? cliente;
  const NotaCard({super.key, required this.nota, this.cliente});

  @override
  State<NotaCard> createState() => _NotaCardState();
}

class _NotaCardState extends State<NotaCard> {
  final _nomeController = TextEditingController();
  final _qtdController = TextEditingController(text: '1');
  final _precoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _qtdController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _adicionarProduto() {
    final nome = _nomeController.text;
    final qtd = int.tryParse(_qtdController.text) ?? 1;
    // <<< LÓGICA DE PARSE ATUALIZADA AQUI >>>
    final precoString = _precoController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final preco = double.tryParse(precoString) ?? 0.0;

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("O nome do produto não pode ser vazio!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final novoProduto = Produto(
      nome: nome,
      quantidade: qtd,
      valorUnitario: preco,
    );
    final novosProdutos = List<Produto>.from(widget.nota.produtos)
      ..add(novoProduto);
    final notaAtualizada = widget.nota.copyWith(produtos: novosProdutos);

    context.read<NotaBloc>().add(UpdateNota(notaAtualizada));

    _nomeController.clear();
    _qtdController.text = '1';
    _precoController.clear();
    FocusScope.of(context).unfocus();
  }

  void _incrementarQuantidade(int index) {
    final produto = widget.nota.produtos[index];
    final produtos = List<Produto>.from(widget.nota.produtos);
    produtos[index] = produto.copyWith(quantidade: produto.quantidade + 1);

    final notaAtualizada = widget.nota.copyWith(produtos: produtos);
    context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
  }

  void _removerProduto(int index) {
    final produtos = List<Produto>.from(widget.nota.produtos);
    produtos.removeAt(index);
    final notaAtualizada = widget.nota.copyWith(produtos: produtos);
    context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(widget.cliente?.nome ?? 'Cliente não encontrado'),
              subtitle: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(widget.nota.dataCriacao),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildProductHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.nota.produtos.length,
                itemBuilder: (context, index) {
                  return _buildProdutoRow(widget.nota.produtos[index], index);
                },
              ),
            ),
            const Divider(),
            _buildAddProductRow(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: R\$ ${widget.nota.total.toStringAsFixed(2)}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 40),
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
          SizedBox(width: 16),
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
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProdutoRow(Produto produto, int index) {
    final formatadorReais = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              tooltip: 'Remover produto',
              onPressed: () => _removerProduto(index),
            ),
          ),
          Expanded(flex: 6, child: Text(produto.nome)),
          Expanded(flex: 2, child: Text('${produto.quantidade}')),
          Expanded(
            flex: 3,
            child: Text(formatadorReais.format(produto.valorUnitario)),
          ),
          const SizedBox(width: 16, child: Center(child: Text("="))),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(formatadorReais.format(produto.subtotal)),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _incrementarQuantidade(index),
              tooltip: 'Adicionar um',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
            flex: 3,
            child: TextFormField(
              controller: _precoController,
              decoration: const InputDecoration(
                labelText: 'Preço',
                isDense: true,
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
              // <<< FORMATADOR APLICADO AQUI >>>
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
