import 'package:bdm_vendas/bloc/nota/nota_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ViewNotaScreen extends StatefulWidget {
  final String notaId;
  const ViewNotaScreen({super.key, required this.notaId});

  @override
  State<ViewNotaScreen> createState() => _ViewNotaScreenState();
}

class _ViewNotaScreenState extends State<ViewNotaScreen> {
  @override
  void initState() {
    super.initState();
    _signInAnonymouslyAndFetchNota();
  }

  Future<void> _signInAnonymouslyAndFetchNota() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    if (!mounted) return;

    context.read<NotaBloc>().add(LoadNota(widget.notaId));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sua Comanda'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: BlocBuilder<NotaBloc, NotaState>(
          builder: (context, state) {
            if (state is NotaError) {
              return Text('Erro: ${state.message}');
            }
            if (state is! SingleNotaLoaded) {
              return const CircularProgressIndicator();
            }

            final nota = state.nota;
            final formatadorReais = NumberFormat.currency(
              locale: 'pt_BR',
              symbol: 'R\$',
            );

            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Resumo da Comanda',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aberta em: ${DateFormat('dd/MM/yyyy HH:mm').format(nota.dataCriacao)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 32),
                      Expanded(
                        child: ListView.builder(
                          itemCount: nota.produtos.length,
                          itemBuilder: (context, index) {
                            final produto = nota.produtos[index];
                            return ListTile(
                              title: Text(produto.nome),
                              subtitle: Text(
                                '${produto.quantidade} x ${formatadorReais.format(produto.valorUnitario)}',
                                style: textTheme.labelMedium,
                              ),
                              trailing: Text(
                                formatadorReais.format(produto.subtotal),
                                style: textTheme.titleSmall,
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            formatadorReais.format(nota.total),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
