import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmarNotaDialog extends StatelessWidget {
  final Cliente cliente;

  const ConfirmarNotaDialog({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text("Nova Nota"),
      content: Text("Deseja criar uma nota para \"${cliente.nome}\"?"),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedButton(
          child: const Text("Criar"),
          onPressed: () {
            final newNota = Nota(
              clienteId: cliente.id!,
              dataCriacao: DateTime.now(),
              produtos: [],
            );
            context.read<NotaBloc>().add(AddNota(newNota));
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
