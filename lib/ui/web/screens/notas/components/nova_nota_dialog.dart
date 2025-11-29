import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NovaNotaDialog extends StatefulWidget {
  const NovaNotaDialog({super.key});

  @override
  State<NovaNotaDialog> createState() => _NovaNotaDialogState();
}

class _NovaNotaDialogState extends State<NovaNotaDialog> {
  Cliente? _selectedCliente;
  final _searchController = TextEditingController();
  List<Cliente> _filteredClientes = [];

  @override
  void initState() {
    super.initState();
    final clienteState = context.read<ClienteBloc>().state;
    if (clienteState is ClienteLoaded) {
      _filteredClientes = clienteState.clientes;
    }
    _searchController.addListener(_filterClientes);
  }

  void _filterClientes() {
    final clienteState = context.read<ClienteBloc>().state;
    if (clienteState is ClienteLoaded) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredClientes =
            clienteState.clientes.where((cliente) {
              return cliente.nome.toLowerCase().contains(query);
            }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nova Nota"),
      content: BlocBuilder<ClienteBloc, ClienteState>(
        builder: (context, state) {
          if (state is ClienteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ClienteError) {
            return Center(child: Text(state.message));
          }
          if (state is ClienteLoaded) {
            return SizedBox(
              width: 400,
              height: 300,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar cliente',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredClientes.length,
                      itemBuilder: (context, index) {
                        final cliente = _filteredClientes[index];
                        return ListTile(
                          title: Text(cliente.nome),
                          onTap: () {
                            setState(() {
                              _selectedCliente = cliente;
                            });
                          },
                          selected: _selectedCliente?.id == cliente.id,
                          selectedTileColor: Colors.grey.shade300,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Text("Nenhum cliente encontrado.");
        },
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed:
              _selectedCliente == null
                  ? null
                  : () {
                    final newNota = Nota(
                      clienteId: _selectedCliente!.id!,
                      dataCriacao: DateTime.now(),
                      produtos: [],
                      isSplitted: true,
                    );
                    context.read<NotaBloc>().add(AddNota(newNota));
                    Navigator.of(context).pop();
                  },
          child: const Text("Salvar"),
        ),
      ],
    );
  }
}
