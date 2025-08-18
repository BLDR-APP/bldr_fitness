import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/progress_service.dart';

class NutritionAnalyticsWidget extends StatefulWidget {
  final int selectedPeriod;

  const NutritionAnalyticsWidget({
    Key? key,
    required this.selectedPeriod,
  }) : super(key: key);

  @override
  State<NutritionAnalyticsWidget> createState() =>
      _NutritionAnalyticsWidgetState();
}

class _NutritionAnalyticsWidgetState extends State<NutritionAnalyticsWidget> {
  Map<String, dynamic>? _waterIntakeData;
  List<Map<String, dynamic>> _recentMeals = [];
  bool _isLoading = true;
  String _selectedMetric = 'water';

  @override
  void initState() {
    super.initState();
    _loadNutritionData();
  }

  @override
  void didUpdateWidget(NutritionAnalyticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPeriod != widget.selectedPeriod) {
      _loadNutritionData();
    }
  }

  Future<void> _loadNutritionData() async {
    setState(() => _isLoading = true);

    try {
      // Load water intake for today
      final waterData = await ProgressService.instance.getDailyWaterIntake(
        date: DateTime.now(),
      );

      // Load recent meals (mock data since getUserMeals not defined)
      final mealsData = <Map<String, dynamic>>[];

      if (mounted) {
        setState(() {
          _waterIntakeData = waterData;
          _recentMeals = mealsData;
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
        child: CircularProgressIndicator(color: AppTheme.accentGold),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          _buildMetricSelector(),
          SizedBox(height: 3.h),
          if (_selectedMetric == 'water')
            _buildWaterIntakeCard()
          else if (_selectedMetric == 'meals')
            _buildMacroChart()
          else
            _buildCalorieChart(),
          SizedBox(height: 3.h),
          _buildRecentMeals(),
          SizedBox(height: 3.h),
          _buildNutritionTips(),
        ],
      ),
    );
  }

  Widget _buildMetricSelector() {
    final metrics = {
      'water': {'label': 'Water', 'icon': 'local_drink', 'color': Colors.blue},
      'meals': {
        'label': 'Macros',
        'icon': 'pie_chart',
        'color': AppTheme.successGreen
      },
      'calories': {
        'label': 'Calories',
        'icon': 'local_fire_department',
        'color': AppTheme.warningAmber
      },
    };

    return SizedBox(
      height: 10.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        itemBuilder: (context, index) {
          final key = metrics.keys.elementAt(index);
          final metric = metrics[key]!;
          final isSelected = key == _selectedMetric;

          return GestureDetector(
            onTap: () => setState(() => _selectedMetric = key),
            child: Container(
              width: 25.w,
              margin: EdgeInsets.only(right: 3.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentGold.withValues(alpha: 0.2)
                    : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? AppTheme.accentGold : AppTheme.dividerGray,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: metric['icon'] as String,
                    color: isSelected ? AppTheme.accentGold : (metric['color'] as Color),
                    size: 6.w,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    metric['label'] as String,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.accentGold
                          : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    final totalAmountMl = _waterIntakeData?['total_amount_ml'] ?? 0;
    final totalAmountLiters = _waterIntakeData?['total_amount_liters'] ?? '0.0';
    final logCount = _waterIntakeData?['log_count'] ?? 0;
    final targetMl = 2500; // 2.5L daily target
    final progress = (totalAmountMl / targetMl).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerGray),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'local_drink',
                  color: Colors.blue,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Water Intake',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${totalAmountLiters}L / 2.5L target',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.dividerGray,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 1.5.h,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildWaterStat('${totalAmountMl}ml', 'Total Today'),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildWaterStat('$logCount', 'Log Entries'),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _showAddWaterDialog,
            icon: Icon(Icons.add, size: 5.w),
            label: Text('Log Water'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 6.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterStat(String value, String label) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.dividerGray),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddWaterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final amounts = [250, 500, 750, 1000];
        return AlertDialog(
          backgroundColor: AppTheme.dialogDark,
          title: Text(
            'Log Water Intake',
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: amounts.map((amount) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 2.h),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ProgressService.instance.logWaterIntake(
                        amountMl: amount,
                      );
                      Navigator.pop(context);
                      _loadNutritionData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Water intake logged: ${amount}ml'),
                          backgroundColor: AppTheme.successGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to log water intake'),
                          backgroundColor: AppTheme.errorRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('${amount}ml'),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMacroChart() {
    // Mock macro data
    final macros = {
      'Protein': {
        'value': 45.0,
        'color': AppTheme.successGreen,
        'target': 50.0
      },
      'Carbs': {'value': 35.0, 'color': AppTheme.warningAmber, 'target': 40.0},
      'Fat': {'value': 20.0, 'color': AppTheme.errorRed, 'target': 25.0},
    };

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
          Text(
            'Macro Distribution',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 25.h,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: macros.entries.map((entry) {
                        final macro = entry.key;
                        final data = entry.value;
                        return PieChartSectionData(
                          color: data['color'] as Color,
                          value: data['value'] as double,
                          title: '${(data['value'] as double).round()}%',
                          radius: 50,
                          titleStyle: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: macros.entries.map((entry) {
                      final macro = entry.key;
                      final data = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        child: Row(
                          children: [
                            Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                color: data['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                macro,
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieChart() {
    // Mock calorie data for the week
    final calorieData = [
      FlSpot(0, 1800),
      FlSpot(1, 2200),
      FlSpot(2, 1950),
      FlSpot(3, 2100),
      FlSpot(4, 1750),
      FlSpot(5, 2300),
      FlSpot(6, 2000),
    ];

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
          Text(
            'Daily Calories',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 25.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.dividerGray,
                      strokeWidth: 1,
                    );
                  },
                ),
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
                        final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                        if (value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 400,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 1500,
                maxY: 2500,
                lineBarsData: [
                  LineChartBarData(
                    spots: calorieData,
                    isCurved: true,
                    color: AppTheme.warningAmber,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.warningAmber.withValues(alpha: 0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.warningAmber,
                          strokeWidth: 2,
                          strokeColor: AppTheme.cardDark,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMeals() {
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
                iconName: 'restaurant',
                color: AppTheme.accentGold,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Recent Meals',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (_recentMeals.isEmpty)
            Center(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  CustomIconWidget(
                    iconName: 'restaurant',
                    color: AppTheme.inactiveGray,
                    size: 10.w,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No meals logged yet',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            )
          else
            ..._recentMeals.take(3).map((meal) => _buildMealItem(meal)),
        ],
      ),
    );
  }

  Widget _buildMealItem(Map<String, dynamic> meal) {
    final name = meal['name'] ?? 'Unknown Meal';
    final mealType = meal['meal_type'] ?? 'snack';
    final mealDate = meal['meal_date'];

    String timeAgo = 'Recently';
    if (mealDate != null) {
      final date = DateTime.parse(mealDate);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      timeAgo = difference == 0 ? 'Today' : '${difference}d ago';
    }

    Color mealTypeColor = AppTheme.accentGold;
    String mealTypeIcon = 'restaurant';

    switch (mealType) {
      case 'breakfast':
        mealTypeColor = AppTheme.warningAmber;
        mealTypeIcon = 'free_breakfast';
        break;
      case 'lunch':
        mealTypeColor = AppTheme.successGreen;
        mealTypeIcon = 'lunch_dining';
        break;
      case 'dinner':
        mealTypeColor = AppTheme.errorRed;
        mealTypeIcon = 'dinner_dining';
        break;
      case 'snack':
        mealTypeColor = Colors.purple;
        mealTypeIcon = 'cookie';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGray),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: mealTypeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: mealTypeIcon,
              color: mealTypeColor,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  mealType.toUpperCase(),
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: mealTypeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTips() {
    final tips = [
      'Drink water 30 minutes before meals for better digestion',
      'Include protein in every meal to maintain muscle mass',
      'Eat colorful vegetables for diverse micronutrients',
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.successGreen.withValues(alpha: 0.1),
            AppTheme.accentGold.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: AppTheme.successGreen,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Nutrition Tips',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...tips.map((tip) => Container(
                margin: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 1.w,
                      height: 1.w,
                      margin: EdgeInsets.only(top: 2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        tip,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}