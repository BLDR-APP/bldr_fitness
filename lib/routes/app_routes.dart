import 'package:flutter/material.dart';

import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/sign_up_screen/sign_up_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/checkout_screen/checkout_screen.dart';
import '../presentation/progress_screen/progress_screen.dart';
import '../presentation/nutrition_screen/nutrition_screen.dart';
import '../presentation/workouts_screen/workouts_screen.dart';
import '../presentation/email_confirmation_screen/email_confirmation_screen.dart';
import '../presentation/profile_drawer/profile_drawer.dart';

class AppRoutes {
  // Route constants
  static const String splashScreen = '/';
  static const String loginScreen = '/login-screen';
  static const String signUpScreen = '/sign-up-screen';
  static const String emailConfirmationScreen = '/email-confirmation-screen';
  static const String dashboard = '/dashboard';
  static const String onboardingFlow = '/onboarding-flow';
  static const String checkoutScreen = '/checkout-screen';
  static const String progressScreen = '/progress-screen';
  static const String nutritionScreen = '/nutrition-screen';
  static const String workoutsScreen = '/workouts-screen';
  static const String profileDrawer = '/profile-drawer';

  // Route map
  static Map<String, WidgetBuilder> get routes => {
        splashScreen: (context) => const SplashScreen(),
        loginScreen: (context) => const LoginScreen(),
        signUpScreen: (context) => const SignUpScreen(),
        emailConfirmationScreen: (context) => const EmailConfirmationScreen(),
        dashboard: (context) => const Dashboard(),
        onboardingFlow: (context) => const OnboardingFlow(),
        checkoutScreen: (context) => const CheckoutScreen(),
        progressScreen: (context) => const ProgressScreen(),
        nutritionScreen: (context) => const NutritionScreen(),
        workoutsScreen: (context) => const WorkoutsScreen(),
      };
}
