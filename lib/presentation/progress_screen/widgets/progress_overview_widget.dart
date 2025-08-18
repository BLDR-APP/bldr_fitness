import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/progress_service.dart';
import '../../../services/user_service.dart';

class ProgressOverviewWidget extends StatefulWidget {
  final int selectedPeriod;

  const ProgressOverviewWidget({
    Key? key,
    required this.selectedPeriod,
  }) : super(key: key);

  @override
  State<ProgressOverviewWidget> createState() => _ProgressOverviewWidgetState();
}

class _ProgressOverviewWidgetState extends State<ProgressOverviewWidget> {
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _workoutProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOverviewData();
  }

  @override
  void didUpdateWidget(ProgressOverviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _loadOverviewData();
    }
  }

  Future<void> _loadOverviewData() async {
    setState(() => _isLoading = true);

    try {
      final userProfile = await UserService.instance.getCurrentUserProfile();
      if (userProfile != null) {
        final userStatsData =
            await UserService.instance.getUserStatistics(userProfile.id);
        final workoutProgressData =
            await ProgressService.instance.getWorkoutProgress(
          daysPeriod: widget.selectedPeriod,
        );

        if (mounted) {
          setState(() {
            _userStats = userStatsData;
            _workoutProgress = workoutProgressData;
            _isLoading = false;
          });
        }
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
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerGray),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentGold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final completionRate = _workoutProgress?['completion_rate'] ?? 0;
    final totalWorkouts = _userStats?['total_workouts'] ?? 0;
    final achievements = _userStats?['achievements'] ?? 0;
    final workoutTime = _workoutProgress?['total_workout_time_hours'] ?? '0.0';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardDark,
            AppTheme.cardDark.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'trending_up',
                  color: AppTheme.accentGold,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Overview',
                      style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Last ${widget.selectedPeriod} days',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCompletionRate(completionRate),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Workouts',
                  totalWorkouts.toString(),
                  'sessions',
                  AppTheme.accentGold,
                  'fitness_center',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Time',
                  workoutTime,
                  'hours',
                  AppTheme.warningAmber,
                  'schedule',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Badges',
                  achievements.toString(),
                  'earned',
                  AppTheme.successGreen,
                  'emoji_events',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '7', // Mock data - could be calculated from consistency
                  'days',
                  Colors.purple,
                  'local_fire_department',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRate(int rate) {
    Color rateColor = AppTheme.errorRed;
    if (rate >= 80)
      rateColor = AppTheme.successGreen;
    else if (rate >= 60) rateColor = AppTheme.warningAmber;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: rateColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${rate}%',
        style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
          color: rateColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    Color color,
    String iconName,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                color: color,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                unit,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
