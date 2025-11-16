import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/ui/web/screens/clientes/confirmar_nota_dialog.dart';
import 'package:bdm_vendas/ui/web/screens/clientes/novo_cliente_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ClientesScreen extends StatefulWidget {
  final VoidCallback onNavigateToNotas;

  const ClientesScreen({super.key, required this.onNavigateToNotas});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _searchController = TextEditingController();
  List<Cliente> _filteredClientes = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<ClienteBloc>().state;
    if (state is ClienteLoaded) {
      _filteredClientes = state.clientes;
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final state = context.read<ClienteBloc>().state;
    if (state is ClienteLoaded) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredClientes = state.clientes.where((cliente) {
          final nomeCliente = cliente.nome.toLowerCase();
          return nomeCliente.contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClienteBloc, ClienteState>(
      listener: (context, state) {
        if (state is ClienteLoaded) {
          _onSearchChanged();
        }
      },
      child: BlocBuilder<ClienteBloc, ClienteState>(
        builder: (context, state) {
          if (state is ClienteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ClienteError) {
            return Center(child: Text(state.message));
          }

          if (state is ClienteLoaded) {
            return _buildContent(context, state);
          }

          return const Center(child: Text("Inicializando"));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ClienteLoaded state) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => NovoClienteDialog(),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text("Novo Cliente"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Pesquisar Cliente",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              avatar: Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                "Toque em um cliente para criar uma nova nota pra ele",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 230,
                childAspectRatio: 3 / 2.1, // Adjusted to fix overflow
              ),
              itemCount: _filteredClientes.length,
              itemBuilder: (context, index) {
                final cliente = _filteredClientes[index];
                final data = DateFormat(
                  'dd/MM/yyyy',
                ).format(cliente.dataCriacao);

                return Card(
                  child: InkWell(
                    onTap: () {
                      showAdaptiveDialog(
                        context: context,
                        builder: (_) => ConfirmarNotaDialog(cliente: cliente),
                      ).then((value) {
                        if (value ?? false) {
                          widget.onNavigateToNotas();
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          const SizedBox(height: 8),
                          Text(
                            cliente.nome,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Criado em $data",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}