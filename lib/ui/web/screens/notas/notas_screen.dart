import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart'; // Importe o modelo
import 'package:bdm_vendas/ui/web/components/nota_card.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotaBloc, NotaState>(
      builder: (context, notaState) {
        if (notaState is NotaLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (notaState is NotaError) {
          return Center(child: Text(notaState.message));
        }
        if (notaState is NotaLoaded) {
          final notasAbertas =
              notaState.notas
                  .where((nota) => nota.status == NotaStatus.emAberto)
                  .toList();

          return BlocBuilder<ClienteBloc, ClienteState>(
            builder: (context, clienteState) {
              if (clienteState is ClienteLoaded) {
                final filteredNotas =
                    notasAbertas.where((nota) {
                      final cliente = clienteState.clientes.firstWhereOrNull(
                        (c) => c.id == nota.clienteId,
                      );
                      if (cliente == null) return false;
                      return cliente.nome.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );
                    }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: 'Buscar por nome do cliente',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed:
                                () => context.read<NotaBloc>().add(LoadNotas()),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredNotas.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma nota encontrada.',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(4),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 540,
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: filteredNotas.length,
                              itemBuilder: (context, index) {
                                final nota = filteredNotas[index];
                                final cliente = clienteState.clientes
                                    .firstWhereOrNull(
                                        (c) => c.id == nota.clienteId);
                                final isLoading =
                                    notaState.loadingNoteIds.contains(nota.id);

                                return NotaCard(
                                    nota: nota,
                                    cliente: cliente,
                                    isLoading: isLoading);
                              },
                            ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        }
        return const Center(child: Text("Inicializando..."));
      },
    );
  }
}
