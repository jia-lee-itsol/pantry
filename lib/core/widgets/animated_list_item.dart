import 'package:flutter/material.dart';

/// Animated List Item Widget
///
/// A widget that applies slide and fade animations to list items.
/// Creates a smooth, staggered entrance effect when lists are updated,
/// enhancing the user experience with polished animations.
///
/// Features:
/// - Slide-in animation from bottom
/// - Fade-in animation
/// - Staggered effect based on item index
/// - Customizable animation duration
///
/// Usage:
/// ```dart
/// ListView.builder(
///   itemBuilder: (context, index) {
///     return AnimatedListItem(
///       index: index,
///       child: ListTile(title: Text('Item $index')),
///     );
///   },
/// );
/// ```
class AnimatedListItem extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// The index of the item (used for stagger delay)
  final int index;

  /// Animation duration (default: 300ms)
  final Duration duration;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Delayed start based on index (stagger effect)
    Future.delayed(
      Duration(milliseconds: widget.index * 50),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

