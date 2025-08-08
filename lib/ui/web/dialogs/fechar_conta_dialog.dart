import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/ui/shared/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pix_flutter/pix_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class FecharContaDialog extends StatefulWidget {
  final Nota nota;
  const FecharContaDialog({super.key, required this.nota});

  @override
  State<FecharContaDialog> createState() => FecharContaDialogState();
}

class FecharContaDialogState extends State<FecharContaDialog> {
  late final TextEditingController _totalController;
  NotaStatus _selectedStatus = NotaStatus.pagoCredito;
  var _pixQRCode;

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

  void _generatePixQRCode() {
    setState(() {
      PixFlutter pixFlutter = PixFlutter(
        payload: Payload(
          pixKey: '+5521990935252',
          merchantName: 'Bar do Malhado',
          merchantCity: 'Rio de Janeiro',
          txid: '***',
          amount: _totalController.text.replaceAll(',', '.'),
        ),
      );

      _pixQRCode = pixFlutter.getQRCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fechar Conta'),
      content: SizedBox(
        // <<< AQUI ESTÁ A CORREÇÃO
        width: 400, // <<< Define uma largura fixa para o conteúdo
        child: SingleChildScrollView(
          child: Column(
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
                  title: Text(status.toString()),
                  value: status,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                        _pixQRCode =
                            null; // Reseta o QR Code ao mudar a forma de pagamento
                      });
                    }
                  },
                );
              }),
              if (_selectedStatus == NotaStatus.pagoPix)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _generatePixQRCode,
                        child: const Text('Gerar QR Code PIX'),
                      ),
                      if (_pixQRCode != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: QrImageView(data: _pixQRCode),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
