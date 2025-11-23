import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final List<String> methods;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.methods = const ['Dinheiro', 'Crédito', 'Débito', 'Pix'],
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: methods.map((method) {
        return _PaymentMethodChoice(
          method: method,
          isSelected: selectedMethod == method,
          onTap: onMethodChanged,
        );
      }).toList(),
    );
  }
}

class _PaymentMethodChoice extends StatelessWidget {
  final String method;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _PaymentMethodChoice({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  Widget _getIcon(BuildContext context) {
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[700];
    switch (method) {
      case 'Crédito':
      case 'Débito':
        return Icon(Icons.credit_card, color: color, size: 28);
      case 'Dinheiro':
        return Icon(Icons.attach_money, color: color, size: 28);
      case 'Pix':
        return SvgPicture.asset(
          'assets/icons/pix.svg',
          height: 28,
          width: 28,
          colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        );
      default:
        return Icon(Icons.help_outline, color: color, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onTap(method),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            _getIcon(context),
            const SizedBox(height: 4),
            Text(
              method,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
