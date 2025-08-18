import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/progress_service.dart';
import '../../../services/workout_service.dart';

class WorkoutProgressWidget extends StatefulWidget {
  final int selectedPeriod;

  const WorkoutProgressWidget({
    Key? key,
    required this.selectedPeriod,
  }) : super(key: key);

  @override
  State<WorkoutProgressWidget> createState() => _WorkoutProgressWidgetState();
}

class _WorkoutProgressWidgetState extends State<WorkoutProgressWidget> {
  Map<String, dynamic>? _workoutProgress;
  List<Map<String, dynamic>> _recentWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  @override
  void didUpdateWidget(WorkoutProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _loadWorkoutData();
    }
  }

  Future<void> _loadWorkoutData() async {
    setState(() => _isLoading = true);

    try {
      final workoutProgressData = await ProgressService.instance
          .getWorkoutProgress(daysPeriod: widget.selectedPeriod);

      final recentWorkoutsData =
          await WorkoutService.instance.getUserWorkouts(limit: 5);

      if (mounted) {
        setState(() {
          _workoutProgress = workoutProgressData;
          _recentWorkouts = recentWorkoutsData;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGold));
    }

    final completedWorkouts = _workoutProgress?['completed_workouts'] ?? 0;
    final totalWorkouts = _workoutProgress?['total_workouts'] ?? 0;
    final avgDuration =
        _workoutProgress?['average_workout_duration_minutes'] ?? 0;
    final totalTime = _workoutProgress?['total_workout_time_hours'] ?? '0.0';

    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 2.h),
      _buildWorkoutChart(),
      SizedBox(height: 3.h),
      _buildStatsGrid(completedWorkouts, totalWorkouts, avgDuration, totalTime),
      SizedBox(height: 3.h),
      _buildRecentWorkouts(),
    ]));
  }

  Widget _buildWorkoutChart() {
    // Generate mock chart data based on period
    final spots = _generateWorkoutSpots();

    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerGray)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CustomIconWidget(
                iconName: 'show_chart', color: AppTheme.accentGold, size: 5.w),
            SizedBox(width: 3.w),
            Expanded(
                child: Text('Workout Frequency',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600))),
          ]),
          SizedBox(height: 3.h),
          SizedBox(
              height: 25.h,
              child: LineChart(LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                            color: AppTheme.dividerGray, strokeWidth: 1);
                      }),
                  titlesData: FlTitlesData(
                      show: true,
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final days = [
                                  'S',
                                  'M',
                                  'T',
                                  'W',
                                  'T',
                                  'F',
                                  'S'
                                ];
                                if (value.toInt() < days.length) {
                                  return Text(days[value.toInt()],
                                      style: AppTheme
                                          .darkTheme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: AppTheme.textSecondary));
                                }
                                return const Text('');
                              })),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(),
                                    style: AppTheme
                                        .darkTheme.textTheme.bodySmall
                                        ?.copyWith(
                                            color: AppTheme.textSecondary));
                              }))),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 4,
                  lineBarsData: [
                    LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppTheme.accentGold,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.accentGold.withValues(alpha: 0.1)),
                        dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                  radius: 4,
                                  color: AppTheme.accentGold,
                                  strokeWidth: 2,
                                  strokeColor: AppTheme.cardDark);
                            })),
                  ]))),
        ]));
  }

  List<FlSpot> _generateWorkoutSpots() {
    // Generate mock data based on selected period
    return [
      const FlSpot(0, 1),
      const FlSpot(1, 3),
      const FlSpot(2, 2),
      const FlSpot(3, 2),
      const FlSpot(4, 3),
      const FlSpot(5, 1),
      const FlSpot(6, 2),
    ];
  }

  Widget _buildStatsGrid(
      int completed, int total, int avgDuration, String totalTime) {
    return Row(children: [
      Expanded(
          child: _buildStatCard('Completed', completed.toString(),
              AppTheme.successGreen, 'check_circle')),
      SizedBox(width: 3.w),
      Expanded(
          child: _buildStatCard('Avg Duration', '${avgDuration}m',
              AppTheme.warningAmber, 'schedule')),
    ]);
  }

  Widget _buildStatCard(
      String title, String value, Color color, String iconName) {
    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerGray)),
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: CustomIconWidget(
                  iconName: iconName, color: color, size: 5.w)),
          SizedBox(height: 2.h),
          Text(value,
              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          SizedBox(height: 0.5.h),
          Text(title,
              style: AppTheme.darkTheme.textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ]));
  }

  Widget _buildRecentWorkouts() {
    return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dividerGray)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CustomIconWidget(
                iconName: 'history', color: AppTheme.accentGold, size: 5.w),
            SizedBox(width: 3.w),
            Text('Recent Workouts',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: 3.h),
          if (_recentWorkouts.isEmpty)
            Center(
                child: Column(children: [
              SizedBox(height: 2.h),
              CustomIconWidget(
                  iconName: 'fitness_center',
                  color: AppTheme.inactiveGray,
                  size: 10.w),
              SizedBox(height: 2.h),
              Text('No workouts yet',
                  style: AppTheme.darkTheme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary)),
              SizedBox(height: 2.h),
            ]))
          else
            ..._recentWorkouts
                .take(3)
                .map((workout) => _buildWorkoutItem(workout)),
        ]));
  }

  Widget _buildWorkoutItem(Map<String, dynamic> workout) {
    final name = workout['name'] ?? 'Unknown Workout';
    final completedAt = workout['completed_at'];
    final duration = workout['total_duration_seconds'];

    String timeAgo = 'Recently';
    if (completedAt != null) {
      final date = DateTime.parse(completedAt);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      timeAgo = difference == 0 ? 'Today' : '${difference}d ago';
    }

    String durationText = '';
    if (duration != null) {
      final minutes = (duration / 60).round();
      durationText = '${minutes}min';
    }

    return Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerGray)),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successGreen,
                  size: 4.w)),
          SizedBox(width: 3.w),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500)),
                if (durationText.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(durationText,
                      style: AppTheme.darkTheme.textTheme.bodySmall
                          ?.copyWith(color: AppTheme.textSecondary)),
                ],
              ])),
          Text(timeAgo,
              style: AppTheme.darkTheme.textTheme.bodySmall
                  ?.copyWith(color: AppTheme.textSecondary)),
        ]));
  }
}
