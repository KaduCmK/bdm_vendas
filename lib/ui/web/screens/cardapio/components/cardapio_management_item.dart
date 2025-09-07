import 'package:bdm_vendas/bloc/cardapio/cardapio_bloc.dart';
import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bdm_vendas/models/cardapio/categoria.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardapioManagementItem extends StatelessWidget {
  final CardapioItem item;
  final List<Categoria> categorias;
  final Function(BuildContext, {CardapioItem? item}) onEdit;

  const CardapioManagementItem({
    super.key,
    required this.categorias,
    required this.item,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final categoria = categorias.firstWhereOrNull(
      (c) => c.id == item.categoriaId.id,
    );

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
          if (categoria != null) Chip(label: Text(categoria.nome)),
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
            onPressed: () => onEdit(context, item: item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red.shade700,
            tooltip: 'Excluir',
            onPressed: () {
              context.read<CardapioBloc>().add(DeleteCardapioItem(item.id!));
            },
          ),
        ],
      ),
    );
  }
}
