import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhotoProgressWidget extends StatefulWidget {
  const PhotoProgressWidget({Key? key}) : super(key: key);

  @override
  State<PhotoProgressWidget> createState() => _PhotoProgressWidgetState();
}

class _PhotoProgressWidgetState extends State<PhotoProgressWidget> {
  List<Map<String, dynamic>> _progressPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressPhotos();
  }

  Future<void> _loadProgressPhotos() async {
    setState(() => _isLoading = true);

    try {
      // In a real implementation, this would load from Supabase storage
      // For now, we'll use mock data
      await Future.delayed(const Duration(milliseconds: 500));

      final mockPhotos = [
        {
          'id': '1',
          'url':
              'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=300&h=400&fit=crop',
          'date': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
          'type': 'front',
          'notes': 'Starting progress photo',
        },
        {
          'id': '2',
          'url':
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=400&fit=crop',
          'date': DateTime.now().subtract(Duration(days: 15)).toIso8601String(),
          'type': 'side',
          'notes': '2 weeks progress',
        },
      ];

      if (mounted) {
        setState(() {
          _progressPhotos = mockPhotos;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddPhotoDialog() {
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
              'Add Progress Photo',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoOption(
                    'Camera',
                    'photo_camera',
                    AppTheme.accentGold,
                    () => _takePhoto(),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildPhotoOption(
                    'Gallery',
                    'photo_library',
                    AppTheme.successGreen,
                    () => _selectFromGallery(),
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

  Widget _buildPhotoOption(
    String title,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
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
                iconName: iconName,
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
            ),
          ],
        ),
      ),
    );
  }

  void _takePhoto() {
    // In a real implementation, this would use camera package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Camera feature will be implemented with camera package'),
        backgroundColor: AppTheme.warningAmber,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectFromGallery() {
    // In a real implementation, this would use image_picker package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Gallery feature will be implemented with image_picker package'),
        backgroundColor: AppTheme.warningAmber,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPhotoComparison() {
    if (_progressPhotos.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add at least 2 photos to compare progress'),
          backgroundColor: AppTheme.warningAmber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.dialogDark,
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Progress Comparison',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Before',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_progressPhotos.first['url']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _formatDate(_progressPhotos.first['date']),
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'After',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(_progressPhotos.last['url']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _formatDate(_progressPhotos.last['date']),
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year}';
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
                  color: AppTheme.successGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'photo_camera',
                  color: AppTheme.successGreen,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Photo Progress',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: _showAddPhotoDialog,
                icon: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.successGreen,
                    size: 4.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: AppTheme.successGreen),
            )
          else if (_progressPhotos.isEmpty)
            _buildEmptyState()
          else
            _buildPhotoGallery(),
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
            iconName: 'photo_camera',
            color: AppTheme.inactiveGray,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No progress photos yet',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Take photos to visually track your transformation',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _showAddPhotoDialog,
            icon: Icon(Icons.add_a_photo, size: 5.w),
            label: Text('Add First Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      children: [
        if (_progressPhotos.length >= 2) ...[
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showPhotoComparison,
              icon: Icon(Icons.compare, size: 5.w),
              label: Text('Compare Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.primaryBlack,
              ),
            ),
          ),
          SizedBox(height: 3.h),
        ],
        SizedBox(
          height: 30.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _progressPhotos.length,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            itemBuilder: (context, index) {
              final photo = _progressPhotos[index];
              return _buildPhotoCard(photo, index);
            },
          ),
        ),
        SizedBox(height: 3.h),
        _buildPhotoTips(),
      ],
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo, int index) {
    final date = DateTime.parse(photo['date']);
    final notes = photo['notes'] ?? '';

    return Container(
      width: 35.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(photo['url']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlack.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2.w,
                      left: 2.w,
                      right: 2.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(photo['date']),
                            style: AppTheme.darkTheme.textTheme.labelMedium
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (notes.isNotEmpty) ...[
                            SizedBox(height: 0.5.h),
                            Text(
                              notes,
                              style: AppTheme.darkTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTips() {
    return Container(
      padding: EdgeInsets.all(3.w),
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
              CustomIconWidget(
                iconName: 'lightbulb',
                color: AppTheme.warningAmber,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Photo Tips',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '• Take photos in the same lighting and pose\n'
            '• Wear similar clothing for consistency\n'
            '• Take front, side, and back views\n'
            '• Schedule weekly progress photos',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
