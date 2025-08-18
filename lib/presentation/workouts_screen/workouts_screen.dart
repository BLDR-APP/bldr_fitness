import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/exercise_service.dart';
import '../../services/workout_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_error_widget.dart';
import './widgets/active_workout_banner_widget.dart';
import './widgets/exercise_categories_widget.dart';
import './widgets/featured_workouts_widget.dart';
import './widgets/workout_card_widget.dart';
import './widgets/workout_search_bar_widget.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  List<Map<String, dynamic>> _workoutTemplates = [];
  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _filteredWorkouts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  String? _selectedType;
  int? _selectedDifficulty;
  bool _hasActiveWorkout = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final workouts =
          await WorkoutService.instance.getWorkoutTemplates(publicOnly: true);
      final exercises = await ExerciseService.instance.getExercises();

      setState(() {
        _workoutTemplates = workouts;
        _exercises = exercises;
        _filteredWorkouts = workouts;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _filterWorkouts() {
    setState(() {
      _filteredWorkouts = _workoutTemplates.where((workout) {
        bool matchesSearch = true;
        bool matchesType = true;
        bool matchesDifficulty = true;

        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          matchesSearch =
              workout['name'].toString().toLowerCase().contains(query) ||
                  (workout['description'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(query);
        }

        if (_selectedType != null) {
          matchesType = workout['workout_type'] == _selectedType;
        }

        if (_selectedDifficulty != null) {
          matchesDifficulty =
              workout['difficulty_level'] == _selectedDifficulty;
        }

        return matchesSearch && matchesType && matchesDifficulty;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterWorkouts();
  }

  void _onTypeFilter(String? type) {
    setState(() {
      _selectedType = type;
    });
    _filterWorkouts();
  }

  void _onDifficultyFilter(int? difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _filterWorkouts();
  }

  void _startWorkout(Map<String, dynamic> workoutTemplate) async {
    try {
      final workout = await WorkoutService.instance.startWorkout(
          name: workoutTemplate['name'],
          workoutTemplateId: workoutTemplate['id']);

      setState(() {
        _hasActiveWorkout = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Workout started: ${workoutTemplate['name']}'),
          backgroundColor: AppTheme.accentGold,
          behavior: SnackBarBehavior.floating));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to start workout'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating));
    }
  }

  void _viewWorkoutDetails(Map<String, dynamic> workoutTemplate) {
    showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.cardDark,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) => Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 12.w,
                          height: 0.5.h,
                          margin: EdgeInsets.only(left: 38.w, bottom: 3.h),
                          decoration: BoxDecoration(
                              color: AppTheme.dividerGray,
                              borderRadius: BorderRadius.circular(2))),
                      Text(workoutTemplate['name'],
                          style: AppTheme.darkTheme.textTheme.titleLarge
                              ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600)),
                      SizedBox(height: 2.h),
                      if (workoutTemplate['description'] != null)
                        Text(workoutTemplate['description'],
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.textSecondary)),
                      SizedBox(height: 3.h),
                      Row(children: [
                        _buildInfoChip(
                            '${workoutTemplate['estimated_duration_minutes']} min',
                            Icons.schedule),
                        SizedBox(width: 2.w),
                        _buildInfoChip(
                            'Level ${workoutTemplate['difficulty_level']}',
                            Icons.trending_up),
                        SizedBox(width: 2.w),
                        _buildInfoChip(
                            workoutTemplate['workout_type']
                                .toString()
                                .replaceAll('_', ' '),
                            Icons.category),
                      ]),
                      SizedBox(height: 3.h),
                      Row(children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _startWorkout(workoutTemplate);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentGold,
                                    foregroundColor: AppTheme.primaryBlack,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 2.h),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: Text('Start Workout',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp)))),
                      ]),
                    ]))));
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.dividerGray)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 4.w, color: AppTheme.accentGold),
          SizedBox(width: 1.w),
          Text(label,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          backgroundColor: AppTheme.primaryBlack,
          body: Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold)));
    }

    if (_hasError) {
      return Scaffold(
          backgroundColor: AppTheme.primaryBlack,
          body: Center(child: CustomErrorWidget()));
    }

    return Scaffold(
        backgroundColor: AppTheme.primaryBlack,
        body: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.accentGold,
            backgroundColor: AppTheme.cardDark,
            child: CustomScrollView(slivers: [
              SliverAppBar(
                  backgroundColor: AppTheme.primaryBlack,
                  floating: true,
                  snap: true,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Column(children: [
                        WorkoutSearchBarWidget(
                            onSearchChanged: _onSearchChanged,
                            onTypeFilter: _onTypeFilter,
                            onDifficultyFilter: _onDifficultyFilter,
                            selectedType: _selectedType,
                            selectedDifficulty: _selectedDifficulty),
                      ])),
                  expandedHeight: _hasActiveWorkout ? 20.h : 15.h),
              if (_hasActiveWorkout)
                SliverToBoxAdapter(
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                        child: ActiveWorkoutBannerWidget())),
              SliverToBoxAdapter(
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      child: FeaturedWorkoutsWidget(
                          workouts: _filteredWorkouts.take(3).toList(),
                          onWorkoutTap: _viewWorkoutDetails,
                          onStartWorkout: _startWorkout))),
              SliverToBoxAdapter(
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                      child: ExerciseCategoriesWidget(
                          exercises: _exercises,
                          onCategoryTap: (category) {
                            _onTypeFilter(category);
                          }))),
              SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    final workout = _filteredWorkouts[index];
                    return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        child: WorkoutCardWidget(
                            workout: workout,
                            onTap: () => _viewWorkoutDetails(workout),
                            onStart: () => _startWorkout(workout)));
                  }, childCount: _filteredWorkouts.length))),
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),
            ])));
  }
}
