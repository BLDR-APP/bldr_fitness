import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import './widgets/login_form_widget.dart';
import './widgets/video_background_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String _errorMessage = '';

  //final Map<String, String> _mockCredentials = {
  //  'test@example.com': 'password123',
  //  'demo@app.com': 'demo123',
  //};

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Use real Supabase authentication
      final authResponse = await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      if (authResponse.user != null) {
        // Success - trigger haptic feedback
        HapticFeedback.mediumImpact();

        // Check if user has completed onboarding
        final hasCompletedOnboarding =
            await UserService.instance.hasCompletedOnboarding();

        if (mounted) {
          if (hasCompletedOnboarding) {
            // User has completed onboarding, go to dashboard
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            // User hasn't completed onboarding, show onboarding flow
            Navigator.pushReplacementNamed(context, '/onboarding-flow');
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
          _isLoading = false;
        });
        HapticFeedback.lightImpact();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Login failed: ${error.toString()}';
        _isLoading = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/sign-up-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: VideoBackgroundWidget(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 6.h), // 🔥 respiro fixo no topo
                    Spacer(), // espaço flexível acima

                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'error_outline',
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 4.h), // respiro entre card e credenciais

                    // Mock Credentials Info (for testing)
                   /*
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info_outline',
                                color: AppTheme.accentGold,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Test Credentials',
                                style: AppTheme.darkTheme.textTheme.labelLarge
                                    ?.copyWith(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          ..._mockCredentials.entries
                              .map((entry) => Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '${entry.key} / ${entry.value}',
                                      style: AppTheme
                                          .darkTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    */

                    Spacer(), // espaço flexível abaixo
                    SizedBox(height: 6.h), // 🔥 respiro fixo embaixo
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}