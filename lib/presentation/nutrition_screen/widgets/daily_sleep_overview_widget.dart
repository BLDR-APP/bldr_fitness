// lib/presentation/nutrition_screen/widgets/daily_sleep_overview_widget.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DailySleepOverviewWidget extends StatelessWidget {
  final int totalSleepMin;
  final int? score;
  final int? restingHr;
  final int? hrv;
  final DateTime selectedDate;

  const DailySleepOverviewWidget({
    Key? key,
    required this.totalSleepMin,
    required this.selectedDate,
    this.score,
    this.restingHr,
    this.hrv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Text(
                  'Sono',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.dividerGray),
                  ),
                  child: Text(
                    _labelDate(selectedDate),
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),

            // Métricas
            Row(
              children: [
                _metric(context, 'Duração', totalSleepMin > 0 ? '${totalSleepMin} min' : '--'),
                SizedBox(width: 4.w),
                _metric(context, 'Score', score != null ? '$score' : '--'),
                SizedBox(width: 4.w),
                _metric(context, 'RHR', restingHr != null ? '${restingHr!} bpm' : '--'),
                SizedBox(width: 4.w),
                _metric(context, 'HRV', hrv != null ? '${hrv!} ms' : '--'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTheme.darkTheme.textTheme.bodySmall
                  ?.copyWith(color: AppTheme.textSecondary)),
          SizedBox(height: 0.6.h),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.accentGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _labelDate(DateTime d) {
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;
    if (isToday) return 'Hoje';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}
