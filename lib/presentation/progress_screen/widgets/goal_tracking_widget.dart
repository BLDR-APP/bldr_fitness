import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/user_service.dart';

class GoalTrackingWidget extends StatefulWidget {
  final int selectedPeriod;

  const GoalTrackingWidget({
    Key? key,
    required this.selectedPeriod,
  }) : super(key: key);

  @override
  State<GoalTrackingWidget> createState() => _GoalTrackingWidgetState();
}

class _GoalTrackingWidgetState extends State<GoalTrackingWidget> {
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => _isLoading = true);

    try {
      // Since there's no specific goals table, we'll create mock goals based on user profile
      final userProfile = await UserService.instance.getCurrentUserProfile();
      if (userProfile != null) {
        final mockGoals = _generateMockGoals(userProfile.toJson());

        if (mounted) {
          setState(() {
            _goals = mockGoals;
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

  List<Map<String, dynamic>> _generateMockGoals(
      Map<String, dynamic> userProfile) {
    final goals = <Map<String, dynamic>>[];
    final fitnessGoal = userProfile['fitness_goal'];
    final targetWeight = userProfile['target_weight_kg'];

    // Weight goal
    if (targetWeight != null) {
      goals.add({
        'id': '1',
        'title': 'Reach Target Weight',
        'description': 'Achieve ${targetWeight}kg body weight',
        'target_value': targetWeight,
        'current_value': 75.0, // Mock current weight
        'unit': 'kg',
        'category': 'weight',
        'color': AppTheme.warningAmber,
        'icon': 'monitor_weight',
        'deadline': DateTime.now().add(Duration(days: 90)).toIso8601String(),
        'is_active': true,
      });
    }

    // Workout frequency goal
    goals.add({
      'id': '2',
      'title': 'Workout Consistency',
      'description': 'Complete 4 workouts per week',
      'target_value': 4,
      'current_value': 2, // Mock current frequency
      'unit': 'workouts/week',
      'category': 'workout',
      'color': AppTheme.successGreen,
      'icon': 'fitness_center',
      'deadline': DateTime.now().add(Duration(days: 7)).toIso8601String(),
      'is_active': true,
    });

    // Strength goal based on fitness goal
    if (fitnessGoal == 'strength' || fitnessGoal == 'muscle_gain') {
      goals.add({
        'id': '3',
        'title': 'Bench Press Goal',
        'description': 'Bench press 1.5x body weight',
        'target_value': 112.5, // 75kg * 1.5
        'current_value': 85.0, // Mock current PR
        'unit': 'kg',
        'category': 'strength',
        'color': AppTheme.accentGold,
        'icon': 'trending_up',
        'deadline': DateTime.now().add(Duration(days: 180)).toIso8601String(),
        'is_active': true,
      });
    }

    // Endurance goal
    if (fitnessGoal == 'endurance' || fitnessGoal == 'general_fitness') {
      goals.add({
        'id': '4',
        'title': '5K Running Time',
        'description': 'Run 5K in under 25 minutes',
        'target_value': 25,
        'current_value': 28, // Mock current time
        'unit': 'minutes',
        'category': 'endurance',
        'color': Colors.blue,
        'icon': 'directions_run',
        'deadline': DateTime.now().add(Duration(days: 60)).toIso8601String(),
        'is_active': true,
      });
    }

    return goals;
  }

  void _showCreateGoalDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController targetController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    String selectedCategory = 'weight';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.dialogDark,
          title: Text(
            'Create New Goal',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Goal Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: targetController,
                        style: TextStyle(color: AppTheme.textPrimary),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Target Value',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setDialogState(() => selectedCategory = value!);
                  },
                  dropdownColor: AppTheme.surfaceDark,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'weight', child: Text('Weight')),
                    DropdownMenuItem(value: 'workout', child: Text('Workout')),
                    DropdownMenuItem(
                        value: 'strength', child: Text('Strength')),
                    DropdownMenuItem(
                        value: 'endurance', child: Text('Endurance')),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real implementation, this would save to database
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal created successfully!'),
                    backgroundColor: AppTheme.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'track_changes',
                  color: AppTheme.accentGold,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Goal Tracking',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showCreateGoalDialog,
                icon: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.accentGold,
                    size: 4.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold),
            )
          else if (_goals.isEmpty)
            _buildEmptyState()
          else
            ..._goals
                .where((goal) => goal['is_active'] == true)
                .map((goal) => _buildGoalCard(goal)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          CustomIconWidget(
            iconName: 'track_changes',
            color: AppTheme.inactiveGray,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No active goals',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Create SMART goals to track your fitness journey',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _showCreateGoalDialog,
            icon: Icon(Icons.add, size: 5.w),
            label: Text('Create First Goal'),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final title = goal['title'] ?? 'Untitled Goal';
    final description = goal['description'] ?? '';
    final targetValue = goal['target_value'] ?? 0.0;
    final currentValue = goal['current_value'] ?? 0.0;
    final unit = goal['unit'] ?? '';
    final category = goal['category'] ?? 'general';
    final color = goal['color'] ?? AppTheme.accentGold;
    final iconName = goal['icon'] ?? 'track_changes';
    final deadline = goal['deadline'];

    final progress =
        targetValue != 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    final progressPercentage = (progress * 100).round();

    String deadlineText = '';
    if (deadline != null) {
      final deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      final daysLeft = deadlineDate.difference(now).inDays;

      if (daysLeft < 0) {
        deadlineText = 'Overdue';
      } else if (daysLeft == 0) {
        deadlineText = 'Due today';
      } else {
        deadlineText = '${daysLeft}d left';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
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
                  color: (color as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: color,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        description,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$progressPercentage%',
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: _getProgressColor(progress),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (deadlineText.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Text(
                      deadlineText,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentValue.toStringAsFixed(1)} $unit',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${targetValue.toStringAsFixed(1)} $unit',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.dividerGray,
              valueColor:
                  AlwaysStoppedAnimation<Color>(_getProgressColor(progress)),
              minHeight: 1.h,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showUpdateProgressDialog(goal),
                  icon: Icon(Icons.edit, size: 4.w),
                  label: Text('Update Progress'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color),
                    foregroundColor: color,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () => _showGoalOptions(goal),
                icon: CustomIconWidget(
                  iconName: 'more_vert',
                  color: AppTheme.textSecondary,
                  size: 5.w,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppTheme.successGreen;
    if (progress >= 0.5) return AppTheme.warningAmber;
    return AppTheme.errorRed;
  }

  void _showUpdateProgressDialog(Map<String, dynamic> goal) {
    final TextEditingController progressController = TextEditingController();
    progressController.text = goal['current_value'].toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dialogDark,
        title: Text(
          'Update Progress',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              goal['title'],
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: progressController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Current Value (${goal['unit']})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.accentGold, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = double.tryParse(progressController.text);
              if (newValue != null) {
                // In a real implementation, this would update the database
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Progress updated successfully!'),
                    backgroundColor: AppTheme.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showGoalOptions(Map<String, dynamic> goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.dividerGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              goal['title'],
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.accentGold,
                size: 6.w,
              ),
              title: Text(
                'Edit Goal',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Show edit goal dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Edit goal feature coming soon'),
                    backgroundColor: AppTheme.warningAmber,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'pause',
                color: AppTheme.warningAmber,
                size: 6.w,
              ),
              title: Text(
                'Pause Goal',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal paused'),
                    backgroundColor: AppTheme.warningAmber,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorRed,
                size: 6.w,
              ),
              title: Text(
                'Delete Goal',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal deleted'),
                    backgroundColor: AppTheme.errorRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
