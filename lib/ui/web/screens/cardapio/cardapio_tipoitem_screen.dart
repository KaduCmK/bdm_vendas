import 'package:bdm_vendas/bloc/categoria/categoria_bloc.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/components/tipoitem_header.dart';
import 'package:flutter/material.dart';

class CardapioTipoitemScreen extends StatelessWidget {
  final String tipoItemTitulo;

  const CardapioTipoitemScreen({super.key, required this.tipoItemTitulo});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          TipoitemHeader(tipoItemTitulo: tipoItemTitulo)

          // lista de itens aqui
        ],
      ),
    );
  }
}
