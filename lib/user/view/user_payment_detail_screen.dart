import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/user/error/user_error.dart';
import 'package:miti/user/provider/user_provider.dart';

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
        hasBorder: false,
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
            return const Text('error');
          }
          final model = (result as ResponseModel<PaymentResultResponse>).data!;

          final approvedAt = model.approvedAt != null
              ? DateTimeUtil.formatDateTimeToString(model.approvedAt!.toLocal())
              : null;
          final String? canceledAt = model.canceledAt != null
              ? DateTimeUtil.formatDateTimeToString(model.canceledAt!.toLocal())
              : null;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                child: Column(
                  spacing: 16.h,
                  children: [
                    _PaymentSimpleInfoComponent.fromDetailModel(model: model),
                    if (approvedAt != null || canceledAt != null)
                      Column(
                        spacing: 10.h,
                        children: [
                          if (approvedAt != null)
                            _PaymentDateInfoComponent(
                              title: '결제 승인',
                              dateTime: approvedAt,
                            ),
                          if (canceledAt != null)
                            _PaymentDateInfoComponent(
                              title: '결제 취소',
                              dateTime: canceledAt,
                            ),
                        ],
                      ),
                    _PaymentInfoComponent.fromModel(model: model),
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
          style: V2MITITextStyle.tinyMediumTight.copyWith(
            color: V2MITIColor.white,
          ),
        ),
        Text(
          dateTime ?? '',
          style: V2MITITextStyle.tinyRegularTight.copyWith(
            color: V2MITIColor.white,
          ),
        )
      ],
    );
  }
}

class _PaymentInfoComponent extends StatelessWidget {
  final int? originAmount;
  final int discountAmount;
  final int finalAmount;
  final int canceledFinalAmount;

  const _PaymentInfoComponent({
    super.key,
    required this.originAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.canceledFinalAmount,
  });

  factory _PaymentInfoComponent.fromModel(
      {required PaymentResultResponse model}) {
    return _PaymentInfoComponent(
      originAmount: model.originAmount,
      discountAmount: model.discountAmount ?? 0,
      finalAmount: model.finalAmount,
      canceledFinalAmount: model.canceledFinalAmount ?? 0,
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
              style: V2MITITextStyle.tinyRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              title,
              style: V2MITITextStyle.tinyRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              NumberUtil.format(amount.toString()),
              style: V2MITITextStyle.tinyMediumTight.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '원',
              style: V2MITITextStyle.tinyRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          spacing: 8.h,
          children: [
            getPayInfo('➀', '상품 금액', originAmount ?? 0),
            getPayInfo('②', '할인 금액', discountAmount),
            getPayInfo('③', '결제 금액', finalAmount),
            getPayInfo('④', '결제 취소 금액', canceledFinalAmount),
          ],
        ),
        Divider(height: 16.h, color: V2MITIColor.gray10),
        Row(
          children: [
            Text(
              '최종 결제 금액',
              style: V2MITITextStyle.smallRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              '③ - ④',
              style: V2MITITextStyle.tinyRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            const Spacer(),
            Text(
              NumberUtil.format((finalAmount - canceledFinalAmount).toString()),
              style: V2MITITextStyle.smallMediumTight.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              '원',
              style: V2MITITextStyle.smallRegularTight.copyWith(
                color: V2MITIColor.white,
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
  final String itemName;
  final int totalAmount;
  final int taxFreeAmount;
  final int? canceledTotalAmount;
  final int? canceledTaxFreeAmount;

  const _PaymentSimpleInfoComponent({
    super.key,
    required this.id,
    required this.itemType,
    required this.status,
    required this.paymentMethod,
    required this.itemName,
    required this.totalAmount,
    required this.taxFreeAmount,
    this.canceledTotalAmount,
    this.canceledTaxFreeAmount,
  });

  factory _PaymentSimpleInfoComponent.fromDetailModel(
      {required PaymentResultResponse model}) {
    return _PaymentSimpleInfoComponent(
      id: model.id,
      itemType: model.itemType,
      status: model.status,
      paymentMethod: model.paymentMethod,
      itemName: model.itemName,
      totalAmount: model.finalAmount,
      taxFreeAmount: model.taxFreeAmount,
      canceledTotalAmount: model.canceledFinalAmount,
      canceledTaxFreeAmount: model.canceledVatAmount,
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
                style: V2MITITextStyle.tinyMediumTight.copyWith(
                  color: V2MITIColor.gray1,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                itemName,
                style: V2MITITextStyle.regularMediumTight.copyWith(
                  color: V2MITIColor.gray1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    paymentMethod.displayName,
                    style: V2MITITextStyle.tinyRegular.copyWith(
                      color: V2MITIColor.gray5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      '|',
                      style: V2MITITextStyle.tinyRegular.copyWith(
                        color: V2MITIColor.gray5,
                      ),
                    ),
                  ),
                  Text(
                    status.name,
                    style: V2MITITextStyle.tinyRegular.copyWith(
                      color: V2MITIColor.gray5,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
