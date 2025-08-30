import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/ui/web/screens/clientes/confirmar_nota_dialog.dart';
import 'package:bdm_vendas/ui/web/screens/clientes/novo_cliente_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ClientesScreen extends StatelessWidget {
  final VoidCallback onNavigateToNotas;

  const ClientesScreen({super.key, required this.onNavigateToNotas});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClienteBloc, ClienteState>(
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
    );
  }

  Widget _buildContent(BuildContext context, ClienteLoaded state) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FloatingActionButton.extended(
              onPressed:
                  () => showDialog(
                    context: context,
                    builder: (_) => NovoClienteDialog(),
                  ),
              icon: const Icon(Icons.add),
              label: const Text("Novo Cliente"),
            ),
          ),
          Divider(),
          Chip(
            avatar: Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: Text(
              "Toque em um cliente para criar uma nova nota pra ele",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 230,
                childAspectRatio: 3 / 2,
              ),
              itemCount: state.clientes.length,
              itemBuilder: (context, index) {
                final cliente = state.clientes[index];
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
                          onNavigateToNotas();
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(child: Icon(Icons.person)),
                          Text(
                            cliente.nome,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
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
