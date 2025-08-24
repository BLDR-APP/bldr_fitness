import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  // Estado do usuário (com persistência em SharedPreferences)
  Map<String, dynamic> _userData = {
    "id": 1,
    "name": "Alex Rodriguez",
    "email": "alex.rodriguez@email.com",
    "phone": "+1 (555) 123-4567",
    "profileImage": // pode ser URL http(s) OU caminho local (File.path)
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face",
    "isPremium": true,
    "memberSince": "January 2023",
    "fitnessGoal": "Build Muscle",
    "preferredUnits": "Metric",
    "notificationsEnabled": true,
    "dataSync": true,
    "privacyMode": false,
    // medidas básicas
    "heightCm": null,
    "weightKg": null,
    "bodyFat": null,
  };

  SharedPreferences? _prefs;

  bool get _notificationsEnabled => _userData["notificationsEnabled"] as bool;
  bool get _dataSyncEnabled => _userData["dataSync"] as bool;
  bool get _privacyModeEnabled => _userData["privacyMode"] as bool;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _prefs = await SharedPreferences.getInstance();
    final jsonStr = _prefs!.getString('profile_user_data');
    if (jsonStr != null) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        setState(() => _userData = {..._userData, ...map});
      } catch (_) {
        // Se der erro no parse, mantemos os defaults
      }
    }
  }

  Future<void> _persistUserData() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    await _prefs!.setString('profile_user_data', json.encode(_userData));
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialogWidget(
        currentName: _userData["name"] as String,
        currentEmail: _userData["email"] as String,
        currentPhone: _userData["phone"] as String,
        onSave: (name, email, phone) async {
          setState(() {
            _userData["name"] = name;
            _userData["email"] = email;
            _userData["phone"] = phone;
          });
          await _persistUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Perfil atualizado com sucesso!'),
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
                'Alterar foto de perfil',
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
                            const Icon(Icons.camera_alt,
                                color: AppTheme.accentGold, size: 32),
                            SizedBox(height: 1.h),
                            Text(
                              'Câmera',
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textPrimary),
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
                            const Icon(Icons.photo_library,
                                color: AppTheme.accentGold, size: 32),
                            SizedBox(height: 1.h),
                            Text(
                              'Galeria',
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textPrimary),
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
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _savePickedFile(XFile picked) async {
    // Web: usar o path (blob:/data-URL) direto; Mobile: copiar p/ diretório do app
    if (kIsWeb) return picked.path;

    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(picked.path);
    final target = File(p.join(dir.path, 'profile_image$ext'));
    final bytes = await picked.readAsBytes();
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  Future<void> _handleCameraCapture() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (photo != null) {
        final saved = await _savePickedFile(photo);
        if (saved != null) {
          setState(() => _userData["profileImage"] = saved);
          await _persistUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Foto atualizada!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao usar a câmera: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _handleGallerySelection() async {
    try {
      final picker = ImagePicker();
      final XFile? img = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        imageQuality: 90,
      );
    if (img != null) {
        final saved = await _savePickedFile(img);
        if (saved != null) {
          setState(() => _userData["profileImage"] = saved);
          await _persistUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Foto atualizada!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao escolher imagem: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _showOptionsSheet({
    required String title,
    required List<String> options,
    required String currentValue,
    required void Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.dialogDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(height: 2.h),
              ...options.map((opt) {
                final selected = opt == currentValue;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(opt,
                      style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      )),
                  trailing: selected
                      ? const Icon(Icons.check, color: AppTheme.accentGold)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(opt);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showMeasurementsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.dialogDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Body Measurements',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              _buildMeasurementField('Height (cm)', 'heightCm'),
              SizedBox(height: 2.h),
              _buildMeasurementField('Weight (kg)', 'weightKg'),
              SizedBox(height: 2.h),
              _buildMeasurementField('Body Fat (%)', 'bodyFat'),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _persistUserData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Measurements saved!'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          initialValue: _userData[key]?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
          style: TextStyle(color: AppTheme.textPrimary),
          onChanged: (value) {
            final numValue = double.tryParse(value);
            _userData[key] = numValue;
          },
        ),
      ],
    );
  }

  Future<void> _shareProfile() async {
    try {
      final name = _userData["name"] as String;
      final goal = _userData["fitnessGoal"] as String;
      final member = _userData["memberSince"] as String;

      await Share.share(
        'Check out my BLDR Fitness profile!\n\n'
        '👤 $name\n'
        '🎯 Goal: $goal\n'
        '📅 Member since: $member\n\n'
        'Join me on BLDR Fitness - Your AI-powered fitness journey!',
        subject: '$name\'s BLDR Fitness Profile',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing profile: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _exportProgress() {
    // Mantido como "coming soon" conforme seu arquivo atual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress export feature coming soon!'),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialogWidget(
        title: 'Sign Out',
        message: 'Are you sure you want to sign out?',
        confirmText: 'Sign Out',
        onConfirm: () {
          // Clear user data e navegar p/ login
          _userData.clear();
          _persistUserData();
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.loginScreen,
            (route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.primaryBlack,
      child: SafeArea(
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(
              userName: _userData["name"] as String,
              userEmail: _userData["email"] as String,
              profileImageUrl: _userData["profileImage"] as String,
              isPremiumMember: _userData["isPremium"] as bool,
              onProfileImageTap: _showImagePickerDialog,
            ),

            // Divider
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              color: AppTheme.dividerGray,
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // PERSONAL INFO (ajuste mínimo para reativar o diálogo de edição)
                    ProfileSectionWidget(
                      title: 'PERSONAL INFO',
                      items: [
                        ProfileSectionItem(
                          iconName: 'edit',
                          title: 'Edit Profile',
                          subtitle: 'Update name, email, phone',
                          onTap: _showEditProfileDialog,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Fitness Settings
                    ProfileSectionWidget(
                      title: 'FITNESS SETTINGS',
                      items: [
                        ProfileSectionItem(
                          iconName: 'fitness_center',
                          title: 'Fitness Goal',
                          subtitle: _userData["fitnessGoal"] as String,
                          onTap: () => _showOptionsSheet(
                            title: 'Select Fitness Goal',
                            options: const [
                              'Lose Weight',
                              'Build Muscle',
                              'Maintain',
                              'General Fitness'
                            ],
                            currentValue: _userData["fitnessGoal"] as String,
                            onSelected: (value) async {
                              setState(() => _userData["fitnessGoal"] = value);
                              await _persistUserData();
                            },
                          ),
                        ),
                        ProfileSectionItem(
                          iconName: 'straighten',
                          title: 'Units',
                          subtitle: _userData["preferredUnits"] as String,
                          onTap: () => _showOptionsSheet(
                            title: 'Select Units',
                            options: const ['Metric', 'Imperial'],
                            currentValue: _userData["preferredUnits"] as String,
                            onSelected: (value) async {
                              setState(
                                  () => _userData["preferredUnits"] = value);
                              await _persistUserData();
                            },
                          ),
                        ),
                        ProfileSectionItem(
                          iconName: 'fitness_center',
                          title: 'Body Measurements',
                          subtitle: 'Height, Weight, Body Fat',
                          onTap: _showMeasurementsDialog,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // App Settings
                    ProfileSectionWidget(
                      title: 'APP SETTINGS',
                      items: [
                        ProfileSectionItem(
                          iconName: 'notifications',
                          title: 'Notifications',
                          subtitle:
                              _notificationsEnabled ? 'Enabled' : 'Disabled',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) async {
                              setState(() =>
                                  _userData["notificationsEnabled"] = value);
                              await _persistUserData();
                            },
                            activeColor: AppTheme.accentGold,
                          ),
                          onTap: () async {
                            setState(() => _userData["notificationsEnabled"] =
                                !_notificationsEnabled);
                            await _persistUserData();
                          },
                        ),
                        ProfileSectionItem(
                          iconName: 'sync',
                          title: 'Data Sync',
                          subtitle: _dataSyncEnabled ? 'Enabled' : 'Disabled',
                          trailing: Switch(
                            value: _dataSyncEnabled,
                            onChanged: (value) async {
                              setState(() => _userData["dataSync"] = value);
                              await _persistUserData();
                            },
                            activeColor: AppTheme.accentGold,
                          ),
                          onTap: () async {
                            setState(() =>
                                _userData["dataSync"] = !_dataSyncEnabled);
                            await _persistUserData();
                          },
                        ),
                        ProfileSectionItem(
                          iconName: 'privacy_tip',
                          title: 'Privacy Mode',
                          subtitle:
                              _privacyModeEnabled ? 'Enabled' : 'Disabled',
                          trailing: Switch(
                            value: _privacyModeEnabled,
                            onChanged: (value) async {
                              setState(() => _userData["privacyMode"] = value);
                              await _persistUserData();
                            },
                            activeColor: AppTheme.accentGold,
                          ),
                          onTap: () async {
                            setState(() => _userData["privacyMode"] =
                                !_privacyModeEnabled);
                            await _persistUserData();
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Data & Sharing
                    ProfileSectionWidget(
                      title: 'DATA & SHARING',
                      items: [
                        ProfileSectionItem(
                          iconName: 'download',
                          title: 'Share Profile',
                          subtitle: 'Share your fitness journey',
                          onTap: _shareProfile,
                        ),
                        ProfileSectionItem(
                          iconName: 'download',
                          title: 'Export Progress',
                          subtitle: 'Download your data',
                          onTap: _exportProgress,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Account Actions
                    ProfileSectionWidget(
                      title: 'ACCOUNT',
                      items: [
                        ProfileSectionItem(
                          iconName: 'logout',
                          title: 'Sign Out',
                          subtitle: 'Sign out of your account',
                          onTap: _showLogoutConfirmation,
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
