import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/supabase_service.dart';
import '../models/subscription_plan.dart';

class PaymentService {
  static PaymentService? _instance;
  static PaymentService get instance => _instance ??= PaymentService._();
  PaymentService._();

  final Dio _dio = Dio();
  final String _baseUrl = '${SupabaseService.supabaseUrl}/functions/v1';

  /// Initialize Stripe with publishable key
  static Future<void> initialize() async {
    try {
      const String publishableKey = String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
        defaultValue: '',
      );

      if (publishableKey.isEmpty) {
        if (kDebugMode) {
          print(
              'STRIPE_PUBLISHABLE_KEY not configured - payment features disabled');
        }
        return;
      }

      // Initialize Stripe for both platforms
      Stripe.publishableKey = publishableKey;

      // Initialize web-specific settings if on web
      if (kIsWeb) {
        await Stripe.instance.applySettings();
      }

      if (kDebugMode) {
        print(
            'Stripe initialized successfully for ${kIsWeb ? 'web' : 'mobile'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Stripe initialization error: $e');
      }
      rethrow;
    }
  }

  /// Get all available subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final client = SupabaseService.instance.client;
      final response = await client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('plan_type', ascending: true);

      return response
          .map<SubscriptionPlan>((json) => SubscriptionPlan.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subscription plans: $e');
    }
  }

  /// Create payment intent for subscription
  Future<PaymentIntentResponse> createSubscriptionPaymentIntent({
    required String planId,
    required String billingPeriod, // 'monthly' or 'annual'
    String currency = 'brl',
  }) async {
    try {
      // Check authentication
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated. Please login and try again.');
      }

      // Get the current session for access token
      final session = SupabaseService.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception('No active session found. Please login again.');
      }

      final response = await _dio.post(
        '$_baseUrl/create-subscription-payment-intent',
        data: {
          'plan_id': planId,
          'billing_period': billingPeriod,
          'currency': currency,
          'user_id': user.id,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PaymentIntentResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create payment intent: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.response?.data != null) {
        if (e.response?.data['error'] != null) {
          errorMessage = 'Payment error: ${e.response?.data['error']}';
        } else {
          errorMessage =
              'Server error: ${e.response?.statusMessage ?? 'Unknown error'}';
        }
      } else if (e.message?.contains('SocketException') == true) {
        errorMessage = 'No internet connection. Please check your network.';
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow; // Re-throw our custom exceptions
      }
      throw Exception('Unexpected error: $e');
    }
  }

  /// Process payment using unified approach for both mobile and web
  Future<PaymentResult> processPayment({
    required String clientSecret,
    required String merchantDisplayName,
    required BillingDetails billingDetails,
  }) async {
    try {
      // Validate client secret
      if (clientSecret.isEmpty) {
        throw Exception('Invalid payment configuration');
      }

      // Check if Stripe is properly initialized
      if (Stripe.publishableKey.isEmpty) {
        throw Exception('Payment service not properly initialized');
      }

      // Confirm payment directly with CardField data
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      // Check payment status
      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        return PaymentResult(
          success: true,
          message: 'Payment completed successfully',
          paymentIntentId: paymentIntent.id,
        );
      } else {
        return PaymentResult(
          success: false,
          message: 'Payment was not completed. Status: ${paymentIntent.status}',
        );
      }
    } on StripeException catch (e) {
      return PaymentResult(
        success: false,
        message: _getStripeErrorMessage(e),
        errorCode: e.error.code.name,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  /// Get current user subscription
  Future<UserSubscription?> getCurrentUserSubscription() async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) return null;

      final response = await client
          .from('user_subscriptions')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;

      return UserSubscription.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user subscription: $e');
      }
      return null;
    }
  }

  /// Cancel user subscription
  Future<bool> cancelSubscription() async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      await client
          .from('user_subscriptions')
          .update({
            'status': 'canceled',
            'canceled_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('status', 'active');

      return true;
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  /// Get user-friendly error message from Stripe error
  String _getStripeErrorMessage(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return 'Payment was cancelled';
      case FailureCode.Failed:
        return 'Payment failed. Please try again.';
      case FailureCode.Timeout:
        return 'Payment timed out. Please try again.';
      default:
        return e.error.localizedMessage ?? 'Payment failed. Please try again.';
    }
  }
}

/// Payment Intent Response model
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final String paymentId;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.paymentId,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentIntentResponse(
      clientSecret: json['client_secret'],
      paymentIntentId: json['payment_intent_id'],
      paymentId: json['payment_id'],
    );
  }
}

/// Payment Result model
class PaymentResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? paymentIntentId;

  PaymentResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.paymentIntentId,
  });
}
