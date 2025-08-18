import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../nutrition_screen/nutrition_screen.dart';
import '../progress_screen/progress_screen.dart';
import '../workouts_screen/workouts_screen.dart';
import '../profile_drawer/profile_drawer.dart'; // <- IMPORTANTE

import './widgets/achievements_widget.dart';
import './widgets/active_workout_card_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/nutrition_progress_widget.dart';
import './widgets/partnership_widget.dart';
import './widgets/quick_actions_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // <- adicionada
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _tabController.animateTo(index);
  }

  // Agora abre o END DRAWER
  void _openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _startWorkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting workout...'),
        backgroundColor: AppTheme.accentGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logMeal() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening meal logger...'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewProgress() {
    Navigator.pushNamed(context, '/progress-screen');
  }

  void _quickLog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
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
              'Quick Log',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildQuickLogOption(
                    'Log Meal',
                    'restaurant',
                    AppTheme.successGreen,
                    _logMeal,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildQuickLogOption(
                    'Log Exercise',
                    'fitness_center',
                    AppTheme.accentGold,
                    _startWorkout,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildQuickLogOption(
                    'Log Weight',
                    'monitor_weight',
                    AppTheme.warningAmber,
                    () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening weight logger...'),
                          backgroundColor: AppTheme.warningAmber,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildQuickLogOption(
                    'Log Water',
                    'local_drink',
                    Colors.blue,
                    () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening water logger...'),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLogOption(
      String title, String icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerGray),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 6.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // <- chave para abrir o drawer
      backgroundColor: AppTheme.primaryBlack,
      endDrawer: const ProfileDrawer(), // <- seu Drawer aqui
      // opcional: controla abrir via gesto de arrastar
      // endDrawerEnableOpenDragGesture: true,
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildDashboardTab(),
            WorkoutsScreen(),
            NutritionScreen(),
            ProgressScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          border: Border(
            top: BorderSide(
              color: AppTheme.dividerGray,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceDark,
          selectedItemColor: AppTheme.accentGold,
          unselectedItemColor: AppTheme.inactiveGray,
          elevation: 0,
          selectedLabelStyle:
              AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTheme.darkTheme.textTheme.labelMedium,
          items: [
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'dashboard',
                color: _selectedIndex == 0
                    ? AppTheme.accentGold
                    : AppTheme.inactiveGray,
                size: 6.w,
              ),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'fitness_center',
                color: _selectedIndex == 1
                    ? AppTheme.accentGold
                    : AppTheme.inactiveGray,
                size: 6.w,
              ),
              label: 'Treinos',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'restaurant',
                color: _selectedIndex == 2
                    ? AppTheme.accentGold
                    : AppTheme.inactiveGray,
                size: 6.w,
              ),
              label: 'Nutrição',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'trending_up',
                color: _selectedIndex == 3
                    ? AppTheme.accentGold
                    : AppTheme.inactiveGray,
                size: 6.w,
              ),
              label: 'Progresso',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _quickLog,
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.primaryBlack,
              child: CustomIconWidget(
                iconName: 'add',
                color: AppTheme.primaryBlack,
                size: 7.w,
              ),
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dashboard refreshed'),
            backgroundColor: AppTheme.accentGold,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      color: AppTheme.accentGold,
      backgroundColor: AppTheme.cardDark,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingHeaderWidget(
              onSettingsPressed: _openProfileDrawer, // <- abre o drawer
            ),
            SizedBox(height: 2.h),
            ActiveWorkoutCardWidget(
              onStartPressed: _startWorkout,
            ),
            SizedBox(height: 3.h),
            const NutritionProgressWidget(),
            SizedBox(height: 3.h),
            const PartnershipWidget(),
            SizedBox(height: 3.h),
            const AchievementsWidget(),
            SizedBox(height: 3.h),
            QuickActionsWidget(
              onLogMealPressed: _logMeal,
              onStartWorkoutPressed: _startWorkout,
              onViewProgressPressed: _viewProgress,
            ),
            SizedBox(height: 10.h), // espaço pro FAB
          ],
        ),
      ),
    );
  }
}
