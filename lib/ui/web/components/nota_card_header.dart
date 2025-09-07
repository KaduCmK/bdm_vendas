import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/ui/web/screens/notas/components/share_nota_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotaCardHeader extends StatelessWidget {
  final Cliente? cliente;
  final Nota nota;
  const NotaCardHeader({super.key, this.cliente, required this.nota});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(cliente?.nome ?? 'Cliente não encontrado'),
      subtitle: Row(
        children: [
          const Icon(Icons.calendar_month, size: 16),
          const SizedBox(width: 4),
          Text(DateFormat('dd/MM/yyyy').format(nota.dataCriacao)),
        ],
      ),
      trailing: IconButton(
        onPressed:
            () => showDialog(
              context: context,
              builder:
                  (context) => ShareNotaDialog(
                    notaUrl: '${Uri.base.origin}/#/view-nota/${nota.id}',
                  ),
            ),
        icon: Icon(Icons.qr_code),
      ),
    );
  }
}
