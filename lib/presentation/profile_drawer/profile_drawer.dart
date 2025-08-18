import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/confirmation_dialog_widget.dart';
import './widgets/edit_profile_dialog_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_section_widget.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({Key? key}) : super(key: key);

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  // Mock user data
  final Map<String, dynamic> _userData = {
    "id": 1,
    "name": "Alex Rodriguez",
    "email": "alex.rodriguez@email.com",
    "phone": "+1 (555) 123-4567",
    "profileImage":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face",
    "isPremium": true,
    "memberSince": "January 2023",
    "fitnessGoal": "Build Muscle",
    "preferredUnits": "Metric",
    "notificationsEnabled": true,
    "dataSync": true,
    "privacyMode": false,
  };

  bool get _notificationsEnabled => _userData["notificationsEnabled"] as bool;
  bool get _dataSyncEnabled => _userData["dataSync"] as bool;
  bool get _privacyModeEnabled => _userData["privacyMode"] as bool;

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialogWidget(
        currentName: _userData["name"] as String,
        currentEmail: _userData["email"] as String,
        currentPhone: _userData["phone"] as String,
        onSave: (name, email, phone) {
          setState(() {
            _userData["name"] = name;
            _userData["email"] = email;
            _userData["phone"] = phone;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        },
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.dialogDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Photo',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _handleCameraCapture();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerGray),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: AppTheme.accentGold,
                              size: 32,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Camera',
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _handleGallerySelection();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.dividerGray),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: AppTheme.accentGold,
                              size: 32,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Gallery',
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCameraCapture() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Camera feature will be implemented'),
        backgroundColor: AppTheme.warningAmber,
      ),
    );
  }

  void _handleGallerySelection() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gallery selection will be implemented'),
        backgroundColor: AppTheme.warningAmber,
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialogWidget(
        title: 'Delete Account',
        message:
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        confirmText: 'Delete Account',
        onConfirm: _handleDeleteAccount,
        isDestructive: true,
      ),
    );
  }

  void _handleDeleteAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account deletion initiated. You will be logged out.'),
        backgroundColor: AppTheme.errorRed,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(
        context, '/login-screen', (route) => false);
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialogWidget(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out of your account?',
        confirmText: 'Sign Out',
        onConfirm: () {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login-screen', (route) => false);
        },
      ),
    );
  }

  Widget _buildToggleSwitch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.accentGold,
      activeTrackColor: AppTheme.accentGold.withValues(alpha: 0.3),
      inactiveThumbColor: AppTheme.inactiveGray,
      inactiveTrackColor: AppTheme.inactiveGray.withValues(alpha: 0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.primaryBlack,
      width: 85.w,
      child: SafeArea(
        child: Column(
          children: [
            ProfileHeaderWidget(
              userName: _userData["name"] as String,
              userEmail: _userData["email"] as String,
              profileImageUrl: _userData["profileImage"] as String,
              isPremiumMember: _userData["isPremium"] as bool,
              onProfileImageTap: _showImagePickerDialog,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    ProfileSectionWidget(
                      title: 'Personal Information',
                      items: [
                        ProfileSectionItem(
                          title: 'Edit Profile',
                          subtitle: 'Update your personal details',
                          iconName: 'edit',
                          onTap: _showEditProfileDialog,
                        ),
                        ProfileSectionItem(
                          title: 'Member Since',
                          subtitle: _userData["memberSince"] as String,
                          iconName: 'calendar_today',
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    ProfileSectionWidget(
                      title: 'Fitness Profile',
                      items: [
                        ProfileSectionItem(
                          title: 'Fitness Goal',
                          subtitle: _userData["fitnessGoal"] as String,
                          iconName: 'fitness_center',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Fitness goals settings coming soon')),
                            );
                          },
                        ),
                        ProfileSectionItem(
                          title: 'Body Measurements',
                          subtitle: 'Height, weight, body fat',
                          iconName: 'straighten',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Measurements tracking coming soon')),
                            );
                          },
                        ),
                        ProfileSectionItem(
                          title: 'Workout Preferences',
                          subtitle: 'Customize your training',
                          iconName: 'tune',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Workout preferences coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    ProfileSectionWidget(
                      title: 'App Settings',
                      items: [
                        ProfileSectionItem(
                          title: 'Notifications',
                          subtitle: 'Workout reminders and updates',
                          iconName: 'notifications',
                          trailing: _buildToggleSwitch(
                            _notificationsEnabled,
                            (value) {
                              setState(() {
                                _userData["notificationsEnabled"] = value;
                              });
                            },
                          ),
                        ),
                        ProfileSectionItem(
                          title: 'Units',
                          subtitle: _userData["preferredUnits"] as String,
                          iconName: 'straighten',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Units settings coming soon')),
                            );
                          },
                        ),
                        ProfileSectionItem(
                          title: 'Data Sync',
                          subtitle: 'Sync across devices',
                          iconName: 'sync',
                          trailing: _buildToggleSwitch(
                            _dataSyncEnabled,
                            (value) {
                              setState(() {
                                _userData["dataSync"] = value;
                              });
                            },
                          ),
                        ),
                        ProfileSectionItem(
                          title: 'Privacy Mode',
                          subtitle: 'Hide personal data',
                          iconName: 'privacy_tip',
                          trailing: _buildToggleSwitch(
                            _privacyModeEnabled,
                            (value) {
                              setState(() {
                                _userData["privacyMode"] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    ProfileSectionWidget(
                      title: 'Account',
                      items: [
                        ProfileSectionItem(
                          title: 'Subscription',
                          subtitle: (_userData["isPremium"] as bool)
                              ? 'Premium Active'
                              : 'Free Plan',
                          iconName: 'card_membership',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Subscription management coming soon')),
                            );
                          },
                        ),
                        ProfileSectionItem(
                          title: 'Payment Methods',
                          subtitle: 'Manage billing',
                          iconName: 'payment',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Payment methods coming soon')),
                            );
                          },
                        ),
                        ProfileSectionItem(
                          title: 'Export Data',
                          subtitle: 'Download your fitness data',
                          iconName: 'download',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Data export coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    ProfileSectionWidget(
                      title: 'Support',
                      items: [
                        ProfileSectionItem(
                          title: 'Help Center',
                          subtitle: 'FAQs and guides',
                          iconName: 'help',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Help center coming soon')),
                            );
                          },
                        ),
                        ProfileSectionItem(
                          title: 'Contact Support',
                          subtitle: 'Get help from our team',
                          iconName: 'support_agent',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Contact support coming soon')),
                            );
                          },
                        ),
                        ProfileSectionItem(
                          title: 'App Version',
                          subtitle: 'v1.0.0 (Build 100)',
                          iconName: 'info',
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    ProfileSectionWidget(
                      title: 'Account Actions',
                      items: [
                        ProfileSectionItem(
                          title: 'Sign Out',
                          subtitle: 'Sign out of your account',
                          iconName: 'logout',
                          onTap: _handleLogout,
                        ),
                        ProfileSectionItem(
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          iconName: 'delete_forever',
                          onTap: _showDeleteAccountDialog,
                          isDestructive: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
