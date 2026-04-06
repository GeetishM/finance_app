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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // Smooth, formal entrance duration
      duration: const Duration(milliseconds: 400), 
      vsync: this,
    );

    // Premium entrance: Smooth deceleration instead of a playful bounce
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() async {
    // 1. Subtle, quick shrink on tap (mimics a physical button press)
    await _controller.animateTo(
      0.85, 
      duration: const Duration(milliseconds: 100), 
      curve: Curves.easeOut,
    );
    
    // 2. Trigger the actual navigation/action
    widget.onPressed();
    
    // 3. Smoothly pop back to original size
    _controller.animateTo(
      1.0, 
      duration: const Duration(milliseconds: 250), 
      curve: Curves.easeOutBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppConstants.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0, 
          highlightElevation: 0,
          backgroundColor: Colors.transparent, 
          onPressed: _onPressed,
          // Removed the RotationTransition for a cleaner, static icon
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}