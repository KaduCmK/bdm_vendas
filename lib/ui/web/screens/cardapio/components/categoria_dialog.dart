import 'package:bdm_vendas/bloc/categoria/categoria_bloc.dart';
import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bdm_vendas/models/cardapio/categoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriaDialog extends StatelessWidget {
  const CategoriaDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gerenciar Categorias'),
      content: BlocBuilder<CategoriaBloc, CategoriaState>(
        builder: (context, state) {
          if (state is! CategoriaLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final categoriasComida = state.categorias.where((c) => c.tipo == TipoItem.comida).toList();
          final categoriasBebida = state.categorias.where((c) => c.tipo == TipoItem.bebida).toList();

          return SizedBox(
            width: 600,
            height: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _CategoriaList(
                  title: 'Comidas',
                  tipo: TipoItem.comida,
                  categorias: categoriasComida,
                )),
                const VerticalDivider(),
                Expanded(child: _CategoriaList(
                  title: 'Bebidas',
                  tipo: TipoItem.bebida,
                  categorias: categoriasBebida,
                )),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))
      ],
    );
  }
}

class _CategoriaList extends StatelessWidget {
  final String title;
  final TipoItem tipo;
  final List<Categoria> categorias;
  final _controller = TextEditingController();

  _CategoriaList({
    required this.title,
    required this.tipo,
    required this.categorias,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Nova categoria', border: OutlineInputBorder()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Adicionar Categoria",
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  context.read<CategoriaBloc>().add(AddCategoria(
                    Categoria(nome: _controller.text, tipo: tipo),
                  ));
                  _controller.clear();
                }
              },
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return ListTile(
                title: Text(categoria.nome),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => context.read<CategoriaBloc>().add(DeleteCategoria(categoria.id!)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}