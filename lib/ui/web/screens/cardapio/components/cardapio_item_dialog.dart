import 'package:bdm_vendas/bloc/cardapio/cardapio_bloc.dart';
import 'package:bdm_vendas/bloc/categoria/categoria_bloc.dart';
import 'package:bdm_vendas/models/cardapio/cardapio_item.dart';
import 'package:bdm_vendas/models/cardapio/categoria.dart';
import 'package:bdm_vendas/ui/shared/currency_input_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // import firestore
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardapioItemDialog extends StatefulWidget {
  final CardapioItem? item;
  const CardapioItemDialog({super.key, this.item});

  @override
  State<CardapioItemDialog> createState() => _CardapioItemDialogState();
}

class _CardapioItemDialogState extends State<CardapioItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _precoController;
  String? _selectedCategoriaId;

  TipoItem? _selectedTipo;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item?.nome);
    _descricaoController = TextEditingController(text: widget.item?.descricao);
    _precoController = TextEditingController(
      text: widget.item?.preco.toStringAsFixed(2).replaceAll('.', ','),
    );
    _selectedCategoriaId = widget.item?.categoriaId.id;
    _selectedTipo = widget.item?.tipo ?? TipoItem.comida;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final precoString = _precoController.text
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final categoriaRef = FirebaseFirestore.instance
        .collection('categorias')
        .doc(_selectedCategoriaId); // cria a referencia

    final item = CardapioItem(
      id: widget.item?.id,
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      preco: double.tryParse(precoString) ?? 0.0,
      tipo: _selectedTipo!,
      categoriaId: categoriaRef, // salva a referencia
    );

    if (widget.item == null) {
      context.read<CardapioBloc>().add(AddCardapioItem(item));
    } else {
      context.read<CardapioBloc>().add(UpdateCardapioItem(item));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriaState = context.watch<CategoriaBloc>().state;
    List<Categoria> categoriasDoTipo = [];
    if (categoriaState is CategoriaLoaded) {
      // Filtra as categorias com base no TIPO de item selecionado
      categoriasDoTipo =
          categoriaState.categorias
              .where((c) => c.tipo == _selectedTipo)
              .toList();
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.item == null ? Icons.add_box_rounded : Icons.edit_square),
          const SizedBox(width: 8),
          Text(widget.item == null ? 'Novo Item' : 'Editar Item'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500, // Define uma largura para o diálogo
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.abc),
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição (Opcional)',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TipoItem>(
                        value: _selectedTipo,
                        onChanged:
                            (value) => setState(() {
                              _selectedTipo = value;
                              _selectedCategoriaId = null;
                            }),
                        items:
                            TipoItem.values
                                .map(
                                  (tipo) => DropdownMenuItem(
                                    value: tipo,
                                    child: Text(tipo.displayName),
                                  ),
                                )
                                .toList(),
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _precoController,
                        decoration: const InputDecoration(
                          labelText: 'Preço',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo obrigatório' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategoriaId,
                  hint: const Text('Selecione'),
                  // Usa a lista filtrada para as opções
                  items:
                      categoriasDoTipo.map((categoria) {
                        return DropdownMenuItem(
                          value: categoria.id,
                          child: Text(categoria.nome),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategoriaId = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    prefixIcon: Icon(Icons.bookmark),
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Campo obrigatório'
                              : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _salvar,
          icon: const Icon(Icons.save),
          label: const Text('Salvar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
