import 'package:bdm_vendas/ui/web/screens/cardapio/components/cardapio_categoria_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardapioScreen extends StatefulWidget {
  const CardapioScreen({super.key});

  @override
  State<CardapioScreen> createState() => _CardapioScreenState();
}

class _CardapioScreenState extends State<CardapioScreen> {
  late final ScrollController _scrollController;

  bool _textVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController =
        ScrollController()..addListener(() {
          setState(() {
            _textVisible = _scrollController.offset <= 32;
          });
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            expandedHeight: screenHeight,
            collapsedHeight: screenHeight * 0.1,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/header.jpg', fit: BoxFit.fitHeight),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                        stops: [0.0, 0.8],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: screenHeight * 0.25,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: _textVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 225),
                      child: Text(
                        'CARDÁPIO',
                        style: textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              title: Image.asset(
                'assets/images/logo.png',
                height: screenHeight * 0.15,
                isAntiAlias: true,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: screenHeight * 0.1),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: screenHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CardapioCategoriaCard(
                    title: "COMIDAS",
                    scrollController: _scrollController,
                    onTap: () => context.push('/cardapio/COMIDAS'),
                  ),
                  CardapioCategoriaCard(
                    title: "BEBIDAS",
                    scrollController: _scrollController,
                    onTap: () => context.push('/cardapio/BEBIDAS'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
