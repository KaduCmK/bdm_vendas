import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/repositories/cliente_repository.dart';
import 'package:bdm_vendas/service_locator.dart';
import 'package:bdm_vendas/ui/web/screens/components/novo_cliente_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ClientesScreen extends StatelessWidget {
  const ClientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClienteBloc>(
      create:
          (_) =>
              ClienteBloc(repository: sl<ClienteRepository>())
                ..add(LoadClientes()),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                state.clientes.map((cliente) {
                  final data = DateFormat(
                    'dd/MM/yyyy',
                  ).format(cliente.dataCriacao);
                  return Card(
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
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
