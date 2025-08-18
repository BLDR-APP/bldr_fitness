import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './services/payment_service.dart';
import './services/supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseService.initialize();

    // Initialize Stripe Payment Service
    try {
      await PaymentService.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Payment service initialization failed: $e');
      }
      // Continue app launch even if payment service fails
    }

    runApp(const MyApp());
  } catch (e) {
    if (kDebugMode) {
      print('App initialization failed: $e');
    }
    // Handle initialization failure
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Initialization failed: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: MaterialApp(
            title: 'BLDR Fitness',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            initialRoute: AppRoutes.splashScreen,
            routes: AppRoutes.routes,
          ),
        );
      },
    );
  }
}
