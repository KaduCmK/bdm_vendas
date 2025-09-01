import 'package:flutter/material.dart';

class TipoitemHeader extends StatelessWidget {
  final String tipoItemTitulo;

  const TipoitemHeader({super.key, required this.tipoItemTitulo});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                tipoItemTitulo,
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Hero(
                tag: tipoItemTitulo,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('images/$tipoItemTitulo.jpg', fit: BoxFit.cover),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0, 0.9],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}