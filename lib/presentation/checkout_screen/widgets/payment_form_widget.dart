import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PaymentFormWidget extends StatelessWidget {
  final VoidCallback onPaymentProcess;
  final bool isProcessing;
  final String? errorMessage;
  final String? successMessage;

  const PaymentFormWidget({
    super.key,
    required this.onPaymentProcess,
    required this.isProcessing,
    this.errorMessage,
    this.successMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Information Section
        Text(
          'Informações do Cartão',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),

        // Card Field
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerGray),
          ),
          child: stripe.CardField(
            onCardChanged: (card) {
              if (kDebugMode) {
                print('Card changed: ${card?.complete}');
              }
            },
            decoration: InputDecoration(
              labelText: 'Dados do Cartão',
              labelStyle: TextStyle(color: AppTheme.textSecondary),
              border: InputBorder.none,
              helperText: 'Digite o número, validade e CVV do seu cartão',
              helperStyle: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),

        SizedBox(height: 20),

        // Test cards info in debug mode
        if (kDebugMode)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningAmber.withAlpha(26),
              border: Border.all(color: AppTheme.warningAmber.withAlpha(77)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cartões de Teste (Modo Desenvolvimento):',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.warningAmber,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Text(
                  '• Sucesso: 4242 4242 4242 4242',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  '• Recusado: 4000 0000 0000 9995',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  '• 3D Secure: 4000 0000 0000 3220',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                Text(
                  '• Use qualquer data futura e CVV válido',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),

        SizedBox(height: 20),

        // Security Info
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.successGreen.withAlpha(77)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: AppTheme.successGreen,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Seus dados estão protegidos com criptografia SSL e processamento seguro via Stripe',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.successGreen,
                      ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Error Message
        if (errorMessage != null)
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withAlpha(26),
              border: Border.all(color: AppTheme.errorRed.withAlpha(77)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error, color: AppTheme.errorRed, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.errorRed,
                        ),
                  ),
                ),
              ],
            ),
          ),

        // Success Message
        if (successMessage != null)
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withAlpha(26),
              border: Border.all(color: AppTheme.successGreen.withAlpha(77)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle,
                    color: AppTheme.successGreen, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    successMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.successGreen,
                        ),
                  ),
                ),
              ],
            ),
          ),

        // Payment Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isProcessing ? null : onPaymentProcess,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGold,
              foregroundColor: AppTheme.textVariant,
              disabledBackgroundColor: AppTheme.inactiveGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppTheme.textVariant,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Processando...',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Finalizar Pagamento',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 16),

        // Terms and conditions
        Text(
          'Ao continuar, você concorda com nossos Termos de Uso e Política de Privacidade. O cancelamento pode ser feito a qualquer momento.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}