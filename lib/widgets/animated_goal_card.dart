import 'package:flutter/material.dart';

class AnimatedGoalProgressCard extends StatefulWidget {
  final String goalTitle;
  final double progressPercentage;
  final String currentAmount;
  final String targetAmount;
  final Color primaryColor;
  final VoidCallback? onTap;

  const AnimatedGoalProgressCard({
    Key? key,
    required this.goalTitle,
    required this.progressPercentage,
    required this.currentAmount,
    required this.targetAmount,
    required this.primaryColor,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedGoalProgressCard> createState() =>
      _AnimatedGoalProgressCardState();
}

class _AnimatedGoalProgressCardState extends State<AnimatedGoalProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.goalTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Text(
                          '${(widget.progressPercentage * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: widget.primaryColor,
                              ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: widget.progressPercentage.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.primaryColor),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.currentAmount,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    widget.targetAmount,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}