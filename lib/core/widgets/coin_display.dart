import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Animated coin counter that smoothly transitions between values
class CoinDisplay extends StatefulWidget {
  const CoinDisplay({
    required this.amount,
    this.onTap,
    this.showLabel = true,
    this.size = CoinDisplaySize.medium,
    this.iconSize,
    super.key,
  });

  final int amount;
  final VoidCallback? onTap;
  final bool showLabel;
  final CoinDisplaySize size;
  final double? iconSize;

  @override
  State<CoinDisplay> createState() => _CoinDisplayState();
}

enum CoinDisplaySize { small, medium, large }

class _CoinDisplayState extends State<CoinDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousAmount = 0;

  @override
  void initState() {
    super.initState();
    _previousAmount = widget.amount;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(CoinDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _previousAmount = oldWidget.amount;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getIconSize() {
    if (widget.iconSize != null) return widget.iconSize!;
    switch (widget.size) {
      case CoinDisplaySize.small:
        return 18;
      case CoinDisplaySize.medium:
        return 24;
      case CoinDisplaySize.large:
        return 32;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case CoinDisplaySize.small:
        return 14;
      case CoinDisplaySize.medium:
        return 18;
      case CoinDisplaySize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: _getIconSize() + 4,
                height: _getIconSize() + 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.goldDark,
                  size: _getIconSize(),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.amount.compact,
              style: AppTextStyles.counter.copyWith(
                fontSize: _getFontSize(),
                color: AppColors.goldDark,
              ),
            ),
            if (widget.showLabel) ...[
              const SizedBox(width: 4),
              Text(
                'عملة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.goldDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Gem / diamond counter
class GemDisplay extends StatelessWidget {
  const GemDisplay({
    required this.amount,
    this.onTap,
    super.key,
  });

  final int amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.oceanGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tertiary.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.diamond_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              amount.compact,
              style: AppTextStyles.counter.copyWith(
                fontSize: 18,
                color: AppColors.tertiaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
