import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/models/produto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProductList extends StatelessWidget {
  final Nota nota;
  const ProductList({super.key, required this.nota});

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

  void _reduzirQuantidade(BuildContext context, int index) {
    final produtos = List<Produto>.from(nota.produtos);
    final produto = produtos[index];
    produtos[index] = produto.copyWith(quantidade: produto.quantidade - 1);
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
                  tooltip: 'Clique para adicionar um',
                ),
              ),
              SizedBox(
                width: 32,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Clique para remover um; segure para apagar o item',
                  onPressed: () => _reduzirQuantidade(context, index),
                  onLongPress: () => _removerProduto(context, index),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
