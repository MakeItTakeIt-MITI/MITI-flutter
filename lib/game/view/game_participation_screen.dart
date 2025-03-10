import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/model/game_player_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_drop_down_button.dart';
import '../../common/model/entity_enum.dart';
import '../../user/model/v2/base_player_profile_response.dart';
import '../../user/model/v2/user_guest_player_response.dart';
import '../../util/component/widget_util.dart';
import '../../util/util.dart';
import '../model/v2/participation/participation_guest_player_response.dart';

class GameParticipationScreen extends StatelessWidget {
  static String get routeName => 'participation';
  final int gameId;

  const GameParticipationScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: '참가한 게스트',
        hasBorder: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ParticipationFilterButton(
            gameId: gameId,
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final result =
                  ref.watch(gamePlayerProfileProvider(gameId: gameId));
              if (result is LoadingModel) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              } else if (result is ErrorModel) {
                return Text('error');
              }
              final model = (result
                      as ResponseListModel<ParticipationGuestPlayerResponse>)
                  .data!;
              log('model length = ${model.length}');
              if (model.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      '참가한 게스트가 없습니다.',
                      style:
                          MITITextStyle.xxl140.copyWith(color: MITIColor.white),
                    ),
                  ),
                );
              }
              return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (_, idx) {
                    return _ParticipationPlayerCard.fromModel(
                        model: model[idx]);
                  },
                  separatorBuilder: (_, idx) {
                    return SizedBox(height: 12.h);
                  },
                  itemCount: model.length);
            },
          ),
        ],
      ),
    );
  }
}

class _ParticipationPlayerCard extends StatelessWidget {
  final int id;
  final ParticipationStatusType participationStatus;
  final UserGuestPlayerResponse user;
  final BasePlayerProfileResponse profile;

  const _ParticipationPlayerCard({
    super.key,
    required this.id,
    required this.participationStatus,
    required this.user,
    required this.profile,
  });

  factory _ParticipationPlayerCard.fromModel(
      {required ParticipationGuestPlayerResponse model}) {
    return _ParticipationPlayerCard(
      id: model.id,
      participationStatus: model.participationStatus,
      user: model.user,
      profile: model.user.playerProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> details = [
      if (profile.gender?.displayName != null) profile.gender!.displayName,
      if (profile.height != null) "${profile.height} cm",
      if (profile.weight != null) "${profile.weight} kg",
      if (profile.position?.displayName != null) profile.position!.displayName,
    ];

    return Container(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          if (user.profileImageUrl != null)
            CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 18.r,
              backgroundImage: NetworkImage(user.profileImageUrl, scale: 36.r),
            )
          else
            SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: 'user_thum'),
              width: 36.r,
              height: 36.r,
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  user.nickname,
                  style: MITITextStyle.smBold.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    ...WidgetUtil.getStar(user.guestRating.averageRating ?? 0),
                    SizedBox(width: 6.w),
                    Text(
                      "${user.guestRating.averageRating ?? 0}",
                      style:
                          MITITextStyle.sm.copyWith(color: MITIColor.gray100),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '리뷰 ${user.guestRating.numOfReviews}',
                      style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray100,
                          decoration: TextDecoration.underline,
                          decorationColor: MITIColor.gray100),
                    )
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  details.join(" • "),
                  style: MITITextStyle.sm.copyWith(color: MITIColor.gray400),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ParticipationFilterButton extends ConsumerStatefulWidget {
  final int gameId;

  const _ParticipationFilterButton({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<_ParticipationFilterButton> createState() =>
      _ParticipationFilterButtonState();
}

class _ParticipationFilterButtonState
    extends ConsumerState<_ParticipationFilterButton> {
  final items = ['참가순', '신장순'];

  PlayerOrderType? getStatus(String? value) {
    switch (value) {
      case '참가순':
        return PlayerOrderType.participation;
      case '신장순':
        return PlayerOrderType.height;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        color: MITIColor.gray750,
      ))),
      child: Row(
        children: [
          const Spacer(),
          SizedBox(
            height: 58.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 13.h),
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final participationStatus = ref.watch(
                      dropDownValueProvider(DropButtonType.participation));
                  final selectStatus = participationStatus ?? '참가순';
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          useRootNavigator: true,
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20.r),
                            ),
                          ),
                          backgroundColor: MITIColor.gray800,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: MITIColor.gray100,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    width: 60.w,
                                    height: 4.h,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(20.r),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        '경기 상태',
                                        style: MITITextStyle.mdBold.copyWith(
                                          color: MITIColor.gray100,
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      ...items.map((i) {
                                        return GestureDetector(
                                          onTap: () {
                                            changeDropButton(i, widget.gameId);
                                            context.pop();
                                          },
                                          child: Container(
                                            height: 60.h,
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: MITIColor.gray700,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  i,
                                                  style: MITITextStyle
                                                      .smSemiBold
                                                      .copyWith(
                                                          color:
                                                              selectStatus == i
                                                                  ? MITIColor
                                                                      .primary
                                                                  : MITIColor
                                                                      .gray100),
                                                ),
                                                if (selectStatus == i)
                                                  SvgPicture.asset(
                                                    AssetUtil.getAssetPath(
                                                        type: AssetType.icon,
                                                        name: "active_check"),
                                                    height: 24.r,
                                                    width: 24.r,
                                                  )
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                )
                              ],
                            );
                          });
                    },
                    child: Container(
                      width: 92.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.r),
                        color: MITIColor.gray700,
                      ),
                      padding: EdgeInsets.only(left: 16.w, right: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            participationStatus ?? '참가순',
                            style: MITITextStyle.xxsmLight
                                .copyWith(color: MITIColor.gray100),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: MITIColor.primary,
                            size: 16.r,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeDropButton(String? value, int gameId) {
    ref
        .read(gamePlayerProfileProvider(gameId: gameId).notifier)
        .getPlayers(gameId: gameId, orderType: getStatus(value));
    ref
        .read(dropDownValueProvider(DropButtonType.participation).notifier)
        .update((state) => value);
  }
}
