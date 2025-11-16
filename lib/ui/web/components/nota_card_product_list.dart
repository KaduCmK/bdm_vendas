import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProductList extends StatelessWidget {
  final Nota nota;
  const ProductList({super.key, required this.nota});

  void _removerTodosProdutos(BuildContext context, List<Produto> produtos) {
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
    if (nota.isSplitted) {
      context.read<NotaBloc>().add(AddProduto(nota.id!, produto.copyWith(createdAt: DateTime.now())));
    } else {
      final produtos = List<Produto>.from(nota.produtos);
      final index = produtos.indexWhere((p) => p.nome == produto.nome);
      if (index != -1) {
        final notaAtualizada = nota.copyWith(produtos: produtos);
        context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
      }
    }
  }

  void _reduzirQuantidade(BuildContext context, Produto produto) {
    if (nota.isSplitted) {
      context.read<NotaBloc>().add(RemoveProduto(nota.id!, produto));
    } else {
      final produtos = List<Produto>.from(nota.produtos);
      final index = produtos.indexWhere((p) => p.nome == produto.nome);
      if (index != -1) {
        final notaAtualizada = nota.copyWith(produtos: produtos);
        context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatadorReais = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final groupedProdutos = groupBy(nota.produtos, (Produto p) => p.nome);

    final uniqueProdutos = groupedProdutos.keys.map((nome) {
      final produtos = groupedProdutos[nome]!;
      final firstProduto = produtos.first;
      final quantidade = nota.isSplitted ? produtos.length : 1;
      final subtotal = firstProduto.valorUnitario * quantidade;
      return {
        'produto': firstProduto,
        'quantidade': quantidade,
        'subtotal': subtotal,
        'all_produtos': produtos,
      };
    }).toList()
      ..sort((a, b) =>
          (b['produto'] as Produto).createdAt.compareTo((a['produto'] as Produto).createdAt));

    return ListView.builder(
      itemCount: uniqueProdutos.length,
      itemBuilder: (context, index) {
        final item = uniqueProdutos[index];
        final produto = item['produto'] as Produto;
        final quantidade = item['quantidade'] as int;
        final subtotal = item['subtotal'] as double;
        final allProdutos = item['all_produtos'] as List<Produto>;

        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 6, child: Text(produto.nome)),
              Expanded(flex: 2, child: Text('$quantidade')),
              Expanded(
                flex: 3,
                child: Text(formatadorReais.format(produto.valorUnitario)),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(formatadorReais.format(subtotal)),
                ),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _incrementarQuantidade(context, produto),
                  tooltip: 'Clique para adicionar um',
                ),
              ),
              SizedBox(
                width: 32,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Clique para remover um; segure para apagar o item',
                  onPressed: () => _reduzirQuantidade(context, produto),
                  onLongPress: () => _removerTodosProdutos(context, allProdutos),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
