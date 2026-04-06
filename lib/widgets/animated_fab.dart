import 'package:flutter/material.dart';
import 'package:finance_app/utils/constants.dart';

class AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AnimatedFAB({
    Key? key,
    required this.onPressed,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  State<AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() {
    _controller.reverse().then((_) {
      widget.onPressed();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: FloatingActionButton(
          onPressed: _onPressed,
          backgroundColor: AppConstants.primaryColor,
          elevation: 8,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}