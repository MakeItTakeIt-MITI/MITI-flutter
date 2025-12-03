import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../common/model/entity_enum.dart';
import '../model/v2/game/base_game_response.dart';
import 'game_state_label.dart';

class GameCardByDate extends StatelessWidget {
  final List<BaseGameResponse> model;

  const GameCardByDate({
    super.key,
    required this.model,
  });

  factory GameCardByDate.fromModel({required List<BaseGameResponse> model}) {
    return GameCardByDate(
      model: model,
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(model.first.startDate);
    final formatDate = DateFormat('yyyy년 MM월 dd일 (EEE', "ko").format(date);
    return Column(
      spacing: 12.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$formatDate요일)",
          style: V2MITITextStyle.smallMediumNormal
              .copyWith(color: V2MITIColor.white),
        ),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, idx) {
            return GameCard.fromModel(
              model: model[idx],
            );
          },
          separatorBuilder: (_, idx) {
            return SizedBox(height: 12.h);
          },
          itemCount: model.length,
        ),
      ],
    );
  }
}

class GameCard extends StatelessWidget {
  final int id;
  final GameStatusType game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;

  const GameCard({
    super.key,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.id,
  });

  factory GameCard.fromModel({required BaseGameResponse model}) {
    return GameCard(
      game_status: model.gameStatus,
      title: model.title,
      startdate: model.startDate,
      starttime: model.startTime,
      enddate: model.endDate,
      endtime: model.endTime,
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final startTime = starttime.substring(0, 5);
    final endTime = endtime.substring(0, 5);
    return InkWell(
      onTap: () {
        Map<String, String> pathParameters = {'gameId': id.toString()};
        Map<String, String> queryParameters = {};
        context.pushNamed(GameDetailScreen.routeName,
            pathParameters: pathParameters, queryParameters: queryParameters);
      },
      child: Container(
        decoration: BoxDecoration(
            color: MITIColor.gray700,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: MITIColor.gray600)),
        padding: EdgeInsets.all(16.r),
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
                  SizedBox(height: 8.h),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: MITITextStyle.mdBold.copyWith(
                      color: MITIColor.gray200,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetUtil.getAssetPath(
                            type: AssetType.icon, name: 'clock'),
                        width: 16.r,
                        height: 16.r,
                        colorFilter: const ColorFilter.mode(
                          MITIColor.gray500,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        startdate == enddate
                            ? '$startTime ~ $endTime'
                            : '$startdate $startTime ~ $enddate $endTime',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: MITITextStyle.xxsm
                            .copyWith(color: MITIColor.gray300),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
