import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/coin_display.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../services/haptics/haptic_service.dart';
import '../../core/game_controller.dart';
import '../providers/game_providers.dart';
import '../widgets/letter_circle.dart';
import '../widgets/word_list_panel.dart';
import '../widgets/hint_sheet.dart';
import '../widgets/level_complete_dialog.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({required this.levelId, super.key});
  final int levelId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final GlobalKey _circleKey = GlobalKey();
  late ConfettiController _confettiController;
  bool _hasShownCompletion = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onLevelCompleted(int coinsEarned) {
    HapticService().levelComplete();
    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LevelCompleteDialog(
          levelId: widget.levelId,
          coinsEarned: coinsEarned,
          onNext: () {
            Navigator.of(context).pop();
            _goToNextLevel();
          },
          onReplay: () {
            Navigator.of(context).pop();
            _restartLevel();
          },
          onHome: () {
            Navigator.of(context).pop();
            context.goNamed('home');
          },
        ),
      );
    });
  }

  void _goToNextLevel() {
    setState(() {
      _hasShownCompletion = false;
    });
    ref.invalidate(gameControllerProvider(widget.levelId + 1));
    context.goNamed('game', pathParameters: {'levelId': '${widget.levelId + 1}'});
  }

  void _restartLevel() {
    setState(() {
      _hasShownCompletion = false;
    });
    ref.read(gameControllerProvider(widget.levelId).notifier).reset();
  }

  void _showHints() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => HintSheet(
        levelId: widget.levelId,
        onHintUsed: (hintType) {
          ref
              .read(gameControllerProvider(widget.levelId).notifier)
              .useHint(hintType);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controllerAsync = ref.watch(gameControllerProvider(widget.levelId));
    final notifier = ref.read(gameControllerProvider(widget.levelId).notifier);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final userCoins = currentUser?.coins ?? 0;

    // Watch for completion via controller state changes
    ref.listen<GameController>(gameControllerProvider(widget.levelId),
        (previous, next) {
      if (next.isCompleted && !_hasShownCompletion) {
        _hasShownCompletion = true;
        _onLevelCompleted(notifier.coinsEarned);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradientLight,
              ),
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 30,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.2,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.secondary,
                AppColors.tertiary,
                AppColors.gold,
              ],
            ),
          ),
          SafeArea(
            child: controllerAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => ErrorDisplay(
                message: 'فشل تحميل المستوى',
                onRetry: () => ref.invalidate(
                    gameControllerProvider(widget.levelId)),
              ),
              data: (controller) => Column(
                children: [
                  _buildTopBar(context, controller, notifier, userCoins),
                  Expanded(
                    flex: 5,
                    child: Container(
                      key: _circleKey,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: LetterCircle(
                        letters: controller.displayedLetters,
                        selectedIndices: controller.selectedIndices,
                        hintedIndices: controller.hintedIndices,
                        connectionPoints: controller.connectionPoints,
                        currentPointerPosition:
                            controller.currentPointerPosition,
                        isDragging: controller.isDragging,
                        onLetterTouched: (index, point) {
                          final box = _circleKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box != null) {
                            final local = box.globalToLocal(point);
                            controller.startSelection(index, local);
                          }
                        },
                        onLetterHovered: (index, point) {
                          final box = _circleKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box != null) {
                            final local = box.globalToLocal(point);
                            controller.continueSelection(index, local);
                          }
                        },
                        onPointerMoved: (position) {
                          controller.updatePointer(position);
                        },
                        onSelectionEnded: () {
                          notifier.endSelection();
                        },
                      ),
                    ),
                  ),
                  _buildWordSection(context, controller, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    GameController controller,
    GameControllerNotifier notifier,
    int userCoins,
  ) {
    final level = notifier.level;
    final totalWords = level?.totalWords ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
            color: AppColors.textPrimaryLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'مستوى ${widget.levelId}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      totalWords > 0
                          ? '${notifier.wordsFound + notifier.bonusWordsFound}/$totalWords'
                          : '',
                      style: AppTextStyles.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(level?.rewardCoins ?? 0) + (notifier.wordsFound * 5) + (notifier.bonusWordsFound * 10)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.goldDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CoinDisplay(amount: userCoins, size: CoinDisplaySize.small),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _showHints,
            icon: const Icon(Icons.lightbulb_rounded),
            color: AppColors.gold,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.gold.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordSection(
    BuildContext context,
    GameController controller,
    GameControllerNotifier notifier,
  ) {
    final level = notifier.level;
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current word being formed
          if (controller.currentWord.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Text(
                controller.currentWord,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ).animate(key: ValueKey(controller.currentWord))
                .fadeIn(duration: 200.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            ),
          if (controller.successMessage != null)
            Text(
              controller.successMessage!,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ).animate()
              .fadeIn()
              .then(delay: 800.ms)
              .fadeOut(duration: 400.ms)
          else if (controller.errorMessage != null)
            Text(
              controller.errorMessage!,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ).animate()
              .fadeIn()
              .then(delay: 800.ms)
              .fadeOut(duration: 400.ms),
          const SizedBox(height: 8),
          // Words list
          if (level != null)
            WordListPanel(
              answers: level.answers,
              bonusWords: level.bonusWords,
              foundAnswersCount: controller.foundAnswersCount,
              foundBonusCount: controller.foundBonusWordsCount,
            ),
        ],
      ),
    );
  }
}
