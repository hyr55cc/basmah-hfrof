import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Panel showing found / remaining words
class WordListPanel extends StatelessWidget {
  const WordListPanel({
    required this.answers,
    required this.bonusWords,
    required this.foundAnswersCount,
    required this.foundBonusCount,
    super.key,
  });

  final List<String> answers;
  final List<String> bonusWords;
  final int foundAnswersCount;
  final int foundBonusCount;

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty && bonusWords.isEmpty) {
      return Text('جاري تحميل الكلمات...', style: AppTextStyles.bodyMedium);
    }
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          ...answers.map((word) => _WordChip(
                word: word,
                isFound:
                    foundAnswersCount >= answers.indexOf(word) + 1,
                isAnswer: true,
              )),
          ...bonusWords.map((word) => _WordChip(
                word: word,
                isFound:
                    foundBonusCount >= bonusWords.indexOf(word) + 1,
                isAnswer: false,
              )),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.isFound,
    required this.isAnswer,
  });

  final String word;
  final bool isFound;
  final bool isAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isFound
            ? (isAnswer
                ? AppColors.success.withOpacity(0.15)
                : AppColors.secondary.withOpacity(0.15))
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFound
              ? (isAnswer ? AppColors.success : AppColors.secondary)
              : AppColors.borderLight,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFound) ...[
            Icon(
              Icons.check_circle_rounded,
              color:
                  isAnswer ? AppColors.success : AppColors.secondary,
              size: 16,
            ),
            const SizedBox(width: 6),
          ] else if (!isAnswer) ...[
            Icon(
              Icons.star_rounded,
              color: AppColors.secondary,
              size: 16,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            isFound || !isAnswer ? word : '·' * word.length,
            style: AppTextStyles.titleSmall.copyWith(
              color: isFound
                  ? (isAnswer ? AppColors.success : AppColors.secondary)
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
