import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/pagamento.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProductList extends StatelessWidget {
  final Nota nota;
  const ProductList({super.key, required this.nota});

  @override
  Widget build(BuildContext context) {
    final paidProductIds =
        nota.pagamentos.expand((p) => p.produtoIds).toSet();
    final unpaidProducts =
        nota.produtos.where((p) => !paidProductIds.contains(p.id)).toList();
    final unpaidItems = _getDisplayItems(unpaidProducts);

    final hasPayments = nota.pagamentos.isNotEmpty;

    if (!hasPayments) {
      return Column(
        children: [
          if (unpaidItems.isNotEmpty) const _ProductListHeader(),
          Expanded(
            child: ListView(
              children: unpaidItems
                  .map((item) => _ProductListItem(
                        item: item,
                        nota: nota,
                        isPaid: false,
                      ))
                  .toList(),
            ),
          ),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Pendentes (${unpaidItems.length})'),
              Tab(text: 'Pagos (${nota.pagamentos.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Aba de Itens Pendentes
                ListView(
                  children: [
                    const _ProductListHeader(),
                    ...unpaidItems.map((item) => _ProductListItem(
                          item: item,
                          nota: nota,
                          isPaid: false,
                        )),
                  ],
                ),
                // Aba de Pagamentos Realizados
                ListView.builder(
                  itemCount: nota.pagamentos.length,
                  itemBuilder: (context, index) {
                    final pagamento = nota.pagamentos.sorted((a, b) => b.data.compareTo(a.data))[index];
                    return _PagamentoCard(pagamento: pagamento, nota: nota);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDisplayItems(List<Produto> produtos) {
    if (produtos.isEmpty) return [];

    final grouped = groupBy(produtos, (Produto p) => p.nome);
    return grouped.keys.map((nome) {
      final productGroup = grouped[nome]!;
      final firstProduct = productGroup.first;
      final quantidade = productGroup.length;
      final subtotal = firstProduct.valorUnitario * quantidade;
      return {
        'produto': firstProduct,
        'quantidade': quantidade,
        'subtotal': subtotal,
        'all_produtos': productGroup,
      };
    }).toList()
      ..sort((a, b) => (b['produto'] as Produto)
          .createdAt
          .compareTo((a['produto'] as Produto).createdAt));
  }
}

class _PagamentoCard extends StatelessWidget {
  final Pagamento pagamento;
  final Nota nota;

  const _PagamentoCard({required this.pagamento, required this.nota});

  @override
  Widget build(BuildContext context) {
    final formatadorReais = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yy \'às\' HH:mm');

    final bool isAbatimento = pagamento.produtoIds.isEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatadorReais.format(pagamento.valor),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${pagamento.metodo} - ${formatadorData.format(pagamento.data)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (pagamento.pagadorNome != null && pagamento.pagadorNome!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Pago por: ${pagamento.pagadorNome}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const Divider(height: 16),
            if (isAbatimento)
              const ListTile(
                dense: true,
                leading: Icon(Icons.remove_circle_outline, color: Colors.blue),
                title: Text('Abatimento de valor'),
              )
            else
              _buildProductListOfPayment(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListOfPayment() {
    final produtosNestePagamento = nota.produtos
        .where((p) => pagamento.produtoIds.contains(p.id))
        .toList();
    final grouped = groupBy(produtosNestePagamento, (Produto p) => p.nome);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final nome = entry.key;
        final quantidade = entry.value.length;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            '$quantidade x $nome',
            style: const TextStyle(
                decoration: TextDecoration.lineThrough, color: Colors.grey),
          ),
        );
      }).toList(),
    );
  }
}


class _ProductListHeader extends StatelessWidget {
  const _ProductListHeader();

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

class _ProductListItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final Nota nota;
  final bool isPaid;

  const _ProductListItem({
    required this.item,
    required this.nota,
    required this.isPaid,
  });

  void _removerTodosProdutos(BuildContext context, List<Produto> produtos) {
    if (isPaid) return;
    if (nota.isSplitted) {
      for (var produto in produtos) {
        context.read<NotaBloc>().add(RemoveProduto(nota.id!, produto));
      }
    } else {
      final produtosAtualizados = List<Produto>.from(nota.produtos)
        ..removeWhere((p) => p.nome == produtos.first.nome);
      final notaAtualizada = nota.copyWith(produtos: produtosAtualizados);
      context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
    }
  }

  void _incrementarQuantidade(BuildContext context, Produto produto) {
    if (isPaid) return;
    if (nota.isSplitted) {
      context
          .read<NotaBloc>()
          .add(AddProduto(nota.id!, produto.copyWith(createdAt: DateTime.now())));
    } else {
      // Migrate old note format to new format on write
      final novaLista = List<Produto>.from(nota.produtos)
        ..add(produto.copyWith(createdAt: DateTime.now()));
      
      context.read<NotaBloc>().add(AddProdutos(nota.id!, novaLista));
      context.read<NotaBloc>().add(UpdateNota(nota.copyWith(isSplitted: true, produtos: [])));
    }
  }

  void _reduzirQuantidade(BuildContext context, Produto produto) {
    if (isPaid) return;
    if (nota.isSplitted) {
      context.read<NotaBloc>().add(RemoveProduto(nota.id!, produto));
    } else {
      // Migrate old note format to new format on write
      final novaLista = List<Produto>.from(nota.produtos);
      final index = novaLista.indexWhere((p) => p.id == produto.id || p.createdAt == produto.createdAt);
      if (index != -1) {
        novaLista.removeAt(index);
        context.read<NotaBloc>().add(AddProdutos(nota.id!, novaLista));
        context.read<NotaBloc>().add(UpdateNota(nota.copyWith(isSplitted: true, produtos: [])));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatadorReais =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final produto = item['produto'] as Produto;
    final quantidade = item['quantidade'] as int;
    final subtotal = item['subtotal'] as double;
    final allProdutos = item['all_produtos'] as List<Produto>;

    final textStyle = isPaid
        ? const TextStyle(
            decoration: TextDecoration.lineThrough, color: Colors.grey)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 6, child: Text(produto.nome, style: textStyle)),
          Expanded(flex: 2, child: Text('$quantidade', style: textStyle)),
          Expanded(
            flex: 3,
            child: Text(formatadorReais.format(produto.valorUnitario),
                style: textStyle),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(formatadorReais.format(subtotal), style: textStyle),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed:
                  isPaid ? null : () => _incrementarQuantidade(context, produto),
              tooltip: isPaid ? 'Item já pago' : 'Clique para adicionar um',
            ),
          ),
          SizedBox(
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: isPaid ? Colors.grey : Colors.red,
              tooltip: isPaid
                  ? 'Item já pago'
                  : 'Clique para remover um; segure para apagar o item',
              onPressed: isPaid
                  ? null
                  : () => _reduzirQuantidade(context, allProdutos.last),
              onLongPress: isPaid
                  ? null
                  : () => _removerTodosProdutos(context, allProdutos),
            ),
          ),
        ],
      ),
    );
  }
}
