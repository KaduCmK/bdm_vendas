import 'package:bdm_vendas/models/cliente.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/ui/web/dialogs/timeline_dialog.dart';
import 'package:bdm_vendas/ui/web/screens/notas/components/share_nota_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotaCardHeader extends StatelessWidget {
  final Cliente? cliente;
  final Nota nota;
  final bool isLoading;
  const NotaCardHeader({super.key, this.cliente, required this.nota, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(cliente?.nome ?? 'Cliente não encontrado'),
          subtitle: Row(
            children: [
              const Icon(Icons.calendar_month, size: 16),
              const SizedBox(width: 4),
              Text(DateFormat('dd/MM/yyyy').format(nota.dataCriacao)),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (nota.isSplitted)
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => TimelineDialog(nota: nota),
                  ),
                  icon: const Icon(Icons.history),
                  tooltip: 'Histórico da Nota',
                ),
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ShareNotaDialog(
                    notaUrl: '${Uri.base.origin}/#/view-nota/${nota.id}',
                  ),
                ),
                icon: const Icon(Icons.qr_code),
              ),
            ],
          ),
        ),
        if (isLoading)
          const LinearProgressIndicator()
        else
          const SizedBox(height: 4.0), // Reserve space for the indicator
      ],
    );
  }
}
