import 'package:bdm_vendas/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimelineDialog extends StatelessWidget {
  final Nota nota;

  const TimelineDialog({super.key, required this.nota});

  @override
  Widget build(BuildContext context) {
    final sortedProdutos = List.from(nota.produtos)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Descending order

    return AlertDialog(
      title: const Text('Linha do Tempo da Nota'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itens do mais recente ao mais antigo:',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: sortedProdutos.length,
                itemBuilder: (context, index) {
                  final produto = sortedProdutos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: const Icon(Icons.add_shopping_cart),
                      title: Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy - HH:mm:ss').format(produto.createdAt),
                      ),
                      trailing: Text(
                        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(produto.valorUnitario),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
