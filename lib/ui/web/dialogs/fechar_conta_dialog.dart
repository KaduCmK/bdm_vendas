import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:bdm_vendas/models/nota.dart';
import 'package:bdm_vendas/ui/shared/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
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
    final notaAtualizada = widget.nota.copyWith(
      status: _selectedStatus,
      dataFechamento: DateTime.now(),
    );
    context.read<NotaBloc>().add(UpdateNota(notaAtualizada));
    context.pop();
  }

  void _generatePixQRCode() {
    PixFlutter pixFlutter = PixFlutter(
      payload: Payload(
        pixKey: '+5521990935252',
        merchantName: 'Bar do Malhado',
        merchantCity: 'Rio de Janeiro',
        txid: '***',
        amount: _totalController.text.replaceAll(',', '.'),
      ),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('QR Code Pix'),
            content: SizedBox(
              height: 400,
              width: 400,
              child: QrImageView(size: 400, data: pixFlutter.getQRCode()),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fechar Conta'),
      content: SizedBox(
        width: 400,
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    NotaStatus.values
                        .where((s) => s != NotaStatus.emAberto)
                        .map((status) {
                          return _PaymentMethodWidget(
                            status: status,
                            isSelected: _selectedStatus == status,
                            onTap: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                          );
                        })
                        .toList(),
              ),
              if (_selectedStatus == NotaStatus.pagoPix)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _generatePixQRCode,
                        child: const Text('Gerar QR Code PIX'),
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

class _PaymentMethodWidget extends StatelessWidget {
  final NotaStatus status;
  final bool isSelected;
  final Function(NotaStatus) onTap;

  const _PaymentMethodWidget({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  Widget _getIcon(BuildContext context) {
    switch (status) {
      case NotaStatus.pagoCredito:
      case NotaStatus.pagoDebito:
        return Icon(
          Icons.credit_card,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[700],
          size: 28,
        );
      case NotaStatus.pagoDinheiro:
        return Icon(
          Icons.attach_money,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[700],
          size: 28,
        );
      case NotaStatus.pagoPix:
        return SvgPicture.asset(
          'icons/pix.svg',
          height: 28,
          width: 28,
          colorFilter: ColorFilter.mode(
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[700]!,
            BlendMode.srcIn,
          ),
        );
      default:
        return Icon(
          Icons.help_outline,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[700],
          size: 28,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(status),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            _getIcon(context),
            const SizedBox(height: 4),
            Text(
              status.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
