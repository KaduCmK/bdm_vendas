import 'package:bdm_vendas/bloc/cliente/cliente_bloc.dart';
import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/ui/web/components/arquivada_nota_card.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotasArquivadasScreen extends StatelessWidget {
  const NotasArquivadasScreen({super.key});

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
          final notasArquivadas =
              notaState.notas
                  .where((nota) => nota.status != NotaStatus.emAberto)
                  .toList();

          if (notasArquivadas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma nota arquivada.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return BlocBuilder<ClienteBloc, ClienteState>(
            builder: (context, clienteState) {
              if (clienteState is ClienteLoaded) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 450, // Largura máxima de cada card
                    childAspectRatio: 0.9, // Proporção do card
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: notasArquivadas.length,
                  itemBuilder: (context, index) {
                    final nota = notasArquivadas[index];
                    final cliente = clienteState.clientes.firstWhereOrNull(
                      (c) => c.id == nota.clienteId,
                    );
                    return ArquivadaNotaCard(nota: nota, cliente: cliente);
                  },
                );
              }
              // Se os clientes ainda não carregaram
              return const Center(child: CircularProgressIndicator());
            },
          );
        }
        // Estado inicial
        return const Center(child: Text("Inicializando..."));
      },
    );
  }
}
