import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArquivadaNotaCard extends StatelessWidget {
  final Nota nota;
  final Cliente? cliente;

  const ArquivadaNotaCard({super.key, required this.nota, this.cliente});

  @override
  Widget build(BuildContext context) {
    final formatadorReais =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com nome do cliente e data
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(cliente?.nome ?? 'Cliente não encontrado',
                  style: Theme.of(context).textTheme.titleLarge),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(nota.dataCriacao)),
              trailing: PopupMenuButton<int>(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 1,
                    child: Text("Opção 1 (placeholder)"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text("Opção 2 (placeholder)"),
                  ),
                ],
                onSelected: (value) {
                  // Lógica para o menu (placeholder)
                },
              ),
            ),
            const Divider(),

            // Lista de produtos
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Itens Consumidos",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: nota.produtos.length,
                itemBuilder: (context, index) {
                  final produto = nota.produtos[index];
                  return ListTile(
                    dense: true,
                    title: Text(produto.nome),
                    leading: Text("${produto.quantidade}x"),
                    trailing: Text(formatadorReais.format(produto.subtotal)),
                  );
                },
              ),
            ),
            const Divider(),

            // Rodapé com Total e Status
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${formatadorReais.format(nota.total)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text(nota.status.displayName),
                    avatar: const Icon(Icons.check_circle),
                    backgroundColor: Colors.green.shade100,
                  )
                ],
              ),
            ),
            if (nota.dataFechamento != null)
              Text('Fechada em ${DateFormat('dd/MM/yyyy HH:mm').format(nota.dataFechamento!)}'),
          ],
        ),
      ),
    );
  }
}