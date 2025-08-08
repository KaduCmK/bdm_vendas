import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotaCard extends StatelessWidget {
  final Nota nota;
  final Cliente? cliente;
  const NotaCard({super.key, required this.nota, this.cliente});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text(cliente?.nome ?? 'Cliente não encontrado'),
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.calendar_month, size: 16),
                Text(DateFormat('dd/MM/yyyy').format(nota.dataCriacao)),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
