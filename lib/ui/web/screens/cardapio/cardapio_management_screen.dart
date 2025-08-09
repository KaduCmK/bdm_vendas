import 'package:bdm_vendas/bloc/cardapio/cardapio_bloc.dart';
import 'package:bdm_vendas/bloc/categoria/categoria_bloc.dart';
import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/cardapio_item_dialog.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/categoria_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardapioManagementScreen extends StatelessWidget {
  const CardapioManagementScreen({super.key});

  void _showItemDialog(BuildContext context, {CardapioItem? item}) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: BlocProvider.of<CardapioBloc>(context),
            child: CardapioItemDialog(item: item),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 abas: Comidas e Bebidas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciamento do Cardápio'),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed:
                  () => showDialog(
                    context: context,
                    builder:
                        (_) => BlocProvider.value(
                          value: BlocProvider.of<CategoriaBloc>(context),
                          child: CategoriaDialog(),
                        ),
                  ),
              icon: Icon(Icons.bookmark_add),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _showItemDialog(context),
                label: const Text('Novo Item'),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fastfood_outlined), text: 'Comidas'),
              Tab(icon: Icon(Icons.local_bar_outlined), text: 'Bebidas'),
            ],
          ),
        ),
        body: BlocBuilder<CardapioBloc, CardapioState>(
          builder: (context, state) {
            if (state is CardapioLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CardapioError) {
              return Center(child: Text(state.message));
            }
            if (state is CardapioLoaded) {
              // Separa a lista principal em duas
              final comidas =
                  state.itens.where((i) => i.tipo == TipoItem.comida).toList();
              final bebidas =
                  state.itens.where((i) => i.tipo == TipoItem.bebida).toList();

              return TabBarView(
                children: [
                  _ItemList(
                    itens: comidas,
                    onEdit: _showItemDialog,
                    context: context,
                  ),
                  _ItemList(
                    itens: bebidas,
                    onEdit: _showItemDialog,
                    context: context,
                  ),
                ],
              );
            }
            return const Center(
              child: Text('Para começar, adicione um item ao cardápio.'),
            );
          },
        ),
      ),
    );
  }
}

// Widget reutilizável para renderizar a lista de itens
class _ItemList extends StatelessWidget {
  final List<CardapioItem> itens;
  final Function(BuildContext, {CardapioItem? item}) onEdit;
  final BuildContext context;

  const _ItemList({
    required this.itens,
    required this.onEdit,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    // Renomeado para evitar conflito
    if (itens.isEmpty) {
      return Center(child: Text('Nenhum item desta categoria cadastrado.'));
    }

    return ListView.separated(
      itemCount: itens.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = itens[index];
        return ListTile(
          title: Text(
            item.nome,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: item.descricao != null ? Text(item.descricao!) : null,
          leading: CircleAvatar(
            child: Icon(
              item.tipo == TipoItem.comida
                  ? Icons.fastfood_outlined
                  : Icons.local_bar_outlined,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(label: Text(item.categoria)),
              const SizedBox(width: 16),
              Text(
                "R\$ ${item.preco.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: Colors.blue.shade700,
                tooltip: 'Editar',
                onPressed: () => onEdit(this.context, item: item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade700,
                tooltip: 'Excluir',
                onPressed: () {
                  this.context.read<CardapioBloc>().add(
                    DeleteCardapioItem(item.id!),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
