import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/nutrition_service.dart';

class NutritionSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodSelected;

  const NutritionSearchWidget({
    Key? key,
    required this.onFoodSelected,
  }) : super(key: key);

  @override
  State<NutritionSearchWidget> createState() => _NutritionSearchWidgetState();
}

class _NutritionSearchWidgetState extends State<NutritionSearchWidget> {
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPopularFoods();
  }

  Future<void> _loadPopularFoods() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final foods = await NutritionService.instance.searchFoodItems(
        verifiedOnly: true,
        limit: 20,
      );

      setState(() {
        _searchResults = foods;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) {
      _loadPopularFoods();
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _searchQuery = query;
      });

      final foods = await NutritionService.instance.searchFoodItems(
        search: query,
        limit: 50,
      );

      setState(() {
        _searchResults = foods;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Search Food',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerGray),
              ),
              child: TextField(
                onChanged: _searchFoods,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search foods...',
                  hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: AppTheme.textSecondary,
                    size: 5.w,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'camera_alt',
                        color: AppTheme.textSecondary,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'qr_code_scanner',
                        color: AppTheme.textSecondary,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            if (_searchQuery.isEmpty)
              Text(
                'Popular Foods',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (_searchQuery.isNotEmpty)
              Text(
                'Search Results (${_searchResults.length})',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            SizedBox(height: 2.h),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentGold,
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        return _buildFoodItem(food);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () => widget.onFoodSelected(food),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerGray),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'restaurant',
                color: AppTheme.accentGold,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'] ?? 'Unknown Food',
                    style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (food['brand'] != null)
                    Text(
                      food['brand'],
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      _buildNutritionInfo(
                        '${food['calories_per_100g']?.toInt() ?? 0}',
                        'cal',
                        AppTheme.accentGold,
                      ),
                      SizedBox(width: 3.w),
                      _buildNutritionInfo(
                        '${food['protein_per_100g']?.toInt() ?? 0}',
                        'P',
                        AppTheme.errorRed,
                      ),
                      SizedBox(width: 3.w),
                      _buildNutritionInfo(
                        '${food['carbs_per_100g']?.toInt() ?? 0}',
                        'C',
                        AppTheme.warningAmber,
                      ),
                      SizedBox(width: 3.w),
                      _buildNutritionInfo(
                        '${food['fat_per_100g']?.toInt() ?? 0}',
                        'F',
                        AppTheme.successGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'add_circle_outline',
              color: AppTheme.accentGold,
              size: 6.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo(String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value$label',
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
