import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/user/view/user_payment_detail_screen.dart';
import 'package:miti/util/util.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/dispose_sliver_cursor_pagination_list_view.dart';
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
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                isSliver: true,
                title: '결제 내역 확인',
                hasBorder: true,
              )
            ];
          },
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              DisposeSliverCursorPaginationListView(
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
                      child: _PaymentCard.fromModel(model: pModel));
                },
                skeleton: const PaymentCardListSkeleton(),
                param: UserPaymentParam(),
                controller: _scrollController,
                separateSize: 0,
                separatorWidget: Divider(height: 16.h, color: V2MITIColor.gray10,),
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

class _PaymentCard extends StatelessWidget {
  final int id;
  final PaymentResultStatusType status;
  final ItemType itemType;
  final String itemName;
  final PaymentMethodType paymentMethod;
  final int finalAmount;
  final DateTime createdAt;
  final DateTime approvedAt;

  const _PaymentCard({
    super.key,
    required this.id,
    required this.status,
    required this.itemType,
    required this.itemName,
    required this.paymentMethod,
    required this.finalAmount,
    required this.createdAt,
    required this.approvedAt,
  });

  factory _PaymentCard.fromModel({required BasePaymentResultResponse model}) {
    return _PaymentCard(
      id: model.id,
      status: model.status,
      itemType: model.itemType,
      itemName: model.itemName,
      paymentMethod: model.paymentMethod,
      finalAmount: model.finalAmount,
      createdAt: model.createdAt,
      approvedAt: model.approvedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTimeUtil.parseMd(dateTime: approvedAt);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: V2MITITextStyle.tinyMediumTight.copyWith(
              color: V2MITIColor.gray5,
            ),
          ),
          SizedBox(width: 20.w),
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
                SizedBox(height: 4.h),
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
          Text(
            finalAmount == 0
                ? '무료'
                : '${NumberUtil.format(finalAmount.toString())}원',
            style: V2MITITextStyle.largeMediumTight.copyWith(
              color: V2MITIColor.gray1,
            ),
          )
        ],
      ),
    );
  }
}
