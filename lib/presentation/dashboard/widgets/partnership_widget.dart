import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PartnershipWidget extends StatelessWidget {
  const PartnershipWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.shadowBlack,
                  blurRadius: 8,
                  offset: Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: CustomIconWidget(
                    iconName: 'handshake',
                    color: AppTheme.accentGold,
                    size: 5.w)),
            SizedBox(width: 3.w),
            Text('Parceiros',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.accentGold, fontWeight: FontWeight.w600)),
          ]),
          SizedBox(height: 3.h),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.dividerGray, width: 1)),
              child: Column(children: [
                Text('',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 2.h),
                Container(
                    height: 8.h,
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                        color: AppTheme.primaryBlack,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Color(0xFFFF69B4).withValues(alpha: 0.3),
                            width: 1)),
                    child: Center(
                        child: CustomImageWidget(
                            imageUrl: 'assets/images/dont_eat.png', // Add required imageUrl parameter
                            height: 6.h, 
                            fit: BoxFit.contain))),
                SizedBox(height: 2.h),
                Text(
                    'Apoiando sua jornada fitness com soluções nutricionais premium',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center),
              ])),
        ]));
  }
}