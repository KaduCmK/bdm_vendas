import 'package:flutter/material.dart';

class LiveCircle extends StatefulWidget {
  final double size;
  final double maxPulseRadius;
  final Duration duration;
  final Color color;

  const LiveCircle({
    super.key,
    this.size = 16.0,
    this.maxPulseRadius = 32.0, // Este valor agora define o espaço total
    this.duration = const Duration(seconds: 2),
    this.color = Colors.green,
  });

  @override
  State<LiveCircle> createState() => _LiveCircleState();
}

class _LiveCircleState extends State<LiveCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A 'caixa' com tamanho fixo que vai conter a animação
    // O tamanho dela é o tamanho base + a expansão máxima da onda.
    final double maxContainerSize = widget.size + widget.maxPulseRadius;

    return SizedBox(
      width: maxContainerSize,
      height: maxContainerSize,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double pulseProgress = _animation.value;
          
          // O raio da onda agora é calculado sobre o espaço disponível
          final double currentPulseRadius = widget.maxPulseRadius * pulseProgress;
          final double opacity = 1.0 - pulseProgress;

          // O Stack agora fica dentro do SizedBox, permitindo a sobreposição
          return Stack(
            alignment: Alignment.center,
            children: [
              // Círculo da "onda" que se expande e desvanece
              Container(
                width: widget.size + currentPulseRadius,
                height: widget.size + currentPulseRadius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: opacity > 0 ? opacity : 0),
                ),
              ),
              // Círculo central (fixo)
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}