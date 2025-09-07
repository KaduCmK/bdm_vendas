import 'package:bdm_vendas/bloc/cardapio/cardapio_bloc.dart';
import 'package:bdm_vendas/bloc/categoria/categoria_bloc.dart';
import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/components/cardapio_categoria_card.dart';
import 'package:bdm_vendas/ui/web/screens/cardapio/components/tipoitem_header.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CardapioTipoitemScreen extends StatefulWidget {
  final String tipoItemTitulo;

  const CardapioTipoitemScreen({super.key, required this.tipoItemTitulo});

  @override
  State<CardapioTipoitemScreen> createState() => _CardapioTipoitemScreenState();
}

class _CardapioTipoitemScreenState extends State<CardapioTipoitemScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatadorReais = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final tipoItem = TipoItem.values.firstWhere(
      (e) => widget.tipoItemTitulo.toLowerCase().startsWith(
        e.displayName.toLowerCase(),
      ),
      orElse: () => TipoItem.comida,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<CardapioBloc, CardapioState>(
        builder: (context, cardapioState) {
          if (cardapioState is! CardapioLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<CategoriaBloc, CategoriaState>(
            builder: (context, categoriaState) {
              if (categoriaState is! CategoriaLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final categoriasDoTipo =
                  categoriaState.categorias
                      .where((c) => c.tipo == tipoItem)
                      .toList();

              final itensDoTipo =
                  cardapioState.itens
                      .where((item) => item.tipo == tipoItem)
                      .toList();

              final itensAgrupados = groupBy(
                itensDoTipo,
                (CardapioItem item) => item.categoriaId.id,
              );

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  TipoitemHeader(tipoItemTitulo: widget.tipoItemTitulo),
                  ...categoriasDoTipo.expand((categoria) {
                    final itensDaCategoria = itensAgrupados[categoria.id] ?? [];

                    if (itensDaCategoria.isEmpty) return [];

                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: CardapioCategoriaCard(
                            title: categoria.nome.toUpperCase(),
                            scrollController: _scrollController,
                            height: 128,
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = itensDaCategoria[index];
                          return ListTile(
                            title: Text(
                              item.nome,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle:
                                item.descricao != null
                                    ? Text(
                                      item.descricao!,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                                    : null,
                            trailing: Text(
                              formatadorReais.format(item.preco),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }, childCount: itensDaCategoria.length),
                      ),
                    ];
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
