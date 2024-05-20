import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/account/model/account_model.dart';
import 'package:miti/account/provider/account_provider.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/entity_enum.dart';
import '../../game/view/game_detail_screen.dart';
import '../../util/util.dart';

class SettlementDetailScreen extends StatelessWidget {
  static String get routeName => 'settlementDetail';
  final int settlementId;

  const SettlementDetailScreen({super.key, required this.settlementId});

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
            title: '정산 내역',
          ),
        ];
      }),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final userId = ref.watch(authProvider)!.id!;
                final result = ref.watch(settlementProvider(
                    settlementId: settlementId, userId: userId));
                if (result is LoadingModel) {
                  return CircularProgressIndicator();
                } else if (result is ErrorModel) {
                  return Text('에러');
                }
                final model =
                    (result as ResponseModel<SettlementDetailModel>).data!;
                return Column(
                  children: [
                    SummaryComponent.fromSettlementModel(model: model),
                    getDivider(),
                    _SettlementComponent.fromModel(model: model),
                    getDivider(),
                    _ParticipationComponent.fromModel(model: model),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _SettlementComponent extends StatelessWidget {
  final String amount;
  final String commission;
  final String final_settlement_amount;

  const _SettlementComponent(
      {super.key,
      required this.amount,
      required this.commission,
      required this.final_settlement_amount});

  factory _SettlementComponent.fromModel(
      {required SettlementDetailModel model}) {
    return _SettlementComponent(
      amount: NumberUtil.format(model.amount.toString()),
      commission: NumberUtil.format(model.commission.toString()),
      final_settlement_amount:
          NumberUtil.format(model.final_settlement_amount.toString()),
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
            '정산 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '경기 참여비',
                style: MITITextStyle.plainTextMStyle.copyWith(
                  color: const Color(0xff666666),
                ),
              ),
              Text(
                "₩ $amount",
                style: MITITextStyle.feeSStyle.copyWith(
                  color: const Color(0xff333333),
                ),
              ),
            ],
          ),
          Divider(height: 25.h, color: const Color(0xFFE8E8E8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '정산 수수료',
                style: MITITextStyle.plainTextMStyle.copyWith(
                  color: const Color(0xff666666),
                ),
              ),
              Text(
                "₩ $commission",
                style: MITITextStyle.feeSStyle.copyWith(
                  color: const Color(0xff333333),
                ),
              ),
            ],
          ),
          Divider(height: 25.h, color: const Color(0xFFE8E8E8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 정산 금액',
                style: MITITextStyle.gameTitleMainStyle.copyWith(
                  color: const Color(0xff222222),
                ),
              ),
              Text(
                "₩ $final_settlement_amount",
                style: MITITextStyle.feeStyle.copyWith(
                  color: const Color(0xfff45858),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParticipationComponent extends StatelessWidget {
  final List<ParticipationModel> participations;

  const _ParticipationComponent({super.key, required this.participations});

  factory _ParticipationComponent.fromModel(
      {required SettlementDetailModel model}) {
    return _ParticipationComponent(
      participations: model.participations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 12.h,
            left: 12.w,
            right: 12.w,
            bottom: 20.h,
          ),
          child: Text(
            '참여자 정산 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
        ),
        if (participations.isNotEmpty)
          const Divider(
            color: Color(0xFFE8E8E8),
          ),
        ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (_, idx) {
              return _ParticipationCard(
                model: participations[idx],
              );
            },
            separatorBuilder: (_, idx) {
              return const Divider(
                color: Color(0xFFE8E8E8),
              );
            },
            itemCount: participations.length),
      ],
    );
  }
}

class _ParticipationCard extends StatelessWidget {
  final ParticipationModel model;

  const _ParticipationCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final fee = NumberUtil.format(model.fee.toString());
    final bankType = model.is_settled
        ? SettlementType.completed
        : SettlementType.waiting;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 15.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 87.w,
            child: Text(
              '${model.nickname}',
              style: MITITextStyle.inputLabelDStyle.copyWith(
                color: const Color(0xff999999),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 130.w,
            child: Text(
              "₩ $fee",
              style: MITITextStyle.feeStyle.copyWith(
                color: const Color(0xff4065f5),
              ),
            ),
          ),
          SettlementLabel(bankType: bankType),
        ],
      ),
    );
  }
}
