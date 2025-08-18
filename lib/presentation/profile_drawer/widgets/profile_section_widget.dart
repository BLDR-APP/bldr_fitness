import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ProfileSectionItem {
  final String title;
  final String? subtitle;
  final String iconName;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;

  ProfileSectionItem({
    required this.title,
    this.subtitle,
    required this.iconName,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });
}

class ProfileSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget>? children;
  final List<ProfileSectionItem>? items;

  const ProfileSectionWidget({
    Key? key,
    required this.title,
    this.children,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(title),
        if (items != null)
          ...items!
              .map((item) => _buildMenuItem(
                    context,
                    icon: item.iconName,
                    title: item.title,
                    subtitle: item.subtitle,
                    onTap: item.onTap,
                    trailing: item.trailing,
                    isDestructive: item.isDestructive,
                  ))
              .toList(),
        if (children != null) ...children!,
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
      child: Text(
        title,
        style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
          color: AppTheme.accentGold,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    bool showArrow = true,
    bool isDestructive = false,
  }) {
    // Map of icon names to Material Icons
    final Map<String, IconData> iconMap = {
      'edit': Icons.edit,
      'calendar_today': Icons.calendar_today,
      'fitness_center': Icons.fitness_center,
      'straighten': Icons.straighten,
      'tune': Icons.tune,
      'notifications': Icons.notifications,
      'sync': Icons.sync,
      'privacy_tip': Icons.privacy_tip,
      'card_membership': Icons.card_membership,
      'payment': Icons.payment,
      'download': Icons.download,
      'help': Icons.help,
      'support_agent': Icons.support_agent,
      'info': Icons.info,
      'logout': Icons.logout,
      'delete_forever': Icons.delete_forever,
      'chevron_right': Icons.chevron_right,
    };

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerGray,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: (isDestructive ? AppTheme.errorRed : AppTheme.accentGold)
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            iconMap[icon] ?? Icons.help_outline,
            color: isDestructive ? AppTheme.errorRed : AppTheme.accentGold,
            size: 5.w,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
            color: isDestructive ? AppTheme.errorRed : AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              )
            : null,
        trailing: trailing ??
            (onTap != null && showArrow
                ? Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                    size: 4.w,
                  )
                : null),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
      ),
    );
  }
}
