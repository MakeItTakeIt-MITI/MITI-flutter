import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/custom_time_picker.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/model/game_player_model.dart';
import 'package:miti/game/model/widget/user_reivew_short_info_model.dart';
import 'package:miti/game/provider/game_provider.dart' hide Rating;
import 'package:miti/game/view/review_form_screen.dart';
import 'package:miti/review/view/review_list_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/entity_enum.dart';
import '../../user/view/user_review_detail_screen.dart';
import '../model/game_model.dart';
import 'package:collection/collection.dart';

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
    return Scaffold(
      backgroundColor: MITIColor.gray750,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              title: '경기 리뷰 남기기',
              isSliver: true,
              backgroundColor: MITIColor.gray750,
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
                    return const CircularProgressIndicator();
                  } else if (result is ErrorModel) {
                    return const Column(
                      children: [
                        Text('에러'),
                      ],
                    );
                  }
                  final model =
                      (result as ResponseModel<GameRevieweesModel>).data!;
                  final userId = ref.read(authProvider)?.id ?? 0;

                  /// 본인 리뷰 제거
                  model.participations.removeWhere((e) => e.userId == userId);

                  return Column(
                    children: [
                      if (model.host != null && model.host?.userId != userId)
                        _HostReviewComponent(
                          host: model.host!,
                          gameId: widget.gameId,
                        ),
                      if ((model.host != null &&
                              model.host?.userId != userId) &&
                          model.participations.isNotEmpty)
                        Container(
                          color: MITIColor.gray800,
                          height: 4.h,
                        ),
                      if (model.participations.isNotEmpty)
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
  final String nickname;
  final ParticipationStatus? participation_status;
  final int gameId;
  final int? participationId;
  final Rating rating;
  final List<ReviewerModel> reviews;

  const _PlayerComponent({
    super.key,
    this.participation_status,
    this.participationId,
    required this.gameId,
    required this.nickname,
    required this.rating,
    required this.reviews,
  });

  factory _PlayerComponent.fromParticipationModel({
    required GameParticipationModel model,
    required int gameId,
  }) {
    return _PlayerComponent(
      participation_status: model.participation_status,
      gameId: gameId,
      participationId: model.id,
      nickname: model.nickname,
      rating: model.guest_rating,
      reviews: model.guest_reviews,
    );
  }

  factory _PlayerComponent.fromHostModel({
    required ReviewHostModel model,
    required int gameId,
  }) {
    return _PlayerComponent(
      gameId: gameId,
      nickname: model.nickname,
      rating: model.host_rating,
      reviews: model.host_reviews,
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
          color: MITIColor.gray700,
          border: Border.all(color: MITIColor.gray600)),
      padding: EdgeInsets.all(16.r),
      alignment: Alignment.center,
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
                  nickname,
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
                      ...getStar(rating.average_rating ?? 0),
                      SizedBox(width: 6.w),
                      Text(
                        (rating.average_rating ?? 0).toStringAsFixed(1),
                        style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '리뷰 ${rating.num_of_reviews}',
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
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final userId = ref.watch(authProvider.select((user) => user?.id));
              final valid =
                  reviews.singleWhereOrNull((r) => r.reviewer == userId);

              return TextButton(
                  onPressed: () {
                    Map<String, String> queryParameters = {};
                    if (participationId != null) {
                      queryParameters = {
                        'participationId': participationId.toString()
                      };
                    }

                    /// 리뷰 쓰기
                    if (valid == null) {
                      Map<String, String> pathParameters = {
                        'gameId': gameId.toString(),
                      };
                      final model = UserReviewShortInfoModel(
                          nickname: nickname, rating: rating);

                      context.pushNamed(
                        ReviewScreen.routeName,
                        pathParameters: pathParameters,
                        queryParameters: queryParameters,
                        extra: model,
                      );
                    } else {
                      /// 리뷰 내역 보기
                      Map<String, String> queryParameters = {};
                      if (participationId != null) {
                        queryParameters = {
                          'participationId': participationId.toString()
                        };
                      }
                      Map<String, String> pathParameters = {
                        'gameId': gameId.toString(),
                      };

                      context.pushNamed(
                        ReviewListScreen.routeName,
                        queryParameters: queryParameters,
                        pathParameters: pathParameters,
                      );
                      // Map<String, String> pathParameters = {
                      //   'reviewId': valid.id.toString(),
                      //   'gameId': gameId.toString(),
                      // };
                      //
                      // context.pushNamed(
                      //   ReviewDetailScreen.routeName,
                      //   pathParameters: pathParameters,
                      //   queryParameters: queryParameters,
                      // );
                    }
                  },
                  style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      minimumSize: Size(75.w, 30.h),
                      fixedSize: Size(75.w, 30.h),
                      maximumSize: Size(75.w, 30.h),
                      backgroundColor:
                          valid == null ? MITIColor.primary : MITIColor.gray800,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r))),
                  child: Text(
                    valid == null ? "리뷰 쓰기" : "리뷰 보기",
                    style: MITITextStyle.smSemiBold.copyWith(
                      color:
                          valid == null ? MITIColor.gray800 : MITIColor.primary,
                    ),
                  ));
            },
          )
        ],
      ),
    );
  }
}

class _HostReviewComponent extends StatelessWidget {
  final ReviewHostModel host;
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
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              '호스트',
              style: MITITextStyle.mdBold.copyWith(
                color: MITIColor.gray100,
              ),
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
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              '게스트',
              style: MITITextStyle.mdBold.copyWith(
                color: MITIColor.gray100,
              ),
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
