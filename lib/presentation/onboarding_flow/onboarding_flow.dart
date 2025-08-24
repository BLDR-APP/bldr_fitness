import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
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

  // Respostas do usuário
  final Map<String, dynamic> _responses = {
    'fitness_goals': '',
    'experience_level': '',
    'workout_types': <String>[],
    'available_equipment': <String>[],
    'time_constraints': 30.0,
    'dietary_preferences': <String>[],
  };

  // Opções de objetivos
  final List<String> _fitnessGoals = [
    'Perder Peso',
    'Ganhar Massa Muscular',
    'Melhorar Resistência',
    'Saúde Geral',
    'Performance Esportiva',
    'Reabilitação',
  ];

  final List<String> _experienceLevels = [
    'Iniciante (0-6 meses)',
    'Intermediário (6 meses - 2 anos)',
    'Avançado (2+ anos)',
    'Especialista (5+ anos)',
  ];

  final List<String> _workoutTypes = [
    'Treino de Força',
    'Cardio',
    'HIIT',
    'Yoga',
    'Pilates',
    'CrossFit',
    'Corrida',
    'Natação',
    'Ciclismo',
    'Dança',
  ];

  final List<Map<String, dynamic>> _equipmentOptions = [
    {'title': 'Halteres', 'icon': 'fitness_center'},
    {'title': 'Faixas Elásticas', 'icon': 'linear_scale'},
    {'title': 'Kettlebells', 'icon': 'sports_gymnastics'},
    {'title': 'Barra Fixa', 'icon': 'height'},
    {'title': 'Tapete de Yoga', 'icon': 'self_improvement'},
    {'title': 'Esteira', 'icon': 'directions_run'},
    {'title': 'Bicicleta Ergométrica', 'icon': 'directions_bike'},
    {'title': 'Sem Equipamento', 'icon': 'accessibility_new'},
  ];

  final List<String> _dietaryPreferences = [
    'Sem Restrições',
    'Vegetariano',
    'Vegano',
    'Keto',
    'Paleo',
    'Mediterrânea',
    'Low Carb',
    'Alta Proteína',
    'Sem Glúten',
    'Sem Lactose',
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.primaryBlack,
        body: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Padding(
                padding: EdgeInsets.all(4.w),
                child: ProgressIndicatorWidget(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                ),
              ),

              // Main Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
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

              // Navigation Buttons
              Padding(
                padding: EdgeInsets.all(4.w),
                child: NavigationButtonsWidget(
                  canGoBack: _currentStep > 0,
                  canGoNext: _canProceedToNextStep(),
                  isLastStep: _currentStep == _totalSteps - 1,
                  onBack: _previousStep,
                  onNext: _currentStep == _totalSteps - 1
                      ? _completeOnboarding
                      : _nextStep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < _totalSteps) {
      setState(() {
        _currentStep = stepIndex;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return (_responses['fitness_goals'] as String).isNotEmpty;
      case 1:
        return (_responses['experience_level'] as String).isNotEmpty;
      case 2:
        return (_responses['workout_types'] as List<String>).isNotEmpty;
      case 3:
        return (_responses['available_equipment'] as List<String>).isNotEmpty;
      case 4:
        return true; // Time constraints always has a default value
      case 5:
        return true; // Dietary preferences is optional
      case 6:
        return true; // Summary step
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      final sb = Supabase.instance.client;
      final user = sb.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado.');
      }

      if (user.email == null) {
        // se sua coluna email é NOT NULL, melhor falhar de forma clara
        throw Exception(
            'Email do usuário não disponível para salvar no perfil.');
      }

      final payload = {
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'Usuário',
        'onboarding_data': _responses,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      // upsert correto (sem .eq) e garantindo conflito pelo id
      await sb.from('user_profiles').upsert(
            payload,
            onConflict: 'id',
          );

      if (mounted) {
        setState(() {
          _isCompleting = false;
        });

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
                  'Configuração Concluída!',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            content: Text(
              'Sua experiência fitness personalizada está pronta. Vamos começar a jornada!',
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
                child: const Text('Começar'),
              ),
            ],
          ),
        );
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro Supabase: code=${e.code} | ${e.message}${e.details != null ? " | ${e.details}" : ""}',
            ),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: 'Tentar Novamente',
              textColor: AppTheme.accentGold,
              onPressed: () => _completeOnboarding(),
            ),
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
            content:
                Text('Falha ao concluir configuração: ${error.toString()}'),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: 'Tentar Novamente',
              textColor: AppTheme.accentGold,
              onPressed: () => _completeOnboarding(),
            ),
          ),
        );
      }
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
              'Sair da Configuração?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Text(
              'Seu progresso será perdido. Deseja realmente sair?',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Continuar',
                  style: TextStyle(color: AppTheme.accentGold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Sair',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  // --- Passos traduzidos ---
  Widget _buildFitnessGoalsStep() {
    return QuestionCardWidget(
      title: 'Qual é o seu principal objetivo fitness?',
      subtitle: 'Isso nos ajuda a criar um treino personalizado para você.',
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
      title: 'Qual é a sua experiência com treinos?',
      subtitle:
          'Vamos ajustar a intensidade e complexidade conforme seu nível.',
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
      title: 'Quais tipos de treino você prefere?',
      subtitle: 'Selecione todos que se aplicam. Vamos incluir na sua rotina.',
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
      title: 'Quais equipamentos você tem disponíveis?',
      subtitle: 'Montaremos treinos de acordo com seus recursos.',
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
      title: 'Quanto tempo você pode dedicar aos treinos?',
      subtitle: 'Vamos criar rotinas eficientes que cabem na sua agenda.',
      child: Column(
        children: [
          SliderWidget(
            value: _responses['time_constraints'] as double,
            min: 15,
            max: 120,
            divisions: 21,
            label: 'Minutos por treino',
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
                  'Perfeito! ${(_responses['time_constraints'] as double).round()} minutos é ótimo para treinos eficazes.',
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
      title: 'Alguma preferência alimentar?',
      subtitle:
          'Opcional: Isso ajuda a sugerir dicas nutricionais que combinam com seu estilo de vida.',
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
      title: 'Quase lá!',
      subtitle:
          'Revise suas preferências abaixo. Você pode alterá-las depois em Configurações.',
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
