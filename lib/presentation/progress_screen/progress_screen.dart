import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievements_gallery_widget.dart';
import './widgets/export_progress_widget.dart';
import './widgets/goal_tracking_widget.dart';
import './widgets/measurements_chart_widget.dart';
import './widgets/nutrition_analytics_widget.dart';
import './widgets/photo_progress_widget.dart';
import './widgets/progress_overview_widget.dart';
import './widgets/workout_progress_widget.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String _selectedPeriod = '30';
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);

    try {
      // Simulate loading time for better UX
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load progress data'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onPeriodChanged(String period) {
    setState(() => _selectedPeriod = period);
  }

  Future<void> _onRefresh() async {
    await _loadProgressData();
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExportProgressWidget(
        onExport: (format) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exporting progress report as $format...'),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        title: Text('Progress'),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showExportOptions,
            icon: Icon(
              Icons.file_download_outlined,
              color: AppTheme.textPrimary,
            ),
          ),
          PopupMenuButton<String>(
            onSelected: _onPeriodChanged,
            itemBuilder: (context) => [
              PopupMenuItem(value: '7', child: Text('Last 7 days')),
              PopupMenuItem(value: '30', child: Text('Last 30 days')),
              PopupMenuItem(value: '90', child: Text('Last 3 months')),
              PopupMenuItem(value: '365', child: Text('Last year')),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              margin: EdgeInsets.only(right: 2.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.dividerGray),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_selectedPeriod}D',
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.textSecondary,
                    size: 4.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppTheme.accentGold,
              backgroundColor: AppTheme.cardDark,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    ProgressOverviewWidget(
                      selectedPeriod: int.parse(_selectedPeriod),
                    ),
                    SizedBox(height: 3.h),
                    _buildTabSection(),
                    SizedBox(height: 2.h),
                    SizedBox(
                      height: 60.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWorkoutTab(),
                          _buildMeasurementsTab(),
                          _buildNutritionTab(),
                          _buildAchievementsTab(),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    GoalTrackingWidget(
                      selectedPeriod: int.parse(_selectedPeriod),
                    ),
                    SizedBox(height: 3.h),
                    PhotoProgressWidget(),
                    SizedBox(height: 15.h), // Extra space for navigation
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.accentGold,
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Loading progress data...',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.accentGold.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: AppTheme.accentGold,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'Workouts'),
          Tab(text: 'Body'),
          Tab(text: 'Nutrition'),
          Tab(text: 'Badges'),
        ],
      ),
    );
  }

  Widget _buildWorkoutTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: WorkoutProgressWidget(
        selectedPeriod: int.parse(_selectedPeriod),
      ),
    );
  }

  Widget _buildMeasurementsTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: MeasurementsChartWidget(
        selectedPeriod: int.parse(_selectedPeriod),
      ),
    );
  }

  Widget _buildNutritionTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: NutritionAnalyticsWidget(
        selectedPeriod: int.parse(_selectedPeriod),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: AchievementsGalleryWidget(),
    );
  }
}
