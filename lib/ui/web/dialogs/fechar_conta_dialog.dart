import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/ui/shared/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FecharContaDialog extends StatefulWidget {
  final Nota nota;
  const FecharContaDialog({super.key, required this.nota});

  @override
  State<FecharContaDialog> createState() => FecharContaDialogState();
}

class FecharContaDialogState extends State<FecharContaDialog> {
  late final TextEditingController _totalController;
  NotaStatus _selectedStatus = NotaStatus.pagoCredito;

  @override
  void initState() {
    super.initState();
    final totalFormatado = widget.nota.total
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    _totalController = TextEditingController(text: totalFormatado);
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  void _confirmarPagamento() {
    final notaAtualizada = widget.nota.copyWith(status: _selectedStatus);
    context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fechar Conta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _totalController,
            decoration: const InputDecoration(
              labelText: 'Valor Total Pago',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Método de Pagamento:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...NotaStatus.values.where((s) => s != NotaStatus.emAberto).map((
            status,
          ) {
            return RadioListTile<NotaStatus>(
              title: Text(
                status
                    .toString()
                    .split('.')
                    .last
                    .replaceAllMapped(
                      RegExp(r'([A-Z])'),
                      (match) => ' ${match.group(1)}',
                    )
                    .trim()
                    .replaceFirst('p', 'P')
                    .replaceFirst('d', 'D'),
              ),
              value: status,
              groupValue: _selectedStatus,
              onChanged: (value) {
                if (value != null) setState(() => _selectedStatus = value);
              },
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmarPagamento,
          child: const Text('Confirmar Pagamento'),
        ),
      ],
    );
  }
}
