import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaterIntakeWidget extends StatelessWidget {
  final int intake;
  final VoidCallback onIncrement;

  const WaterIntakeWidget({
    Key? key,
    required this.intake,
    required this.onIncrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const dailyTarget = 2500; // 2.5L daily target
    final progress = (intake / dailyTarget).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_drink',
                color: Colors.blue,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Hidratação',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '${(intake / 1000).toStringAsFixed(1)}L',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            height: 1.5.h,
            decoration: BoxDecoration(
              color: AppTheme.dividerGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue,
                      Colors.blue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                'Meta: ${(dailyTarget / 1000).toStringAsFixed(1)}L',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Spacer(),
              Text(
                '${((dailyTarget - intake) / 1000).toStringAsFixed(1)}L restantes',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildWaterButton('250ml', 250),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildWaterButton('500ml', 500),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildWaterButton('750ml', 750),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterButton(String label, int amount) {
    return GestureDetector(
      onTap: onIncrement,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add',
              color: Colors.blue,
              size: 4.w,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
