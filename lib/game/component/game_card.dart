import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../model/base_game_meta_response.dart';
import '../model/v2/game/game_response.dart';
import '../view/game_detail_screen.dart';
import 'game_state_label.dart';

class GameCard extends StatelessWidget {
  final int id;
  final GameStatusType game_status;
  final String title;
  final String startdate;
  final String starttime;
  final String enddate;
  final String endtime;
  final String fee;
  final String? courtName;
  final String? courtAddress;
  final int num_of_participations;
  final int max_invitation;
  final bool showDate;

  const GameCard({
    super.key,
    required this.game_status,
    required this.title,
    required this.startdate,
    required this.starttime,
    required this.enddate,
    required this.endtime,
    required this.fee,
    required this.courtName,
    required this.courtAddress,
    required this.num_of_participations,
    required this.max_invitation,
    required this.id,
    required this.showDate,
  });

  factory GameCard.fromModel(
      {required BaseGameMetaResponse model, bool showDate = false}) {
    return GameCard(
      game_status: model.gameStatus,
      title: model.title,
      startdate: model.startDate,
      starttime: model.startTime,
      enddate: model.endDate,
      endtime: model.endTime,
      fee: formatFee(model.fee),
      num_of_participations: model.numOfParticipations,
      max_invitation: model.maxInvitation,
      id: model.id,
      showDate: showDate,
      courtName: model.courtName,
      courtAddress: "${model.address} ${model.addressDetail}",
    );
  }
  

  factory GameCard.fromMetaModel({required BaseGameMetaResponse model}) {
    return GameCard(
      game_status: model.gameStatus,
      title: model.title,
      startdate: model.startDate,
      starttime: model.startTime,
      enddate: model.endDate,
      endtime: model.endTime,
      fee: formatFee(model.fee),
      num_of_participations: model.numOfParticipations,
      max_invitation: model.maxInvitation,
      id: model.id,
      showDate: false,
      courtName: model.courtName,
      courtAddress: null,
    );
  }

  factory GameCard.fromSoonestGameModel({required GameResponse model}) {
    return GameCard(
      game_status: model.gameStatus,
      title: model.title,
      startdate: model.startDate,
      starttime: model.startTime,
      enddate: model.endDate,
      endtime: model.endTime,
      fee: formatFee(model.fee),
      num_of_participations: model.numOfParticipations,
      max_invitation: model.maxInvitation,
      id: model.id,
      courtAddress: null,
      courtName: null,
      showDate: false,
    );
  }

  static String formatFee(int fee) =>
      fee == 0 ? '무료' : "${NumberFormat.decimalPattern().format(fee)} 원";

  @override
  Widget build(BuildContext context) {
    final month = DateTime.parse(startdate).month;
    final day = DateTime.parse(startdate).day;
    return InkWell(
      onTap: () {
        Map<String, String> pathParameters = {'gameId': id.toString()};
        Map<String, String> queryParameters = {'bottomIdx': '0'};
        context.pushNamed(GameDetailScreen.routeName,
            pathParameters: pathParameters, queryParameters: queryParameters);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameStateLabel(gameStatus: game_status),
                    SizedBox(height: 8.h),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: V2MITITextStyle.smallBoldTight.copyWith(
                        color: V2MITIColor.white,
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: V2MITIColor.gray10,
                      borderRadius: BorderRadius.circular(4.r)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '$month',
                            style: V2MITITextStyle.miniMedium
                                .copyWith(color: V2MITIColor.white),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '월',
                            style: V2MITITextStyle.miniRegular
                                .copyWith(color: V2MITIColor.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$day',
                        style: V2MITITextStyle.smallBoldTight.copyWith(
                          color: V2MITIColor.white,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10.h),
          Column(
            spacing: 4.h,
            children: [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  if (courtAddress != null || courtName != null) {
                    return Row(
                      spacing: 4.w,
                      children: [
                        SvgPicture.asset(
                          AssetUtil.getAssetPath(
                            type: AssetType.icon,
                            name: "map_pin",
                          ),
                          colorFilter: const ColorFilter.mode(
                              MITIColor.gray500, BlendMode.srcIn),
                        ),
                        if (courtAddress != null)
                          Flexible(
                            child: Text(
                              courtAddress!,
                              style: V2MITITextStyle.miniMediumTight.copyWith(
                                  color: MITIColor.gray300,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        if (courtName != null)
                          Flexible(
                            child: Text(
                              courtName!,
                              style: V2MITITextStyle.miniMediumTight.copyWith(
                                  color: MITIColor.gray300,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          )
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              Row(
                spacing: 4.w,
                children: [
                  SvgPicture.asset(
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: "clock",
                    ),
                    width: 16.r,
                    height: 16.r,
                    colorFilter: const ColorFilter.mode(
                        MITIColor.gray500, BlendMode.srcIn),
                  ),
                  Text(
                    '${starttime.substring(0, 5)} ~ ${endtime.substring(0, 5)}',
                    style: V2MITITextStyle.miniMediumTight.copyWith(
                        color: MITIColor.gray300,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/icon/people.svg',
                            colorFilter: const ColorFilter.mode(
                                MITIColor.gray500, BlendMode.srcIn),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '$num_of_participations / $max_invitation',
                            style: V2MITITextStyle.miniMediumTight.copyWith(
                                color: MITIColor.gray300,
                                overflow: TextOverflow.ellipsis),
                          )
                        ],
                      ),
                      SizedBox(width: 12.w),
                    ],
                  ),
                  Text(
                    '$fee',
                    textAlign: TextAlign.right,
                    style: MITITextStyle.mdBold.copyWith(
                      color: V2MITIColor.primary5,
                    ),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
