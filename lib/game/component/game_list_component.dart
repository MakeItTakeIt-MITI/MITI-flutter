import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/entity_enum.dart';
import '../../court/model/court_model.dart';
import '../model/game_model.dart';
import 'game_state_label.dart';

class GameCardByDate extends StatelessWidget {
  final String dateTime;
  final List<GameBaseModel> models;
  final int bottomIdx;

  const GameCardByDate(
      {super.key,
      required this.dateTime,
      required this.models,
      required this.bottomIdx});

  factory GameCardByDate.fromModel(
      {required GameListByDateModel model, required int bottomIdx}) {
    return GameCardByDate(
      dateTime: model.startdate,
      models: model.games,
      bottomIdx: bottomIdx,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateTime,
          style: MITITextStyle.sectionTitleStyle
              .copyWith(color: const Color(0xFF040000)),
        ),
        SizedBox(height: 10.h),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, idx) {
            return GameCard.fromModel(model: models[idx], bottomIdx: bottomIdx,);
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
  final CourtModel court;
  final int bottomIdx;

  const GameCard({
    super.key,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.court,
    required this.id, required this.bottomIdx,
  });

  factory GameCard.fromModel({required GameBaseModel model, required int bottomIdx}) {
    return GameCard(
      game_status: model.game_status,
      title: model.title,
      startdate: model.startdate,
      starttime: model.starttime,
      enddate: model.enddate,
      endtime: model.endtime,
      court: model.court,
      id: model.id, bottomIdx: bottomIdx,
    );
  }

  @override
  Widget build(BuildContext context) {
    final descStyle = MITITextStyle.courtAddressCardStyle.copyWith(
      color: const Color(0xFF999999),
    );

    final startTime = starttime.substring(0, 5);
    final endTime = endtime.substring(0, 5);
    return InkWell(
      onTap: () {
        Map<String, String> pathParameters = {'gameId': id.toString()};
        Map<String, String> queryParameters = {'bottomIdx': bottomIdx.toString()};
        context.pushNamed(GameDetailScreen.routeName,
            pathParameters: pathParameters, queryParameters: queryParameters);
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
            Expanded(
              child: Column(
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
                    style: MITITextStyle.gameTitleCardLStyle.copyWith(
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${court.address} ${court.address_detail ?? ''}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: descStyle,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    startdate == enddate
                        ? '$startTime ~ $endTime'
                        : '$startdate $startTime ~ $enddate $endTime',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: descStyle,
                  ),
                ],
              ),
            ),
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
