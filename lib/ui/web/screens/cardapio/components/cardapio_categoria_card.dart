import 'package:flutter/material.dart';

class CardapioCategoriaCard extends StatefulWidget {
  final String title;
  final ScrollController scrollController;
  final VoidCallback? onTap;

  const CardapioCategoriaCard({
    super.key,
    required this.title,
    required this.scrollController,
    this.onTap,
  });

  @override
  State<CardapioCategoriaCard> createState() => _CardapioCategoriaCardState();
}

class _CardapioCategoriaCardState extends State<CardapioCategoriaCard> {
  final _imageKey = GlobalKey();
  var _imageOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_calculateParallax);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_calculateParallax);
    super.dispose();
  }

  void _calculateParallax() {
    if (!mounted || _imageKey.currentContext == null) return;

    final RenderBox renderBox =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final cardTopPosition = renderBox.localToGlobal(Offset.zero).dy;
    final screenHeight = MediaQuery.of(context).size.height;

    final verticalOffset = (cardTopPosition - (screenHeight / 2)) * -0.2;

    setState(() {
      _imageOffset = Offset(0, verticalOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      child: InkWell(
        onTap: widget.onTap,
        child: Hero(
          tag: widget.title,
          child: SizedBox(
            key: _imageKey,
            height: 300,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.translate(
                  offset: _imageOffset,
                  child: Image.asset(
                    'images/${widget.title}.jpg',
                    fit: BoxFit.cover, 
                  ),
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
                    widget.title,
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}