import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/component/game_state_label.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/provider/game_provider.dart';

import '../../common/model/entity_enum.dart';
import '../../util/util.dart';

class GameDetailScreen extends StatelessWidget {
  static String get routeName => 'gameDetail';
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          DefaultAppBar(
            title: '경기 상세',
            isSliver: true,
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
              )
            ],
          ),
        ];
      }, body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final result = ref.watch(gameDetailProvider(gameId: gameId));

          if (result is LoadingModel) { // todo skeleton
            return CustomScrollView(
              slivers: [],
            );
          }
          result as ResponseModel<GameDetailModel>;
          final model = result.data!;
          return CustomScrollView(
            slivers: [
              getDivider(),
              SliverToBoxAdapter(
                child: _SummaryComponent.fromModel(model: model),
              ),
              getDivider(),
              SliverToBoxAdapter(
                  child: ParticipationComponent.fromModel(model: model)),
              getDivider(),
            ],
          );
        },
      )),
    );
  }

  SliverToBoxAdapter getDivider() {
    return SliverToBoxAdapter(
      child: Container(
        height: 10.h,
        color: const Color(0xFFF8F8F8),
      ),
    );
  }
}

class HostComponent extends StatelessWidget {
  final String imageUrl;

  const HostComponent({super.key, required this.imageUrl});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      child: Column(
        children: [
          Text(
            "호스트 소개",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff222222),
              height: 18 / 16,
            ),
          ),
          SizedBox(height: 19.h),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 20.r,
              ),
              SizedBox(width: 10.w),
              Column(
                children: [
                  Row(
                    children: [],
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 19.h),
        ],
      ),
    );
  }
}

class ParticipationComponent extends StatelessWidget {
  final int max_invitation;
  final int num_of_confirmed_participations;
  final List<ConfirmedParticipationModel> confimed_participations;

  const ParticipationComponent(
      {super.key,
      required this.confimed_participations,
      required this.max_invitation,
      required this.num_of_confirmed_participations});

  factory ParticipationComponent.fromModel({required GameDetailModel model}) {
    return ParticipationComponent(
      confimed_participations: model.confimed_participations,
      max_invitation: model.max_invitation,
      num_of_confirmed_participations: model.num_of_confirmed_participations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "참가 완료된 게스트 ($num_of_confirmed_participations/$max_invitation)",
            style: TextStyle(
              fontFamily: "Pretendard",
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xff222222),
              letterSpacing: -0.25.sp,
              height: 16 / 14,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 16.h),
          if (confimed_participations.isNotEmpty)
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (_, idx) {
                  return _GuestTile(
                    name: confimed_participations[idx].user.nickname,
                    imageUrl: '',
                  );
                },
                separatorBuilder: (_, __) {
                  return SizedBox(width: 16.w);
                },
                itemCount: confimed_participations.length),
          if (confimed_participations.isEmpty)
            Text(
              "모집된 게스트가 없습니다.",
              style: TextStyle(
                fontFamily: "Pretendard",
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xff222222),
                letterSpacing: -0.25.sp,
                height: 16 / 14,
              ),
              textAlign: TextAlign.center,
            )
        ],
      ),
    );
  }
}

class _GuestTile extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _GuestTile({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 20.r,
        ),
        SizedBox(height: 4.h),
        Text(
          "$name 님",
          style: TextStyle(
            fontFamily: "Pretendard",
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xff666666),
            letterSpacing: -0.25.sp,
            height: 20 / 14,
          ),
        )
      ],
    );
  }
}

class _SummaryComponent extends StatelessWidget {
  final GameStatus gameStatus;
  final String title;
  final String gameDate;
  final String address;
  final String fee;
  final int max_invitation;
  final int num_of_confirmed_participations;

  const _SummaryComponent(
      {super.key,
      required this.gameStatus,
      required this.title,
      required this.gameDate,
      required this.address,
      required this.fee,
      required this.max_invitation,
      required this.num_of_confirmed_participations});

  factory _SummaryComponent.fromModel({required GameDetailModel model}) {
    final startDate = model.startdate.replaceAll('-', '. ');
    final endDate = model.startdate.replaceAll('-', '. ');

    final time =
        '${model.starttime.substring(0, 5)} ~ ${model.endtime.substring(0, 5)}';
    final gameDate = startDate == endDate
        ? '$startDate $time'
        : '$startDate ${model.starttime.substring(0, 5)} ~ $endDate ${model.endtime.substring(0, 5)}';
    final address = '${model.court.address} ${model.court.address_detail}';
    return _SummaryComponent(
      gameStatus: model.game_status,
      title: model.title,
      gameDate: gameDate,
      address: address,
      fee: NumberUtil.format(model.fee.toString()),
      max_invitation: model.max_invitation,
      num_of_confirmed_participations: model.num_of_confirmed_participations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameStateLabel(gameStatus: gameStatus),
              SizedBox(height: 13.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff222222),
                  letterSpacing: -0.25.sp,
                  height: 18 / 16,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                gameDate,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff999999),
                  letterSpacing: -0.25.sp,
                  height: 16 / 14,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 13.h),
              Row(children: [
                SvgPicture.asset('assets/images/icon/map_pin.svg'),
                SizedBox(width: 4.w),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff444444),
                    letterSpacing: -0.25.sp,
                    height: 16 / 14,
                  ),
                  textAlign: TextAlign.left,
                )
              ]),
              SizedBox(height: 4.h),
              Row(children: [
                SvgPicture.asset('assets/images/icon/people.svg'),
                SizedBox(width: 4.w),
                Text(
                  "총 $num_of_confirmed_participations명 중 $max_invitation명 모집 완료",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xff444444),
                    letterSpacing: -0.25.sp,
                    height: 16 / 14,
                  ),
                  textAlign: TextAlign.left,
                )
              ]),

              SizedBox(height: 13.h),
              Text(
                "₩ $fee",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff4065f6),
                  letterSpacing: -0.25.sp,
                  height: 18 / 16,
                ),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ],
      ),
    );
  }
}
