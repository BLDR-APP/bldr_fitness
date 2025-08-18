import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../../core/app_export.dart';
import '../../models/subscription_plan.dart';
import '../../services/payment_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import './widgets/billing_period_toggle_widget.dart';
import './widgets/payment_form_widget.dart';
import './widgets/plan_card_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  bool _isAnnualBilling = false;
  bool _isProcessingPayment = false;
  String? _errorMessage;
  String? _successMessage;

  List<SubscriptionPlan> _plans = [];
  SubscriptionPlan? _selectedPlan;
  bool _isLoadingPlans = true;
  int _currentPageIndex = 0;

  // Form controllers
  final _nameController = TextEditingController(text: '');
  final _emailController = TextEditingController(text: '');
  final _phoneController = TextEditingController(text: '');
  final _addressController = TextEditingController(text: '');
  final _cityController = TextEditingController(text: '');
  final _stateController = TextEditingController(text: '');
  final _zipCodeController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
    _loadSubscriptionPlans();
    _loadUserData();
  }

  Future<void> _initializePaymentService() async {
    try {
      await PaymentService.initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize payment service: $e';
        });
      }
    }
  }

  Future<void> _loadSubscriptionPlans() async {
    try {
      setState(() => _isLoadingPlans = true);

      final plans = await PaymentService.instance.getSubscriptionPlans();

      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoadingPlans = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load subscription plans: $e';
          _isLoadingPlans = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user?.email != null) {
        _emailController.text = user!.email!;
      }

      // Try to get user profile data
      final userProfile = await SupabaseService.instance.client
          .from('user_profiles')
          .select('full_name, email')
          .eq('id', user?.id ?? '')
          .maybeSingle();

      if (userProfile != null && mounted) {
        setState(() {
          _nameController.text = userProfile['full_name'] ?? '';
          _emailController.text = userProfile['email'] ?? user?.email ?? '';
        });
      }
    } catch (e) {
      // Silent fail - user can still fill manually
      if (kDebugMode) {
        print('Failed to load user data: $e');
      }
    }
  }

  void _selectPlan(SubscriptionPlan plan) {
    setState(() {
      _selectedPlan = plan;
    });
  }

  void _nextPage() {
    if (_currentPageIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate() || _selectedPlan == null) {
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Step 1: Create Payment Intent
      final billingPeriod = _isAnnualBilling ? 'annual' : 'monthly';
      final paymentIntentResponse =
          await PaymentService.instance.createSubscriptionPaymentIntent(
        planId: _selectedPlan!.id,
        billingPeriod: billingPeriod,
        currency: 'brl',
      );

      // Step 2: Create billing details
      final billingDetails = stripe.BillingDetails(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: stripe.Address(
          line1: _addressController.text,
          line2: '',
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _zipCodeController.text,
          country: 'BR',
        ),
      );

      // Step 3: Process payment
      final result = await PaymentService.instance.processPayment(
        clientSecret: paymentIntentResponse.clientSecret,
        merchantDisplayName: 'BLDR Fitness',
        billingDetails: billingDetails,
      );

      if (result.success && mounted) {
        setState(() {
          _successMessage = result.message;
          _errorMessage = null;
        });
        _showSuccessDialog(paymentIntentResponse.paymentIntentId);
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _successMessage = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _showSuccessDialog(String paymentIntentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.dialogDark,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successGreen, size: 28),
              SizedBox(width: 12),
              Text(
                'Pagamento Realizado!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sua assinatura foi ativada com sucesso!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              SizedBox(height: 16),
              Text(
                'Plano: ${_selectedPlan?.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                'Valor: ${_isAnnualBilling ? _selectedPlan?.annualPriceText : _selectedPlan?.monthlyPriceText}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              if (kDebugMode) ...[
                SizedBox(height: 8),
                Text(
                  'Payment ID: $paymentIntentId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                ),
              ],
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/dashboard');
              },
              child: Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        title: Text('Checkout BLDR'),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: _currentPageIndex > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: _isLoadingPlans
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold),
            )
          : Column(
              children: [
                // Progress Indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            decoration: BoxDecoration(
                              color: i <= _currentPageIndex
                                  ? AppTheme.accentGold
                                  : AppTheme.dividerGray,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // PageView Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    children: [
                      // Page 1: Plan Selection
                      _buildPlanSelectionPage(),
                      // Page 2: Billing Information
                      _buildBillingInformationPage(),
                      // Page 3: Payment
                      _buildPaymentPage(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPlanSelectionPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escolha seu Plano',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Selecione o plano que mais se adequa aos seus objetivos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          SizedBox(height: 24),

          // Billing Period Toggle
          BillingPeriodToggleWidget(
            isAnnual: _isAnnualBilling,
            onToggle: (isAnnual) {
              setState(() {
                _isAnnualBilling = isAnnual;
              });
            },
          ),
          SizedBox(height: 24),

          // Plan Cards
          for (final plan in _plans)
            PlanCardWidget(
              plan: plan,
              isAnnual: _isAnnualBilling,
              isSelected: _selectedPlan?.id == plan.id,
              onTap: () => _selectPlan(plan),
            ),

          SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedPlan != null ? _nextPage : null,
              child: Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInformationPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações de Cobrança',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Preencha seus dados para continuar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            SizedBox(height: 32),

            // Billing Form
            _buildTextField(_nameController, 'Nome Completo', true),
            _buildTextField(_emailController, 'Email', true,
                keyboardType: TextInputType.emailAddress),
            _buildTextField(_phoneController, 'Telefone', true,
                keyboardType: TextInputType.phone),
            _buildTextField(_addressController, 'Endereço', true),
            _buildTextField(_cityController, 'Cidade', true),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(_stateController, 'Estado', true),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(_zipCodeController, 'CEP', true),
                ),
              ],
            ),

            SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _nextPage();
                  }
                },
                child: Text('Continuar para Pagamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finalizar Pagamento',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8),
          Text(
            'Confirme os dados e finalize sua assinatura',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          SizedBox(height: 24),

          // Order Summary
          if (_selectedPlan != null)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerGray),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do Pedido',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedPlan!.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      Text(
                        _isAnnualBilling
                            ? _selectedPlan!.annualPriceText
                            : _selectedPlan!.monthlyPriceText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isAnnualBilling ? 'Cobrança anual' : 'Cobrança mensal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 24),

          // Payment Form
          PaymentFormWidget(
            onPaymentProcess: _processPayment,
            isProcessing: _isProcessingPayment,
            errorMessage: _errorMessage,
            successMessage: _successMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textSecondary),
          fillColor: AppTheme.surfaceDark,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.dividerGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.dividerGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.accentGold, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.errorRed),
          ),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, preencha o campo $label';
                }
                if (label == 'Email' && !value.contains('@')) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
}
