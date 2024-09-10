import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/account/model/account_model.dart';
import 'package:miti/account/provider/account_provider.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/entity_enum.dart';
import '../../game/view/game_detail_screen.dart';
import '../../theme/color_theme.dart';
import '../../util/util.dart';

class SettlementDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'settlementDetail';
  final int settlementId;

  const SettlementDetailScreen({super.key, required this.settlementId});

  @override
  ConsumerState<SettlementDetailScreen> createState() =>
      _SettlementDetailScreenState();
}

class _SettlementDetailScreenState
    extends ConsumerState<SettlementDetailScreen> {
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

  Widget getDivider() {
    return Container(
      height: 8.h,
      color: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray900,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '경기 정산 상세 내역',
              backgroundColor: MITIColor.gray750,
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
                      settlementId: widget.settlementId, userId: userId));
                  if (result is LoadingModel) {
                    return CircularProgressIndicator();
                  } else if (result is ErrorModel) {
                    AccountError.fromModel(model: result).responseError(
                        context, AccountApiType.getSettlementInfo, ref);
                    return Text('에러');
                  }
                  final model =
                      (result as ResponseModel<SettlementDetailModel>).data!;
                  return Column(
                    children: [
                      SettlementCard.fromModel(model: model),
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
      ),
    );
  }
}

class SettlementCard extends StatelessWidget {
  final int id;
  final String title;
  final String datetime;
  final String address;
  final String expected_settlement_amount;
  final SettlementType status;

  const SettlementCard({
    super.key,
    required this.title,
    required this.datetime,
    required this.address,
    required this.id,
    required this.expected_settlement_amount,
    required this.status,
  });

  factory SettlementCard.fromModel({
    required SettlementDetailModel model,
  }) {
    final game = model.game;

    final st = DateTime.parse(game.startdate);
    final et = DateTime.parse(game.startdate);
    final fe = DateFormat('yyyy년 MM월 dd일 (E)', 'ko');

    final startDate = fe.format(st);
    final endDate = fe.format(et);
    final period = game.startdate == game.enddate
        ? "$startDate ${game.starttime.substring(0, 5)}~${game.endtime.substring(0, 5)}"
        : "$startDate ${game.starttime.substring(0, 5)} ~\n$endDate ${game.endtime.substring(0, 5)}";
    return SettlementCard(
      title: game.title,
      datetime: period,
      address: '${game.court.address} ${game.court.address_detail ?? ''}',
      id: model.id,
      expected_settlement_amount: model.expectedSettlementAmount == 0
          ? '무료'
          : NumberUtil.format(model.expectedSettlementAmount.toString()),
      status: model.status,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 20.h, bottom: 24.h),
      color: MITIColor.gray750,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MITITextStyle.mdSemiBold150.copyWith(
              color: MITIColor.gray100,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20.h),
          settlementInfo(datetime),
          SizedBox(height: 8.h),
          settlementInfo(address),
          SizedBox(height: 36.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SettlementLabel(settlementType: status),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '총 정산 금액',
                    style: MITITextStyle.xxsmLight
                        .copyWith(color: MITIColor.gray100),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$expected_settlement_amount 원',
                    style: MITITextStyle.xl.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Row settlementInfo(String desc) {
    return Row(
      children: [
        Text(
          '-',
          style: MITITextStyle.xxsmLight.copyWith(color: MITIColor.gray400),
        ),
        SizedBox(width: 8.w),
        Text(
          desc,
          style: MITITextStyle.xxsmLight.copyWith(color: MITIColor.gray400),
        ),
      ],
    );
  }
}

class _SettlementComponent extends StatelessWidget {
  final String amount;
  final String commission;
  final String settlementAmount;

  const _SettlementComponent({
    super.key,
    required this.amount,
    required this.commission,
    required this.settlementAmount,
  });

  factory _SettlementComponent.fromModel(
      {required SettlementDetailModel model}) {
    return _SettlementComponent(
      amount: NumberUtil.format(model.amount.toString()),
      commission: NumberUtil.format(model.commission.toString()),
      settlementAmount: NumberUtil.format(model.settlementAmount.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MITIColor.gray750,
      padding:
          EdgeInsets.only(left: 21.w, right: 21.w, top: 24.h, bottom: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '정산 정보',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '경기 참여 비용',
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              Text(
                "₩ $amount",
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '정산 수수료',
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              Text(
                "- ₩ $commission",
                style: MITITextStyle.sm.copyWith(
                  color: MITIColor.error,
                ),
              ),
            ],
          ),
          Divider(height: 41.h, color: MITIColor.gray600),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 정산 금액',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              Text(
                '₩ $settlementAmount',
                style: MITITextStyle.mdBold.copyWith(
                  color: MITIColor.gray100,
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
    return Container(
      color: MITIColor.gray750,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 24.h,
              left: 21.w,
              right: 21.w,
              bottom: 20.h,
            ),
            child: Text(
              '참여자 정산 정보',
              style: MITITextStyle.mdBold.copyWith(
                color: MITIColor.gray100,
              ),
            ),
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
                  color: MITIColor.gray600,
                );
              },
              itemCount: participations.length),
        ],
      ),
    );
  }
}

class _ParticipationCard extends StatelessWidget {
  final ParticipationModel model;

  const _ParticipationCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final fee = NumberUtil.format(model.fee.toString());
    final settlementType =
        model.is_settled ? SettlementType.completed : SettlementType.waiting;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 21.w,
        vertical: 20.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SettlementLabel(settlementType: settlementType),
          const Spacer(),
          Text(
            model.nickname,
            style: MITITextStyle.sm.copyWith(
              color: MITIColor.gray100,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: 20.w),
          Text(
            "₩ $fee",
            style: MITITextStyle.sm.copyWith(
              color: MITIColor.gray100,
            ),
          ),
        ],
      ),
    );
  }
}
