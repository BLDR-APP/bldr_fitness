import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/user_profile.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../theme/app_theme.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? profileImageUrl;
  final bool? isPremiumMember;
  final VoidCallback? onProfileImageTap;

  const ProfileHeaderWidget({
    Key? key,
    this.userName,
    this.userEmail,
    this.profileImageUrl,
    this.isPremiumMember,
    this.onProfileImageTap,
  }) : super(key: key);

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  UserProfile? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserService.instance.getCurrentUserProfile();
      if (mounted) {
        setState(() {
          userProfile = profile;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentGold.withValues(alpha: 0.2),
            AppTheme.surfaceDark,
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              GestureDetector(
                onTap: widget.onProfileImageTap,
                child: CircleAvatar(
                  radius: 15.w,
                  backgroundColor: AppTheme.accentGold,
                  backgroundImage:
                      (widget.profileImageUrl ?? userProfile?.avatarUrl) != null
                          ? NetworkImage(
                              widget.profileImageUrl ?? userProfile!.avatarUrl!)
                          : null,
                  child: (widget.profileImageUrl ?? userProfile?.avatarUrl) ==
                          null
                      ? Text(
                          isLoading
                              ? '...'
                              : (widget.userName?.isNotEmpty == true
                                  ? widget.userName![0].toUpperCase()
                                  : userProfile?.fullName.isNotEmpty == true
                                      ? userProfile!.fullName[0].toUpperCase()
                                      : AuthService.instance
                                              .getCurrentUserEmail()?[0]
                                              .toUpperCase() ??
                                          'U'),
                          style: AppTheme.darkTheme.textTheme.headlineMedium
                              ?.copyWith(
                            color: AppTheme.primaryBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              if (widget.onProfileImageTap != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(1.5.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryBlack,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppTheme.primaryBlack,
                      size: 4.w,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),

          // User Name
          Text(
            isLoading
                ? 'Loading...'
                : (widget.userName ??
                    userProfile?.fullName ??
                    AuthService.instance.getCurrentUserEmail()?.split('@')[0] ??
                    'User'),
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),

          // Email
          Text(
            widget.userEmail ??
                AuthService.instance.getCurrentUserEmail() ??
                'No email',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),

          // Premium Badge
          if (widget.isPremiumMember == true || userProfile != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentGold,
                  width: 1,
                ),
              ),
              child: Text(
                widget.isPremiumMember == true
                    ? 'Premium Member'
                    : userProfile?.roleDisplayName ?? 'Member',
                style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
