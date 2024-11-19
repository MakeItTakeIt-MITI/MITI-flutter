import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/user/model/my_payment_model.dart';
import 'package:miti/util/util.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
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
                  pModel as MyPaymentModel;

                  return _PaymentCard.fromModel(model: pModel);
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

class _PaymentCard extends StatelessWidget {
  final int id;
  final PaymentResultType status;
  final ItemType item_type;
  final PaymentMethodType payment_method;
  final String item_name;
  final int total_amount;
  final int tax_free_amount;
  final int? canceled_total_amount;
  final int? canceled_tax_free_amount;
  final PaymentCancelType? cancelation_reason;
  final String approved_at;
  final String? canceled_at;

  const _PaymentCard({
    super.key,
    required this.id,
    required this.status,
    required this.item_type,
    required this.payment_method,
    required this.item_name,
    required this.total_amount,
    required this.tax_free_amount,
    this.canceled_total_amount,
    this.canceled_tax_free_amount,
    this.cancelation_reason,
    required this.approved_at,
    this.canceled_at,
  });

  factory _PaymentCard.fromModel({required MyPaymentModel model}) {
    return _PaymentCard(
      id: model.id,
      status: model.status,
      item_type: model.item_type,
      payment_method: model.payment_method,
      cancelation_reason: model.cancelation_reason,
      approved_at: model.approved_at,
      total_amount: model.total_amount,
      item_name: model.item_name,
      tax_free_amount: model.tax_free_amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTimeUtil.parseMd(dateTime: DateTime.parse(approved_at));
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
                  '참여 비용',
                  style: MITITextStyle.xxsm.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item_name,
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
                      payment_method.displayName,
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
                      status.displayName,
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
            total_amount == 0
                ? '무료'
                : '${NumberUtil.format(total_amount.toString())}원',
            style: MITITextStyle.lg.copyWith(
              color: MITIColor.gray100,
            ),
          )
        ],
      ),
    );
  }
}
