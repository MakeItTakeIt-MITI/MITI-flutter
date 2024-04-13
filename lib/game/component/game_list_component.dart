import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/view/game_detail_screen.dart';

import '../../common/model/entity_enum.dart';
import '../../court/model/court_model.dart';
import '../model/game_model.dart';
import 'game_state_label.dart';

class GameCardByDate extends StatelessWidget {
  final String dateTime;
  final List<GameModel> models;

  const GameCardByDate(
      {super.key, required this.dateTime, required this.models});

  factory GameCardByDate.fromModel({required GameListByDateModel model}) {
    return GameCardByDate(
      dateTime: model.datetime,
      models: model.models,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateTime,
          style: TextStyle(
            color: const Color(0xFF040000),
            fontSize: 12.sp,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25.sp,
          ),
        ),
        SizedBox(height: 10.h),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, idx) {
            return GameCard.fromModel(model: models[idx]);
          },
          separatorBuilder: (_, idx) {
            return SizedBox(height: 10.h);
          },
          itemCount: models.length,
        ),
      ],
    );
  }
}

class GameCard extends StatelessWidget {
  final int id;
  final GameStatus game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final int fee;
  final CourtModel court;

  const GameCard({
    super.key,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.fee,
    required this.court,
    required this.id,
  });

  factory GameCard.fromModel({required GameModel model}) {
    return GameCard(
      game_status: model.game_status,
      title: model.title,
      startdate: model.startdate,
      starttime: model.starttime,
      enddate: model.enddate,
      endtime: model.endtime,
      fee: model.fee,
      court: model.court,
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final descStyle = TextStyle(
      color: const Color(0xFF999999),
      fontSize: 12.sp,
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.w500,
      letterSpacing: -0.25.sp,
    );
    return InkWell(
      onTap: () {
        Map<String, String> pathParameters = {'gameId': id.toString()};
        context.pushNamed(GameDetailScreen.routeName,
            pathParameters: pathParameters);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE8E8E8))),
        padding: EdgeInsets.all(8.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameStateLabel(
                  gameStatus: game_status,
                ),
                SizedBox(height: 6.h),
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.25.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '${court.address} ${court.address_detail}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: descStyle,
                ),
                SizedBox(height: 2.h),
                Text(
                  startdate == enddate
                      ? '$starttime ~ $endtime'
                      : '$startdate $starttime ~ $enddate $endtime',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: descStyle,
                ),
              ],
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/images/icon/chevron_right.svg',
              height: 14.h,
              width: 7.w,
            ),
          ],
        ),
      ),
    );
  }
}
