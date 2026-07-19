import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../game/presentation/providers/game_providers.dart';

/// Beautiful level map showing level nodes connected like a path
class LevelMapScreen extends ConsumerStatefulWidget {
  const LevelMapScreen({super.key});

  @override
  ConsumerState<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends ConsumerState<LevelMapScreen> {
  static const int _totalLevels = 30;
  final List<_MapNode> _nodes = [];
  final Map<int, int> _nodeIndex = {};

  @override
  void initState() {
    super.initState();
    _generateMap();
  }

  void _generateMap() {
    final rng = Random(42);
    double x = 0.5;
    double y = 0.9;
    for (int i = 0; i < _totalLevels; i++) {
      x = 0.15 + rng.nextDouble() * 0.7;
      y = 0.9 - (i / _totalLevels) * 0.85;
      _nodes.add(_MapNode(levelId: i + 1, x: x, y: y));
      _nodeIndex[i + 1] = i;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final maxUnlocked = currentUserAsync.valueOrNull?.maxUnlockedLevel ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المستويات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF9D97FF),
              Color(0xFFFFC9C9),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Path
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(
                      nodes: _nodes,
                      maxUnlocked: maxUnlocked,
                    ),
                  ),
                ),
                // Nodes
                ..._nodes.map((node) {
                  final isUnlocked = node.levelId <= maxUnlocked;
                  final isCompleted = node.levelId < maxUnlocked;
                  return Positioned(
                    left: node.x * constraints.maxWidth - 30,
                    top: node.y * constraints.maxHeight - 30,
                    child: _LevelNode(
                      levelId: node.levelId,
                      isUnlocked: isUnlocked,
                      isCompleted: isCompleted,
                      onTap: isUnlocked
                          ? () => context.goNamed(
                                'game',
                                pathParameters:
                                    {'levelId': '${node.levelId}'},
                              )
                          : null,
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapNode {
  _MapNode({required this.levelId, required this.x, required this.y});
  final int levelId;
  final double x;
  final double y;
}

class _PathPainter extends CustomPainter {
  _PathPainter({required this.nodes, required this.maxUnlocked});
  final List<_MapNode> nodes;
  final int maxUnlocked;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < nodes.length - 1; i++) {
      final from = Offset(
        nodes[i].x * size.width,
        nodes[i].y * size.height,
      );
      final to = Offset(
        nodes[i + 1].x * size.width,
        nodes[i + 1].y * size.height,
      );
      final isCompleted = nodes[i + 1].levelId <= maxUnlocked;
      final paint = Paint()
        ..color = isCompleted
            ? Colors.white.withOpacity(0.8)
            : Colors.white.withOpacity(0.3)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path();
      path.moveTo(from.dx, from.dy);
      // Curve through midpoints
      final mid = Offset(
        (from.dx + to.dx) / 2,
        (from.dy + to.dy) / 2,
      );
      path.quadraticBezierTo(from.dx, mid.dy, mid.dx, mid.dy);
      path.quadraticBezierTo(to.dx, mid.dy, to.dx, to.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) =>
      oldDelegate.maxUnlocked != maxUnlocked;
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.levelId,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
  });
  final int levelId;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isCompleted
              ? AppColors.oceanGradient
              : isUnlocked
                  ? AppColors.primaryGradient
                  : null,
          color: !isUnlocked ? Colors.white.withOpacity(0.3) : null,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isUnlocked
              ? Text(
                  '$levelId',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 24,
                ),
        ),
      ),
    );
  }
}
