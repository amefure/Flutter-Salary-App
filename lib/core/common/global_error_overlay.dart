import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlobalErrorOverlay extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const GlobalErrorOverlay({
    super.key,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<GlobalErrorOverlay> createState() => _GlobalErrorOverlayState();
}

class _GlobalErrorOverlayState extends State<GlobalErrorOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _show();
  }

  Future<void> _show() async {
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            elevation: 6,
            color: Colors.red,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
