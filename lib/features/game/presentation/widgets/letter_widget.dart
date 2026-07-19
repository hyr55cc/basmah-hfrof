import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Single letter in the game circle
class LetterWidget extends StatefulWidget {
  const LetterWidget({
    super.key,
    required this.letter,
    required this.position,
    required this.size,
    required this.isSelected,
    required this.isHinted,
    required this.isFound,
    this.onPanStart,
    this.onPanUpdate,
    this.onTap,
  });

  final String letter;
  final Offset position;
  final double size;
  final bool isSelected;
  final bool isHinted;
  final bool isFound;
  final void Function(Offset globalPosition)? onPanStart;
  final void Function(Offset globalPosition)? onPanUpdate;
  final VoidCallback? onTap;

  @override
  State<LetterWidget> createState() => _LetterWidgetState();
}

class _LetterWidgetState extends State<LetterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(LetterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _scaleController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.isSelected) return AppColors.letterSelected;
    if (widget.isHinted) return AppColors.letterHint;
    if (widget.isFound) return AppColors.letterFound;
    return AppColors.letterDefault;
  }

  Color _getTextColor() {
    if (widget.isSelected || widget.isHinted || widget.isFound) {
      return Colors.white;
    }
    return AppColors.textPrimaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: widget.position.dx - widget.size / 2,
      top: widget.position.dy - widget.size / 2,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onPanStart: widget.onPanStart == null
              ? null
              : (details) {
                  widget.onPanStart!(details.globalPosition);
                },
          onPanUpdate: widget.onPanUpdate == null
              ? null
              : (details) {
                  widget.onPanUpdate!(details.globalPosition);
                },
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isSelected
                    ? AppColors.primary
                    : widget.isHinted
                        ? AppColors.gold
                        : AppColors.borderLight,
                width: widget.isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getBackgroundColor().withOpacity(0.4),
                  blurRadius: widget.isSelected ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.letter,
                style: AppTextStyles.letter.copyWith(
                  color: _getTextColor(),
                  fontSize: widget.size * 0.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
