import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/user_service.dart';
import './widgets/card_selection_widget.dart';
import './widgets/multiple_choice_widget.dart';
import './widgets/navigation_buttons_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/question_card_widget.dart';
import './widgets/single_choice_widget.dart';
import './widgets/slider_widget.dart';
import './widgets/summary_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;
  bool _isCompleting = false;

  // Response storage
  final Map<String, dynamic> _responses = {
    'fitness_goals': '',
    'experience_level': '',
    'workout_types': <String>[],
    'available_equipment': <String>[],
    'time_constraints': 30.0,
    'dietary_preferences': <String>[],
  };

  // Mock data for questions
  final List<String> _fitnessGoals = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'General Fitness',
    'Athletic Performance',
    'Rehabilitation',
  ];

  final List<String> _experienceLevels = [
    'Beginner (0-6 months)',
    'Intermediate (6 months - 2 years)',
    'Advanced (2+ years)',
    'Expert (5+ years)',
  ];

  final List<String> _workoutTypes = [
    'Strength Training',
    'Cardio',
    'HIIT',
    'Yoga',
    'Pilates',
    'CrossFit',
    'Running',
    'Swimming',
    'Cycling',
    'Dance',
  ];

  final List<Map<String, dynamic>> _equipmentOptions = [
    {'title': 'Dumbbells', 'icon': 'fitness_center'},
    {'title': 'Resistance Bands', 'icon': 'linear_scale'},
    {'title': 'Kettlebells', 'icon': 'sports_gymnastics'},
    {'title': 'Pull-up Bar', 'icon': 'height'},
    {'title': 'Yoga Mat', 'icon': 'self_improvement'},
    {'title': 'Treadmill', 'icon': 'directions_run'},
    {'title': 'Stationary Bike', 'icon': 'directions_bike'},
    {'title': 'No Equipment', 'icon': 'accessibility_new'},
  ];

  final List<String> _dietaryPreferences = [
    'No Restrictions',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Mediterranean',
    'Low Carb',
    'High Protein',
    'Gluten Free',
    'Dairy Free',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipStep() {
    _nextStep();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      // Save onboarding data to Supabase
      await UserService.instance.saveOnboardingData(
        onboardingData: _responses,
      );

      if (mounted) {
        setState(() {
          _isCompleting = false;
        });

        // Show completion dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.dialogDark,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.accentGold,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Setup Complete!',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your personalized fitness experience is ready. Let\'s start your journey!',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.dashboard,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: AppTheme.primaryBlack,
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: ${error.toString()}'),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.accentGold,
              onPressed: () => _completeOnboarding(),
            ),
          ),
        );
      }
    }
  }

  bool _canGoNext() {
    switch (_currentStep) {
      case 0:
        return (_responses['fitness_goals'] as String).isNotEmpty;
      case 1:
        return (_responses['experience_level'] as String).isNotEmpty;
      case 2:
        return (_responses['workout_types'] as List).isNotEmpty;
      case 3:
        return (_responses['available_equipment'] as List).isNotEmpty;
      case 4:
        return true; // Slider always has a value
      case 5:
        return (_responses['dietary_preferences'] as List).isNotEmpty;
      case 6:
        return true; // Summary step
      default:
        return false;
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentStep > 0) {
      _previousStep();
      return false;
    }

    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.dialogDark,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Exit Setup?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Text(
              'Your progress will be lost. Are you sure you want to exit?',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Continue Setup',
                  style: TextStyle(color: AppTheme.accentGold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Exit',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.primaryBlack,
        body: SafeArea(
          child: Column(
            children: [
              ProgressIndicatorWidget(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildFitnessGoalsStep(),
                    _buildExperienceLevelStep(),
                    _buildWorkoutTypesStep(),
                    _buildEquipmentStep(),
                    _buildTimeConstraintsStep(),
                    _buildDietaryPreferencesStep(),
                    _buildSummaryStep(),
                  ],
                ),
              ),
              NavigationButtonsWidget(
                canGoBack: _currentStep > 0,
                canGoNext: _canGoNext(),
                isLastStep: _currentStep == _totalSteps - 1,
                onBack: _previousStep,
                onNext: _nextStep,
                onSkip: _skipStep,
                showSkip:
                    _currentStep == 5, // Only show skip on dietary preferences
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFitnessGoalsStep() {
    return QuestionCardWidget(
      title: 'What\'s your main fitness goal?',
      subtitle:
          'This helps us create a personalized workout plan just for you.',
      child: SingleChoiceWidget(
        options: _fitnessGoals,
        selectedOption: _responses['fitness_goals'] as String?,
        onOptionSelected: (option) {
          setState(() {
            _responses['fitness_goals'] = option;
          });
        },
      ),
    );
  }

  Widget _buildExperienceLevelStep() {
    return QuestionCardWidget(
      title: 'What\'s your fitness experience?',
      subtitle:
          'We\'ll adjust the intensity and complexity of your workouts accordingly.',
      child: SingleChoiceWidget(
        options: _experienceLevels,
        selectedOption: _responses['experience_level'] as String?,
        onOptionSelected: (option) {
          setState(() {
            _responses['experience_level'] = option;
          });
        },
      ),
    );
  }

  Widget _buildWorkoutTypesStep() {
    return QuestionCardWidget(
      title: 'What types of workouts do you enjoy?',
      subtitle: 'Select all that apply. We\'ll mix these into your routine.',
      child: MultipleChoiceWidget(
        options: _workoutTypes,
        selectedOptions: _responses['workout_types'] as List<String>,
        onOptionsChanged: (options) {
          setState(() {
            _responses['workout_types'] = options;
          });
        },
      ),
    );
  }

  Widget _buildEquipmentStep() {
    return QuestionCardWidget(
      title: 'What equipment do you have access to?',
      subtitle: 'We\'ll design workouts based on your available equipment.',
      child: CardSelectionWidget(
        options: _equipmentOptions,
        selectedOptions: _responses['available_equipment'] as List<String>,
        onOptionsChanged: (options) {
          setState(() {
            _responses['available_equipment'] = options;
          });
        },
        multiSelect: true,
      ),
    );
  }

  Widget _buildTimeConstraintsStep() {
    return QuestionCardWidget(
      title: 'How much time can you dedicate to workouts?',
      subtitle: 'We\'ll create efficient routines that fit your schedule.',
      child: Column(
        children: [
          SliderWidget(
            value: _responses['time_constraints'] as double,
            min: 15,
            max: 120,
            divisions: 21,
            label: 'Minutes per workout',
            onChanged: (value) {
              setState(() {
                _responses['time_constraints'] = value;
              });
            },
          ),
          SizedBox(height: 4.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerGray),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.accentGold,
                  size: 6.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Perfect! ${(_responses['time_constraints'] as double).round()} minutes is great for effective workouts.',
                  textAlign: TextAlign.center,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferencesStep() {
    return QuestionCardWidget(
      title: 'Any dietary preferences?',
      subtitle:
          'Optional: This helps us suggest nutrition tips that align with your lifestyle.',
      child: MultipleChoiceWidget(
        options: _dietaryPreferences,
        selectedOptions: _responses['dietary_preferences'] as List<String>,
        onOptionsChanged: (options) {
          setState(() {
            _responses['dietary_preferences'] = options;
          });
        },
      ),
    );
  }

  Widget _buildSummaryStep() {
    return QuestionCardWidget(
      title: 'Almost done!',
      subtitle:
          'Review your preferences below. You can always change these later in settings.',
      child: SummaryWidget(
        responses: _responses,
        onEdit: (key) {
          int stepIndex = 0;
          switch (key) {
            case 'fitness_goals':
              stepIndex = 0;
              break;
            case 'experience_level':
              stepIndex = 1;
              break;
            case 'workout_types':
              stepIndex = 2;
              break;
            case 'available_equipment':
              stepIndex = 3;
              break;
            case 'time_constraints':
              stepIndex = 4;
              break;
            case 'dietary_preferences':
              stepIndex = 5;
              break;
          }
          _goToStep(stepIndex);
        },
      ),
    );
  }
}
