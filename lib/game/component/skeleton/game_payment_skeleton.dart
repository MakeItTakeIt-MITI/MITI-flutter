import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/skeleton.dart';

import '../../../common/model/entity_enum.dart';
import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../view/game_payment_screen.dart';
import 'game_detail_skeleton.dart';

class GamePaymentSkeleton extends StatelessWidget {
  final int gameId;
  final PaymentMethodType payType;
  final AgreementRequestType type;

  const GamePaymentSkeleton({super.key, required this.type, required this.gameId, required this.payType});

  Widget getDivider() {
    return Container(
      height: 4.h,
      color: MITIColor.gray800,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SummarySkeleton(),
        getDivider(),
        const PaymentSkeleton(),
        // Column(
        //   children: [
        //     getDivider(),
        //     const PayWayButton(),
        //   ],
        // ),
        getDivider(),
        const PaymentAndRefundPolicyComponent(
          title: '결제 및 환불 정책', isPayment: true,
        ),
        getDivider(),
        // PaymentCheckForm(
        //   type: type, gameId: gameId,
        //   payType: payType,
        // ),
      ],
    );
  }
}

class PaymentSkeleton extends StatelessWidget {
  const PaymentSkeleton({super.key});

  Row getPayment({required String title, required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.sm.copyWith(
            color: MITIColor.gray100,
          ),
        ),
        BoxSkeleton(width: width, height: 14),
      ],
    );
  }

  Divider getDivider() {
    return Divider(
      color: MITIColor.gray700,
      height: 41.h,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '결제 및 할인 정보',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          getPayment(title: '경기 참여 비용', width: 57),
          Column(
            children: [
              SizedBox(height: 12.h),
              getPayment(title: '결제 수수료', width: 47),
            ],
          ),
          getDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 결제 금액',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              const BoxSkeleton(width: 72, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
