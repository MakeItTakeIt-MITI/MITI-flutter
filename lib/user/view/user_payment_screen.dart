import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/user/model/my_payment_model.dart';
import 'package:miti/user/view/user_payment_detail_screen.dart';
import 'package:miti/util/util.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../game/model/v2/payment/base_payment_result_response.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../component/skeleton/payment_card_skeleton.dart';
import '../param/user_profile_param.dart';
import '../provider/user_pagination_provider.dart';

class UserPaymentScreen extends ConsumerStatefulWidget {
  static String get routeName => 'myPayment';

  const UserPaymentScreen({super.key});

  @override
  ConsumerState<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends ConsumerState<UserPaymentScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider)!.id!;
    return Scaffold(
      backgroundColor: MITIColor.gray800,
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                isSliver: true,
                title: '결제 내역 확인',
                backgroundColor: MITIColor.gray800,
                hasBorder: false,
              )
            ];
          },
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              DisposeSliverPaginationListView(
                provider:
                    userPaymentPProvider(PaginationStateParam(path: userId)),
                itemBuilder: (BuildContext context, int index, Base pModel) {
                  pModel as BasePaymentResultResponse;

                  return GestureDetector(
                      onTap: () {
                        Map<String, String> pathParameters = {
                          'paymentResultId': pModel.id.toString()
                        };
                        context.pushNamed(
                          UserPaymentDetailScreen.routeName,
                          pathParameters: pathParameters,
                        );
                      },
                      child: PaymentCard.fromModel(model: pModel));
                },
                skeleton: const PaymentCardListSkeleton(),
                param: UserPaymentParam(),
                controller: _scrollController,
                separateSize: 0,
                emptyWidget: Container(
                  color: MITIColor.gray750,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '결제 내역이 없습니다.',
                        style: MITITextStyle.xxl140.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        '경기에 참여하고 내역을 확인할 수 있어요!',
                        style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final int id;
  final ItemType itemType;
  final PaymentResultStatusType status;
  final PaymentMethodType paymentMethod;
  final int quantity;
  final String itemName;
  final int totalAmount;
  final String approvedAt;

  const PaymentCard({
    super.key,
    required this.id,
    required this.status,
    required this.itemType,
    required this.paymentMethod,
    required this.approvedAt,
    required this.totalAmount,
    required this.itemName,
    required this.quantity,
  });

  factory PaymentCard.fromModel({required BasePaymentResultResponse model}) {
    return PaymentCard(
      id: model.id,
      status: model.status,
      itemType: model.itemType,
      paymentMethod: model.paymentMethod,
      approvedAt: model.approvedAt,
      totalAmount: model.totalAmount,
      itemName: model.itemName,
      quantity: model.quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTimeUtil.parseMd(dateTime: DateTime.parse(approvedAt));
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: MITIColor.gray700,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: MITITextStyle.xxsm.copyWith(
              color: MITIColor.gray400,
            ),
          ),
          SizedBox(width: 20.w),
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
      ),
    );
  }
}
