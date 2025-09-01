import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:bdm_vendas/ui/shared/currency_input_formatter.dart';
import 'package:bdm_vendas/ui/web/dialogs/fechar_conta_dialog.dart';
import 'package:bdm_vendas/ui/web/screens/notas/components/share_nota_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotaCard extends StatelessWidget {
  final Nota nota;
  final Cliente? cliente;
  const NotaCard({super.key, required this.nota, this.cliente});

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
          _NotaCardHeader(cliente: cliente, nota: nota),
          const Divider(),
          _ProductListHeader(),
          Expanded(child: _ProductList(nota: nota)),
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

// Widgets internos refatorados para melhor organização
class _NotaCardHeader extends StatelessWidget {
  final Cliente? cliente;
  final Nota nota;
  const _NotaCardHeader({this.cliente, required this.nota});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(cliente?.nome ?? 'Cliente não encontrado'),
      subtitle: Row(
        children: [
          const Icon(Icons.calendar_month, size: 16),
          const SizedBox(width: 4),
          Text(DateFormat('dd/MM/yyyy').format(nota.dataCriacao)),
        ],
      ),
      trailing: IconButton(
        onPressed:
            () => showDialog(
              context: context,
              builder:
                  (context) => ShareNotaDialog(
                    notaUrl: '${Uri.base.origin}/#/view-nota/${nota.id}',
                  ),
            ),
        icon: Icon(Icons.qr_code),
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
}

class _ProductList extends StatelessWidget {
  final Nota nota;
  const _ProductList({required this.nota});

  void _removerProduto(BuildContext context, int index) {
    final produtos = List<Produto>.from(nota.produtos)..removeAt(index);
    final notaAtualizada = nota.copyWith(produtos: produtos);
    context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
  }

  void _incrementarQuantidade(BuildContext context, int index) {
    final produtos = List<Produto>.from(nota.produtos);
    final produto = produtos[index];
    produtos[index] = produto.copyWith(quantidade: produto.quantidade + 1);
    final notaAtualizada = nota.copyWith(produtos: produtos);
    context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
  }

  @override
  Widget build(BuildContext context) {
    final formatadorReais = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    return ListView.builder(
      itemCount: nota.produtos.length,
      itemBuilder: (context, index) {
        final produto = nota.produtos[index];
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Remover produto',
                  onPressed: () => _removerProduto(context, index),
                ),
              ),
              Expanded(flex: 6, child: Text(produto.nome)),
              Expanded(flex: 2, child: Text('${produto.quantidade}')),
              Expanded(
                flex: 3,
                child: Text(formatadorReais.format(produto.valorUnitario)),
              ),
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
                  onPressed: () => _incrementarQuantidade(context, index),
                  tooltip: 'Adicionar um',
                ),
              ),
            ],
          ),
        );
      },
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
