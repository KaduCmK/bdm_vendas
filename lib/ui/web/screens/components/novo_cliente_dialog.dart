import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NovoClienteDialog extends StatelessWidget {
  final _nomeController = TextEditingController();

  NovoClienteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Novo Cliente"),
      content: TextField(
        controller: _nomeController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Nome do cliente',
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text("Salvar"),
          onPressed: () {
            context.read<ClienteBloc>().add(AddCliente(_nomeController.text));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
