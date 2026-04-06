import 'package:flutter/material.dart';

class AppAnimations {
  // Page Route Animations
  static PageRoute slidePageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  static PageRoute fadePageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRoute scalePageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        );

        return ScaleTransition(scale: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

// Stagger Animation Helper
class StaggerAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delay;

  const StaggerAnimation({
    Key? key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

// Scale and Fade Animation
class ScaleFadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ScaleFadeAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

// Slide Animation
class SlideInAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: beginOffset, end: Offset.zero),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, offset, child) {
        return Transform.translate(offset: offset, child: child);
      },
      child: child,
    );
  }
}

// Bounce Animation
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final bool animate;

  const BounceAnimation({
    Key? key,
    required this.child,
    this.animate = true,
  }) : super(key: key);

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 1.1)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _animation, child: widget.child);
  }
}