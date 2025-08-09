import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart'; // Importe o modelo
import 'package:bdm_vendas/ui/web/components/nota_card.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotasScreen extends StatelessWidget {
  const NotasScreen({super.key});

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
          // <<< FILTRO APLICADO AQUI >>>
          final notasAbertas =
              notaState.notas
                  .where((nota) => nota.status == NotaStatus.emAberto)
                  .toList();

          return BlocBuilder<ClienteBloc, ClienteState>(
            builder: (context, clienteState) {
              if (clienteState is ClienteLoaded) {
                if (notasAbertas.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma nota em aberto no momento.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500, // Largura máxima de cada card
                    childAspectRatio: 0.9, // Proporção do card
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: notasAbertas.length,
                  itemBuilder: (context, index) {
                    final nota = notasAbertas[index]; // Usando a lista filtrada
                    final cliente = clienteState.clientes.firstWhereOrNull(
                      (c) => c.id == nota.clienteId,
                    );

                    return NotaCard(nota: nota, cliente: cliente);
                  },
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
