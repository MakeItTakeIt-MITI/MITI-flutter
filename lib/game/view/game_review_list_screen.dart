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
import '../../common/error/view/error_screen.dart';
import '../../common/model/entity_enum.dart';
import '../../review/model/v2/base_guest_rating_response.dart';
import '../../review/model/v2/game_reviewee_list_response.dart';
import '../../review/model/v2/user_written_reviews.dart';
import '../../user/model/v2/user_host_rating_response.dart';
import '../../user/view/review_detail_screen.dart';
import '../component/skeleton/game_participation_review_skeleton.dart';
import '../model/game_model.dart';
import 'package:collection/collection.dart';

import '../model/v2/participation/participation_guest_rating_response.dart';

class GameReviewListScreen extends StatefulWidget {
  final int gameId;

  static String get routeName => 'gameReviewList';

  const GameReviewListScreen({super.key, required this.gameId});

  @override
  State<GameReviewListScreen> createState() => _GameReviewListScreenState();
}

class _GameReviewListScreenState extends State<GameReviewListScreen> {
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
            SliverFillRemaining(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result =
                      ref.watch(gamePlayersProvider(gameId: widget.gameId));
                  if (result is LoadingModel) {
                    return const GameParticipationReviewSkeleton();
                  } else if (result is ErrorModel) {
                    WidgetsBinding.instance.addPostFrameCallback((s) =>
                        context.pushReplacementNamed(ErrorScreen.routeName));
                    return const Column(
                      children: [
                        Text('에러'),
                      ],
                    );
                  }

                  final model =
                      (result as ResponseModel<GameRevieweeListResponse>).data!;
                  final userId = ref.read(authProvider)?.id ?? 0;

                  /// 본인 리뷰 제거
                  model.participations.removeWhere((e) => e.user.id == userId);

                  if (model.participations.isEmpty) {
                    return Center(
                      child: Text(
                        '리뷰를 작성할\n플레이어가 없습니다.',
                        style: MITITextStyle.xxl140
                            .copyWith(color: MITIColor.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (model.userParticipationId != null)
                        _HostReviewComponent(
                          host: model.host,
                          gameId: widget.gameId,
                          isWrittenReview:
                              model.userWrittenReviews.writtenHostReviewId !=
                                  null,
                        ),
                      if (model.userParticipationId != null &&
                          model.participations.isNotEmpty)
                        Container(
                          color: MITIColor.gray800,
                          height: 4.h,
                        ),
                      if (model.participations.isNotEmpty)
                        _GuestReviewComponent(
                          userWrittenReviews: model.userWrittenReviews,
                          participations: model.participations,
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
  final ParticipationStatusType? participationStatus;
  final int gameId;
  final int? participationId;
  final BaseRatingResponse rating;
  final bool isWrittenReview;
  final String profileImageUrl;

  // final List<ReviewerModel> reviews;

  const _PlayerComponent({
    super.key,
    this.participationStatus,
    this.participationId,
    required this.gameId,
    required this.nickname,
    required this.rating,
    required this.isWrittenReview,
    required this.profileImageUrl,
    // required this.reviews,
  });

  factory _PlayerComponent.fromParticipationModel({
    required ParticipationGuestRatingResponse model,
    required int gameId,
    required bool isWrittenReview,
  }) {
    return _PlayerComponent(
      participationStatus: model.participationStatus,
      gameId: gameId,
      participationId: model.id,
      nickname: model.user.nickname,
      rating: model.user.guestRating,
      isWrittenReview: isWrittenReview,
      profileImageUrl: model.user.profileImageUrl,
      // reviews: model.guest_reviews,
    );
  }

  factory _PlayerComponent.fromHostModel({
    required UserHostRatingResponse model,
    required int gameId,
    required bool isWrittenReview,
  }) {
    return _PlayerComponent(
      gameId: gameId,
      nickname: model.nickname,
      rating: model.hostRating,
      isWrittenReview: isWrittenReview,
      profileImageUrl: model.profileImageUrl,
      // reviews: model.host_reviews,
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
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 18.r,
            backgroundImage: NetworkImage(profileImageUrl, scale: 36.r),
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
                      ...getStar(rating.averageRating ?? 0),
                      SizedBox(width: 6.w),
                      Text(
                        (rating.averageRating ?? 0).toStringAsFixed(1),
                        style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray100,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '리뷰 ${rating.numOfReviews}',
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
              // final valid = isWrittenReview;
              //reviews.singleWhereOrNull((r) => r.reviewer == userId);
              log('isWrittenReview = $isWrittenReview');

              return TextButton(
                  onPressed: () {
                    Map<String, String> queryParameters = {};
                    if (participationId != null) {
                      queryParameters = {
                        'participationId': participationId.toString()
                      };
                    }

                    /// 리뷰 쓰기
                    if (!isWrittenReview) {
                      Map<String, String> pathParameters = {
                        'gameId': gameId.toString(),
                      };

                      final model = UserReviewShortInfoModel(
                        nickname: nickname,
                        rating: rating,
                        profileImageUrl: profileImageUrl,
                      );

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
                      maximumSize: Size(90.w, 30.h),
                      backgroundColor: !isWrittenReview
                          ? MITIColor.primary
                          : MITIColor.gray800,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r))),
                  child: Text(
                    !isWrittenReview ? "리뷰 쓰기" : "리뷰 보기",
                    style: MITITextStyle.smSemiBold.copyWith(
                      color: !isWrittenReview
                          ? MITIColor.gray800
                          : MITIColor.primary,
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
  final UserHostRatingResponse host;
  final int gameId;
  final bool isWrittenReview;

  const _HostReviewComponent({
    super.key,
    required this.host,
    required this.gameId,
    required this.isWrittenReview,
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
            isWrittenReview: isWrittenReview,
          ),
        ],
      ),
    );
  }
}

class _GuestReviewComponent extends StatelessWidget {
  final UserWrittenReviews userWrittenReviews;
  final List<ParticipationGuestRatingResponse> participations;
  final int gameId;

  const _GuestReviewComponent({
    super.key,
    required this.userWrittenReviews,
    required this.participations,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    final writtenUserIds = userWrittenReviews.writtenParticipationIds;

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
          if (participations.isEmpty) getEmptyWidget(),
          SizedBox(height: 12.h),
          if (participations.isNotEmpty)
            ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (_, idx) {
                  return _PlayerComponent.fromParticipationModel(
                    model: participations[idx],
                    gameId: gameId,
                    isWrittenReview: writtenUserIds.contains(
                      participations[idx].id,
                    ),
                  );
                },
                separatorBuilder: (_, idx) {
                  return SizedBox(height: 10.h);
                },
                itemCount: participations.length),
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
