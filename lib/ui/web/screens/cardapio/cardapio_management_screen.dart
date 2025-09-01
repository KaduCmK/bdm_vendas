import 'package:bdm_vendas/bloc/cardapio/cardapio_bloc.dart';
import 'package:bdm_vendas/bloc/categoria/categoria_bloc.dart';
import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/components/cardapio_item_dialog.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/components/cardapio_management_item.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/components/categoria_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CardapioManagementScreen extends StatelessWidget {
  const CardapioManagementScreen({super.key});

  void _showItemDialog(BuildContext context, {CardapioItem? item}) {
    showDialog(
      context: context,
      builder:
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: BlocProvider.of<CardapioBloc>(context)),
              BlocProvider.value(
                value: BlocProvider.of<CategoriaBloc>(context),
              ),
            ],
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
          title: Row(
            children: [
              const Text('Gerenciamento do Cardápio'),
              SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => context.go('/cardapio'),
                child: const Text('Ver Cardápio'),
              ),
            ],
          ),
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
                  _ItemList(itens: comidas, onEdit: _showItemDialog),
                  _ItemList(itens: bebidas, onEdit: _showItemDialog),
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

  const _ItemList({required this.itens, required this.onEdit});

  @override
  Widget build(BuildContext buildContext) {
    if (itens.isEmpty) {
      return Center(child: Text('Nenhum item desta categoria cadastrado.'));
    }

    return BlocBuilder<CategoriaBloc, CategoriaState>(
      builder: (context, state) {
        if (state is! CategoriaLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          itemCount: itens.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = itens[index];
            // compara os IDs

            return CardapioManagementItem(
              item: item,
              categorias: state.categorias,
              onEdit: onEdit,
            );
          },
        );
      },
    );
  }
}
