import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/user/error/user_error.dart';
import 'package:miti/user/model/my_payment_model.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_payment_screen.dart';

import '../../common/error/view/pay_error_screen.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/v2/payment/payment_result_response.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class UserPaymentDetailScreen extends StatelessWidget {
  final int paymentResultId;

  static String get routeName => 'myPaymentDetail';

  const UserPaymentDetailScreen({super.key, required this.paymentResultId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: '결제 내역 확인',
      ),
      bottomNavigationBar: BottomButton(
        hasBorder: false,
        button: TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('돌아가기'),
        ),
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref
              .watch(paymentDetailProvider(paymentResultId: paymentResultId));
          if (result is LoadingModel) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (result is ErrorModel) {
            UserError.fromModel(model: result)
                .responseError(context, UserApiType.paymentResultDetail, ref);
            return Text('error');
          }
          final model = (result as ResponseModel<PaymentResultResponse>).data!;
          final approvedAt = DateTimeUtil.parseDateTime(model.approvedAt);
          final String? canceledAt = model.canceledAt != null
              ? DateTimeUtil.parseDateTime(model.canceledAt!)
              : null;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 35.h,
                ),
                child: Column(
                  children: [
                    _PaymentSimpleInfoComponent.fromDetailModel(model: model),
                    SizedBox(height: 21.h),
                    _PaymentDateInfoComponent(
                      title: '결제 승인',
                      dateTime: approvedAt,
                    ),
                    SizedBox(height: 10.h),
                    _PaymentDateInfoComponent(
                      title: '결제 취소',
                      dateTime: canceledAt,
                    ),
                    SizedBox(height: 21.h),
                    _CancelInfoComponent.fromModel(model: model),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PaymentDateInfoComponent extends StatelessWidget {
  final String title;
  final String? dateTime;

  const _PaymentDateInfoComponent(
      {super.key, required this.title, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.xxsm.copyWith(
            color: MITIColor.white,
          ),
        ),
        Text(
          dateTime ?? '',
          style: MITITextStyle.xxsmLight150.copyWith(
            color: MITIColor.white,
          ),
        )
      ],
    );
  }
}

class _CancelInfoComponent extends StatelessWidget {
  final int total_amount;
  final int tax_free_amount;
  final int canceled_total_amount;
  final int canceled_tax_free_amount;

  const _CancelInfoComponent({
    super.key,
    required this.total_amount,
    required this.tax_free_amount,
    required this.canceled_total_amount,
    required this.canceled_tax_free_amount,
  });

  factory _CancelInfoComponent.fromModel(
      {required PaymentResultResponse model}) {
    return _CancelInfoComponent(
      total_amount: model.totalAmount,
      tax_free_amount: model.taxFreeAmount,
      canceled_total_amount: model.canceledTotalAmount ?? 0,
      canceled_tax_free_amount: model.canceledTaxFreeAmount ?? 0,
    );
  }

  Row getPayInfo(String idx, String title, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              idx,
              style: MITITextStyle.xxsmLight.copyWith(
                color: MITIColor.white,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              title,
              style: MITITextStyle.xxsmLight.copyWith(
                color: MITIColor.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              NumberUtil.format(amount.toString()),
              style: MITITextStyle.xxsm.copyWith(
                color: MITIColor.white,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '원',
              style: MITITextStyle.xxsmLight150.copyWith(
                color: MITIColor.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final finalAmount = total_amount - canceled_tax_free_amount;
    return Column(
      children: [
        getPayInfo('➀', '결제 금액', total_amount),
        SizedBox(height: 8.h),
        getPayInfo('②', '결제 비과세 금액', tax_free_amount),
        SizedBox(height: 8.h),
        getPayInfo('③', '결제 취소 금액', canceled_total_amount),
        SizedBox(height: 8.h),
        getPayInfo('④', '결제 취소 비과세 금액', canceled_tax_free_amount),
        Divider(
          height: 17.h,
          color: MITIColor.gray750,
        ),
        Row(
          children: [
            Text(
              '최종 결제 금액',
              style: MITITextStyle.sm150.copyWith(
                color: MITIColor.white,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              '➀ - ③',
              style: MITITextStyle.xxsm.copyWith(
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              NumberUtil.format(finalAmount.toString()),
              style: MITITextStyle.smSemiBold.copyWith(
                color: MITIColor.white,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '원',
              style: MITITextStyle.sm.copyWith(
                color: MITIColor.white,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _PaymentSimpleInfoComponent extends StatelessWidget {
  final int id;
  final ItemType itemType;
  final PaymentResultStatusType status;
  final PaymentMethodType paymentMethod;
  final int quantity;
  final String itemName;
  final int totalAmount;
  final int taxFreeAmount;
  final int? canceledTotalAmount;
  final int? canceledTaxFreeAmount;
  final String approvedAt;
  final String? canceledAt;

  const _PaymentSimpleInfoComponent({
    super.key,
    required this.id,
    required this.itemType,
    required this.status,
    required this.paymentMethod,
    required this.quantity,
    required this.itemName,
    required this.totalAmount,
    required this.taxFreeAmount,
    this.canceledTotalAmount,
    this.canceledTaxFreeAmount,
    required this.approvedAt,
    this.canceledAt,
  });

  factory _PaymentSimpleInfoComponent.fromDetailModel(
      {required PaymentResultResponse model}) {
    return _PaymentSimpleInfoComponent(
      id: model.id,
      itemType: model.itemType,
      status: model.status,
      paymentMethod: model.paymentMethod,
      quantity: model.quantity,
      itemName: model.itemName,
      totalAmount: model.totalAmount,
      taxFreeAmount: model.taxFreeAmount,
      canceledTotalAmount: model.canceledTotalAmount,
      canceledTaxFreeAmount: model.canceledTaxFreeAmount,
      approvedAt: model.approvedAt,
      canceledAt: model.canceledAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                itemType.value,
                style: MITITextStyle.xxsm.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                itemName,
                style: MITITextStyle.xxsm.copyWith(
                  color: MITIColor.gray100,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    paymentMethod.displayName,
                    style: MITITextStyle.xxsmLight.copyWith(
                      color: MITIColor.gray400,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      '|',
                      style: MITITextStyle.xxsmLight.copyWith(
                        color: MITIColor.gray400,
                      ),
                    ),
                  ),
                  Text(
                    status.name,
                    style: MITITextStyle.xxsmLight.copyWith(
                      color: MITIColor.gray400,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(width: 50.w),
        Text(
          totalAmount == 0
              ? '무료'
              : '${NumberUtil.format(totalAmount.toString())}원',
          style: MITITextStyle.lg.copyWith(
            color: MITIColor.gray100,
          ),
        )
      ],
    );
  }
}
