import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TVFocusCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isFocused;
  final double height;
  final double width;
  final EdgeInsets padding;
  final Color focusColor;

  const TVFocusCard({
    super.key,
    required this.child,
    required this.onTap,
    this.isFocused = false,
    this.height = 200,
    this.width = double.infinity,
    this.padding = const EdgeInsets.all(20),
    this.focusColor = AppColors.secondary,
  });

  @override
  State<TVFocusCard> createState() => _TVFocusCardState();
}

class _TVFocusCardState extends State<TVFocusCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeFocus = widget.isFocused || _isHovered;

    return Focus(
      onFocusChange: (focused) => setState(() => _isHovered = focused),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: widget.height,
          width: widget.width,
          padding: widget.padding,
          transform: activeFocus ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: activeFocus ? AppColors.surfaceHigh : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activeFocus ? widget.focusColor : AppColors.outlineVariant.withValues(alpha: 0.3),
              width: activeFocus ? 3 : 1,
            ),
            boxShadow: activeFocus
                ? [
                    BoxShadow(
                      color: widget.focusColor.withValues(alpha: 0.45),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                    )
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
