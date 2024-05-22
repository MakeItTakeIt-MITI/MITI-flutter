import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/model/game_payment_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/view/game_refund_screen.dart';
import 'package:miti/kakaopay/error/pay_error.dart';
import 'package:miti/kakaopay/model/pay_model.dart';
import 'package:miti/kakaopay/provider/pay_provider.dart';
import 'package:miti/theme/text_theme.dart';

import '../../kakaopay/view/payment_screen.dart';
import 'game_detail_screen.dart';

class GamePaymentScreen extends StatelessWidget {
  static String get routeName => 'paymentInfo';
  final int gameId;

  const GamePaymentScreen({super.key, required this.gameId});

  Widget getDivider() {
    return Container(
      height: 5.h,
      color: const Color(0xFFF8F8F8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
        return [
          const DefaultAppBar(
            isSliver: true,
            title: '경기 상세',
          ),
        ];
      }),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Stack(
              children: [
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final result = ref.watch(paymentProvider(gameId: gameId));
                    if (result is LoadingModel) {
                      return CircularProgressIndicator();
                    } else if (result is ErrorModel) {
                      return Text('에러');
                    }
                    final model =
                        (result as ResponseModel<GamePaymentModel>).data!;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SummaryComponent.fromPaymentModel(model: model),
                          InfoComponent(
                            info: model.info,
                          ),
                          getDivider(),
                          PaymentComponent.fromModel(
                              model: model.payment_information),
                          getDivider(),
                          const PayWayButton(),
                          getDivider(),
                          const _PaymentAndRefundPolicyComponent(),
                          SizedBox(height: 60.h),
                        ],
                      ),
                    );
                  },
                ),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final valid = ref.watch(checkProvider(1)) &&
                        ref.watch(checkProvider(2));
                    return Positioned(
                      bottom: 8.h,
                      right: 16.w,
                      left: 16.w,
                      child: TextButton(
                        onPressed: valid
                            ? () async {
                                await onPay(ref, context);
                              }
                            : () {},
                        style: TextButton.styleFrom(
                          fixedSize: Size(double.infinity, 48.h),
                          backgroundColor: valid
                              ? const Color(0xFF4065F5)
                              : const Color(0xffE8E8E8),
                        ),
                        child: Text(
                          '결제하기',
                          style: MITITextStyle.btnTextBStyle.copyWith(
                            color:
                                valid ? Colors.white : const Color(0xff969696),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onPay(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(readyPayProvider(gameId: gameId).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        PayError.fromModel(model: result)
            .responseError(context, PayApiType.ready, ref);
      } else {
        result as ResponseModel<PayReadyModel>;
        final pathParameters = {'gameId': gameId.toString()};
        final queryParameters = {
          'redirectUrl': result.data!.next_redirect_mobile_url
        };
        context.pushNamed(
          PaymentScreen.routeName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
      }
    }
  }
}

class PaymentComponent extends StatelessWidget {
  final String game_fee_amount;
  final String commission_amount;
  final String vat_amount;
  final String totalAmount;
  final String promotion_amount;
  final String final_payment_amount;

  const PaymentComponent(
      {super.key,
      required this.game_fee_amount,
      required this.commission_amount,
      required this.vat_amount,
      required this.totalAmount,
      required this.promotion_amount,
      required this.final_payment_amount});

  factory PaymentComponent.fromModel({required PaymentModel model}) {
    final payment = model.payment_amount;
    final game_fee_amount =
        NumberFormat.decimalPattern().format(payment.game_fee_amount);
    final miti_commission_amount =
        NumberFormat.decimalPattern().format(payment.commission_amount);
    final vat_amount = NumberFormat.decimalPattern().format(payment.vat_amount);
    final totalAmount =
        NumberFormat.decimalPattern().format(payment.total_amount);
    final promotion_amount = NumberFormat.decimalPattern()
        .format(model.discount_amount.promotion_amount);
    final final_payment_amount =
        NumberFormat.decimalPattern().format(model.final_payment_amount);
    return PaymentComponent(
      game_fee_amount: game_fee_amount,
      commission_amount: miti_commission_amount,
      vat_amount: vat_amount,
      totalAmount: totalAmount,
      promotion_amount: promotion_amount,
      final_payment_amount: final_payment_amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '결제 및 할인 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 14.h),
          getPayment(title: '경기 참여비', fee: game_fee_amount),
          getDivider(),
          getPayment(title: '결제 수수료', fee: commission_amount),
          SizedBox(height: 12.h),
          getPayment(title: 'VAT', fee: vat_amount),
          getDivider(),
          getPayment(
            title: '할인',
            fee: promotion_amount,
            color: const Color(0xFF4065F5),
          ),
          getDivider(),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 결제 금액',
                style: MITITextStyle.gameTitleMainStyle.copyWith(
                  color: const Color(0xFF222222),
                ),
              ),
              Text(
                '₩ $final_payment_amount',
                style: MITITextStyle.feeStyle.copyWith(
                  color: const Color(0xFFF45858),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row getPayment({required String title, required String fee, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.plainTextMStyle.copyWith(
            color: color ?? const Color(0xFF666666),
          ),
        ),
        Text(
          '₩ $fee',
          style: MITITextStyle.feeSStyle.copyWith(
            color: color ?? const Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Divider getDivider() {
    return Divider(
      color: const Color(0xFFE8E8E8),
      height: 25.h,
    );
  }
}

class PayWayButton extends ConsumerWidget {
  const PayWayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(checkProvider(1));
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '결제 수단',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 48.h,
            child: TextButton(
              onPressed: () {
                ref.read(checkProvider(1).notifier).update((state) => !state);
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    selected ? const Color(0xFFFFF100) : Colors.white,
                fixedSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: selected
                        ? const Color(0xFFFFF100)
                        : const Color(0xFFE8E8E8),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.r)),
                ),
              ),
              child: SvgPicture.asset(
                'assets/images/icon/kakao_pay.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentAndRefundPolicyComponent extends StatelessWidget {
  const _PaymentAndRefundPolicyComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '결제 및 환불 정책',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            '참여 취소 환불 수수료 정책',
            style: MITITextStyle.sectionSubTitleStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            '• 경기 시작 48시간 전 : 무료취소',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 24시간 전 : 80% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 12시간 전 : 60% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 6시간 전 : 40% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 2시간 전 : 20% 환급',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 경기 시작 2시간 이내인 경기에 참여할 경우 참여 취소가 불가능하니 유의해주세요!',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xffE92C2C),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            '모집 실패로 인한 환불',
            style: MITITextStyle.sectionSubTitleStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            '• 경기 시작전까지 최소 모집 인원이 모집되지 않은경우 해당 경기는 취소됩니다.',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          Text(
            '• 모집 실패로 인한 경기 취소시, 결제한 금액은 자동 환불처리되며 포인트 및 할인을 제외한 금액이 환불됩니다.',
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff1c1c1c),
            ),
          ),
          SizedBox(height: 14.h),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final selected = ref.watch(checkProvider(2));
              return InkWell(
                onTap: () {
                  ref.read(checkProvider(2).notifier).update((state) => !state);
                },
                child: Row(
                  children: [
                    Text(
                      '결제 및 환불 정책을 확인하였으며, 동의합니다.',
                      style: MITITextStyle.gameTitleMainStyle.copyWith(
                        color: selected
                            ? const Color(0xff4065f5)
                            : const Color(0xFF666666),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    SvgPicture.asset(
                      'assets/images/icon/system_success.svg',
                      colorFilter: ColorFilter.mode(
                          selected
                              ? const Color(0xFF4065F5)
                              : const Color(0xFF666666),
                          BlendMode.srcIn),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
