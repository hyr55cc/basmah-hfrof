import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive.dart';
import 'connection_painter.dart';
import 'letter_widget.dart';

/// The circle of letters where the game happens
class LetterCircle extends StatefulWidget {
  const LetterCircle({
    required this.letters,
    required this.selectedIndices,
    required this.hintedIndices,
    required this.connectionPoints,
    required this.currentPointerPosition,
    required this.isDragging,
    required this.onLetterTouched,
    required this.onLetterHovered,
    required this.onPointerMoved,
    required this.onSelectionEnded,
    super.key,
  });

  final List<String> letters;
  final List<int> selectedIndices;
  final Set<int> hintedIndices;
  final List<Offset> connectionPoints;
  final Offset? currentPointerPosition;
  final bool isDragging;
  final void Function(int index, Offset globalPosition) onLetterTouched;
  final void Function(int index, Offset globalPosition) onLetterHovered;
  final void Function(Offset position) onPointerMoved;
  final VoidCallback onSelectionEnded;

  @override
  State<LetterCircle> createState() => _LetterCircleState();
}

class _LetterCircleState extends State<LetterCircle> {
  List<Offset> _letterPositions = [];
  List<double> _letterDistances = [];
  final Map<int, GlobalKey> _letterKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePositions();
    });
  }

  @override
  void didUpdateWidget(LetterCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.letters.length != widget.letters.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculatePositions();
      });
    }
  }

  void _calculatePositions() {
    if (!mounted) return;
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final size = box.size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = Responsive.gameCircleRadius(context);
    final positions = <Offset>[];
    final distances = <double>[];
    final n = widget.letters.length;
    // Start from top (-90 degrees = -pi/2) and go clockwise
    for (int i = 0; i < n; i++) {
      final angle = -pi / 2 + (2 * pi * i / n);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      positions.add(Offset(x, y));
      distances.add(radius);
    }
    setState(() {
      _letterPositions = positions;
      _letterDistances = distances;
      // Ensure keys exist
      for (int i = 0; i < n; i++) {
        _letterKeys.putIfAbsent(i, () => GlobalKey());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final letterSize = Responsive.gameLetterSize(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              // Connection line painter
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ConnectionPainter(
                      connectionPoints: widget.connectionPoints,
                      currentPointerPosition: widget.currentPointerPosition,
                      isDragging: widget.isDragging,
                      isValidSoFar: true,
                    ),
                  ),
                ),
              ),
              // Letters
              ...List.generate(widget.letters.length, (i) {
                if (i >= _letterPositions.length) {
                  return const SizedBox.shrink();
                }
                return LetterWidget(
                  key: _letterKeys[i],
                  letter: widget.letters[i],
                  position: _letterPositions[i],
                  size: letterSize,
                  isSelected: widget.selectedIndices.contains(i),
                  isHinted: widget.hintedIndices.contains(i),
                  isFound: false,
                  onPanStart: (globalPos) {
                    _onLetterInteraction(i, globalPos, start: true);
                  },
                  onPanUpdate: (globalPos) {
                    _onLetterInteraction(i, globalPos, start: false);
                  },
                  onTap: () {
                    widget.onLetterTouched(i, _letterPositions[i]);
                    widget.onSelectionEnded();
                  },
                );
              }),
              // Pan detector for the whole area
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanStart: (details) {
                    _findLetterAt(details.globalPosition, start: true);
                  },
                  onPanUpdate: (details) {
                    widget.onPointerMoved(details.localPosition);
                    _findLetterAt(details.globalPosition, start: false);
                  },
                  onPanEnd: (_) {
                    widget.onSelectionEnded();
                  },
                  onPanCancel: () {
                    widget.onSelectionEnded();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onLetterInteraction(
    int index,
    Offset globalPos, {
    required bool start,
  }) {
    if (start) {
      widget.onLetterTouched(index, globalPos);
    } else {
      widget.onLetterHovered(index, globalPos);
    }
  }

  void _findLetterAt(Offset globalPos, {required bool start}) {
    final letterSize = Responsive.gameLetterSize(context);
    final hitRadius = letterSize / 2;
    for (int i = 0; i < _letterPositions.length; i++) {
      if (_letterPositions[i] == Offset.zero) continue;
      // Convert global position to local
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final localPos = box.globalToLocal(globalPos);
      final dist = (_letterPositions[i] - localPos).distance;
      if (dist <= hitRadius) {
        if (start) {
          widget.onLetterTouched(i, globalPos);
        } else {
          widget.onLetterHovered(i, globalPos);
        }
        return;
      }
    }
  }
}
