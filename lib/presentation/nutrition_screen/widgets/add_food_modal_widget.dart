import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/nutrition_service.dart';

class AddFoodModalWidget extends StatefulWidget {
  final String mealType;
  final VoidCallback onFoodAdded;

  const AddFoodModalWidget({
    Key? key,
    required this.mealType,
    required this.onFoodAdded,
  }) : super(key: key);

  @override
  State<AddFoodModalWidget> createState() => _AddFoodModalWidgetState();
}

class _AddFoodModalWidgetState extends State<AddFoodModalWidget> {
  List<Map<String, dynamic>> _recentFoods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentFoods();
  }

  Future<void> _loadRecentFoods() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final foods = await NutritionService.instance.searchFoodItems(
        verifiedOnly: true,
        limit: 10,
      );

      setState(() {
        _recentFoods = foods;
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Adicionar ${_formatMealType(widget.mealType)}',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Buscar comida',
                    'search',
                    AppTheme.accentGold,
                    _showSearchDialog,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildActionButton(
                    'Escanear código de barras',
                    'qr_code_scanner',
                    AppTheme.successGreen,
                    _scanBarcode,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Camera',
                    'camera_alt',
                    AppTheme.errorRed,
                    _useCamera,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildActionButton(
                    'Voz',
                    'mic',
                    Colors.purple,
                    _useVoiceInput,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              'Comidas recentes',
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
                      itemCount: _recentFoods.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 1.h),
                      itemBuilder: (context, index) {
                        final food = _recentFoods[index];
                        return _buildRecentFoodItem(food);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, String icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
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

  Widget _buildRecentFoodItem(Map<String, dynamic> food) {
    return GestureDetector(
      onTap: () {
        // Add food to meal
        widget.onFoodAdded();
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.dividerGray),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomIconWidget(
                iconName: 'restaurant',
                color: AppTheme.accentGold,
                size: 4.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'] ?? 'Unknown Food',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
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
                ],
              ),
            ),
            Text(
              '${food['calories_per_100g']?.toInt() ?? 0} cal',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'add_circle_outline',
              color: AppTheme.textSecondary,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMealType(String mealType) {
    return mealType[0].toUpperCase() + mealType.substring(1);
  }

  void _showSearchDialog() {
    // Show nutrition search widget
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo busca de comida...'),
        backgroundColor: AppTheme.accentGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scanBarcode() {
    // Implement barcode scanning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo escaner...'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _useCamera() {
    // Implement camera-based food recognition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo camera...'),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _useVoiceInput() {
    // Implement voice input
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando voz...'),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
