import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareNotaDialog extends StatelessWidget {
  final String notaUrl;

  const ShareNotaDialog({super.key, required this.notaUrl});

  @override
  Widget build(BuildContext context) {
    final double qrCodeSize = 350;
    debugPrint(notaUrl);

    return AlertDialog(
      title: const Text("Compartilhar nota com cliente"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Exiba este QRCode para o cliente escanear"),
          const SizedBox(height: 16),
          SizedBox(
            height: qrCodeSize,
            width: qrCodeSize,
            child: QrImageView(
              data: notaUrl,
              version: QrVersions.auto,
              size: qrCodeSize,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text("Fechar")),
      ],
    );
  }
}
