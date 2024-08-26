import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/model/game_player_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/view/review_form_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/entity_enum.dart';
import '../model/game_model.dart';

class GameParticipationScreen extends StatefulWidget {
  final int gameId;

  static String get routeName => 'participation';

  const GameParticipationScreen({super.key, required this.gameId});

  @override
  State<GameParticipationScreen> createState() =>
      _GameParticipationScreenState();
}

class _GameParticipationScreenState extends State<GameParticipationScreen> {
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
    return DefaultLayout(
      bottomIdx: 0,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              title: '경기 리뷰 남기기',
              isSliver: true,
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result =
                      ref.watch(gamePlayersProvider(gameId: widget.gameId));
                  if (result is LoadingModel) {
                    return CircularProgressIndicator();
                  } else if (result is ErrorModel) {
                    return Column(
                      children: [
                        Text('에러'),
                      ],
                    );
                  }
                  final model =
                      (result as ResponseModel<GamePlayerListModel>).data!;
                  final userId = ref.read(authProvider)?.id ?? 0;

                  /// 본인 리뷰 제거
                  model.participations.removeWhere((e) => e.user.id == userId);

                  return Column(
                    children: [
                      if (model.host != null && model.host?.id != userId)
                        _HostReviewComponent(
                          host: model.host!,
                          gameId: widget.gameId,
                        ),
                      _GuestReviewComponent(
                        participated_users: model.participations,
                        gameId: widget.gameId,
                      ),
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

class _PlayerComponent extends StatelessWidget {
  final int id;
  final ParticipationStatus? participation_status;
  final GamePlayerModel user;
  final int gameId;
  final int? participationId;

  const _PlayerComponent({
    super.key,
    required this.id,
    this.participation_status,
    required this.user,
    this.participationId,
    required this.gameId,
  });

  factory _PlayerComponent.fromParticipationModel({
    required GameParticipationModel model,
    required int gameId,
  }) {
    return _PlayerComponent(
      id: model.id,
      participation_status: model.participation_status,
      user: model.user,
      gameId: gameId,
      participationId: model.id,
    );
  }

  factory _PlayerComponent.fromHostModel({
    required GamePlayerModel model,
    required int gameId,
  }) {
    return _PlayerComponent(
      id: model.id,
      user: model,
      gameId: gameId,
    );
  }

  List<Widget> getStar(double rating) {
    List<Widget> result = [];
    for (int i = 0; i < 5; i++) {
      bool flag = false;
      if (i == rating.toInt()) {
        final decimalPoint = rating - rating.toInt();
        flag = decimalPoint != 0;
      }
      final String star = flag
          ? 'Star_half_v2'
          : rating >= i + 1
              ? 'fill_star'
              : 'unfill_star';
      result.add(SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.icon, name: star),
        height: 14.r,
        width: 14.r,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MITIColor.gray600)),
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/icon/user_thum.svg',
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
                  style:
                      MITITextStyle.smBold.copyWith(color: MITIColor.gray100),
                ),
                SizedBox(height: 4.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...getStar(user.rating.average_rating),
                      SizedBox(width: 6.w),
                      Text(
                        user.rating.average_rating.toStringAsFixed(1),
                        style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '리뷰 ${user.rating.num_of_reviews}',
                        style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Spacer(),
          TextButton(
              onPressed: () {
                Map<String, String> pathParameters = {
                  'gameId': gameId.toString(),
                };
                Map<String, String> queryParameters = {
                  'ratingId': user.rating.id.toString()
                };

                context.pushNamed(
                  ReviewScreen.routeName,
                  pathParameters: pathParameters,
                  queryParameters: queryParameters,
                );
              },
              style: TextButton.styleFrom(
                  minimumSize: Size(75.w, 30.h),
                  fixedSize: Size(75.w, 30.h),
                  maximumSize: Size(75.w, 30.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r))),
              child: Text(
                "리뷰 쓰기",
                style: MITITextStyle.smSemiBold.copyWith(
                  color: MITIColor.gray800,
                ),
              ))
        ],
      ),
    );
  }
}

class _HostReviewComponent extends StatelessWidget {
  final GamePlayerModel host;
  final int gameId;

  const _HostReviewComponent({
    super.key,
    required this.host,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '호스트',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff0d0000),
            ),
          ),
          SizedBox(height: 12.h),
          _PlayerComponent.fromHostModel(
            model: host,
            gameId: gameId,
          ),
        ],
      ),
    );
  }
}

class _GuestReviewComponent extends StatelessWidget {
  final List<GameParticipationModel> participated_users;
  final int gameId;

  const _GuestReviewComponent({
    super.key,
    required this.participated_users,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '게스트',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff0d0000),
            ),
          ),
          if (participated_users.isEmpty) getEmptyWidget(),
          SizedBox(height: 12.h),
          if (participated_users.isNotEmpty)
            ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (_, idx) {
                  return _PlayerComponent.fromParticipationModel(
                    model: participated_users[idx],
                    gameId: gameId,
                    // participationId: participationId,
                  );
                },
                separatorBuilder: (_, idx) {
                  return SizedBox(height: 10.h);
                },
                itemCount: participated_users.length),
        ],
      ),
    );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 170.h),
        Text(
          '작성할 사용자가 없습니다.',
          style: MITITextStyle.pageMainTextStyle,
        ),
        SizedBox(height: 20.h),
        Text(
          '다른 경기에 참여 후 리뷰를 작성해보세요!',
          style: MITITextStyle.pageSubTextStyle,
        )
      ],
    );
  }
}
