import 'package:flutter/material.dart';

class AnimatedTransactionListItem extends StatefulWidget {
  final String title;
  final String amount;
  final String date;
  final Color categoryColor;
  final IconData categoryIcon;
  final VoidCallback? onTap;
  final VoidCallback? onEdit; // 🛠️ ADDED: New onEdit callback
  final VoidCallback? onDelete;

  const AnimatedTransactionListItem({
    Key? key,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryColor,
    required this.categoryIcon,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<AnimatedTransactionListItem> createState() =>
      _AnimatedTransactionListItemState();
}

class _AnimatedTransactionListItemState
    extends State<AnimatedTransactionListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Dismissible(
          key: Key(widget.title + widget.date),
          // 🛠️ UX FIX: Allow swiping both left and right
          direction: DismissDirection.horizontal,
          
          // 🛠️ UX FIX: Background for sliding Left-to-Right (EDIT)
          background: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1), // Primary Indigo Color
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
          ),

          // 🛠️ UX FIX: Background for sliding Right-to-Left (DELETE)
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
          ),

          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // 🛠️ Trigger Edit action
              widget.onEdit?.call();
              // Return false so the item bounces back and isn't removed from the list
              return false; 
            } else if (direction == DismissDirection.endToStart) {
              // 🛠️ Trigger Delete confirmation
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      "Delete Transaction",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    content: const Text(
                      "Are you sure you want to delete this transaction?",
                    ),
                    actionsPadding: const EdgeInsets.all(16),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            return false;
          },
          onDismissed: (direction) {
            // Only trigger onDelete if swiped right-to-left
            if (direction == DismissDirection.endToStart) {
              widget.onDelete?.call();
            }
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.categoryIcon,
                        color: widget.categoryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.date,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Colors.grey[500],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.amount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.categoryColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}