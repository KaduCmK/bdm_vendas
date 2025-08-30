import 'package:flutter/material.dart';

class CardapioScreen extends StatelessWidget {
  const CardapioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Column(
            spacing: 8,
            children: [
              const SizedBox(height: 64, width: 64, child: Placeholder()),
              Text("CARDÁPIO DIGITAL", style: textTheme.displaySmall),
              const Divider(height: 32),
              Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                ),
                elevation: 8,
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://images.unsplash.com/photo-1599409831034-858f59a16a49?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1771&q=80',
                        fit: BoxFit.cover,
                      ),

                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.transparent],
                            begin: Alignment.bottomLeft,
                            end: Alignment(0, -6),
                            stops: [0, 0.6],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Text(
                          "COMIDAS",
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
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
