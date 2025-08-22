import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExerciseCategoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  final Function(String) onCategoryTap;

  const ExerciseCategoriesWidget({
    Key? key,
    required this.exercises,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = _getExerciseCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biblioteca de Exercícios',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 15.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => onCategoryTap(category['type']),
      child: Container(
        width: 30.w,
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerGray),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: (category['color'] as Color).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: category['icon'],
                color: category['color'],
                size: 8.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              category['name'],
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              '${category['count']} exercícios',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getExerciseCategories() {
    // Fazemos as contagens por tipo de exercício vindo do banco
    int strengthCount = 0;
    int hiitCount = 0;
    int flexibilityCount = 0;

    for (final exercise in exercises) {
      final type = (exercise['exercise_type'] ?? '').toString().toLowerCase();
      if (type == 'compound' || type == 'strength') {
        strengthCount++;
      } else if (type == 'cardio' || type == 'plyometric' || type == 'hiit') {
        // nossos exercícios de HIIT estão como 'cardio' nos seeds
        hiitCount++;
      } else if (type == 'stretching' || type == 'flexibility') {
        flexibilityCount++;
      }
    }

    // Renderiza apenas Força, HIIT e Flexibilidade
    return [
      {
        'name': 'Força',
        'type': 'strength', // usado no filtro da tela
        'icon': 'fitness_center',
        'color': AppTheme.accentGold,
        'count': strengthCount,
      },
      {
        'name': 'HIIT',
        'type': 'sports', // seu chip HIIT usa workout_type = 'sports'
        'icon': 'sports_martial_arts',
        'color': AppTheme.warningAmber,
        'count': hiitCount,
      },
      {
        'name': 'Mobilidade',
        'type': 'flexibility',
        'icon': 'accessibility',
        'color': AppTheme.successGreen,
        'count': flexibilityCount,
      },
    ];
  }
}
