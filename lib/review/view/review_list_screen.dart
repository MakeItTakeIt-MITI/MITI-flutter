import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/review/model/review_model.dart';
import 'package:miti/review/providier/review_list_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../../game/view/review_form_screen.dart';
import '../../user/model/review_model.dart';
import '../../user/view/review_detail_screen.dart';
import '../../util/util.dart';
import '../component/skeleton/review_card_skeleton.dart';
import '../model/v2/base_guest_review_response.dart';
import '../model/v2/base_host_review_response.dart';
import '../model/v2/base_written_review_response.dart';
import '../model/v2/guest_review_list_response.dart';
import '../model/v2/host_review_list_response.dart';

class ReviewListScreen extends StatelessWidget {
  final int gameId;
  final int? participationId;

  static String get routeName => 'reviewList';

  const ReviewListScreen({
    super.key,
    required this.gameId,
    this.participationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray800,
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  BaseModel result;
                  if (participationId == null) {
                    result = ref.watch(hostReviewListProvider(gameId: gameId));
                  } else {
                    result = ref.watch(guestReviewListProvider(
                        gameId: gameId, participationId: participationId!));
                  }
                  if (result is LoadingModel || result is ErrorModel) {
                    return const DefaultAppBar(
                      isSliver: true,
                      title: '리뷰 내용',
                      hasBorder: false,
                      backgroundColor: MITIColor.gray750,
                    );
                  }
                  late String nickname;
                  if (participationId == null) {
                    final model =
                        (result as ResponseModel<HostReviewListResponse>).data!;
                    nickname = model.reviewee.nickname;
                  } else {
                    final model =
                        (result as ResponseModel<GuestReviewListResponse>)
                            .data!;
                    nickname = model.reviewee.nickname;
                  }
                  nickname = nickname.length > 6
                      ? '${nickname.substring(0, 6)}...'
                      : nickname;
                  return DefaultAppBar(
                    isSliver: true,
                    hasBorder: false,
                    backgroundColor: MITIColor.gray750,
                    title: '$nickname님의 리뷰 내용',
                  );
                },
              )
            ];
          },
          body: CustomScrollView(
            slivers: [
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  BaseModel result;
                  BaseReviewListResponse model;
                  if (participationId == null) {
                    result = ref.watch(hostReviewListProvider(gameId: gameId));
                  } else {
                    result = ref.watch(guestReviewListProvider(
                        gameId: gameId, participationId: participationId!));
                  }
                  if (result is LoadingModel) {
                    return const SliverToBoxAdapter(
                      child: ReviewCardListSkeleton(),
                    );
                  } else if (result is ErrorModel) {
                    return const SliverToBoxAdapter(child: Text('error'));
                  }

                  if (participationId == null) {
                    model =
                    (result as ResponseModel<HostReviewListResponse>).data!;
                  } else {
                    model = (result as ResponseModel<GuestReviewListResponse>)
                        .data!;
                  }
                  int itemCount = 0;
                  if (model is GuestReviewListResponse) {
                    itemCount = model.reviews.length;
                  } else {
                    itemCount =
                        (model as HostReviewListResponse).reviews.length;
                  }

                  return SliverList.separated(
                    itemBuilder: (_, idx) {
                      if (model is GuestReviewListResponse) {
                        final rModel = (model as GuestReviewListResponse);
                        return ReviewCard.fromGuestHistoryModel(
                          model: rModel.reviews[idx],
                          onTap: () {
                            Map<String, String> queryParameters = {
                              'revieweeNickname': rModel.reviewee.nickname
                            };
                            if (participationId != null) {
                              queryParameters['participationId'] =
                                  participationId.toString();
                            }

                            Map<String, String> pathParameters = {
                              'reviewId': rModel.reviews[idx].id.toString(),
                              'gameId': gameId.toString(),
                            };

                            context.pushNamed(
                              ReviewDetailScreen.routeName,
                              pathParameters: pathParameters,
                              queryParameters: queryParameters,
                            );
                          },
                        );
                      } else {
                        final rModel = (model as HostReviewListResponse);
                        return ReviewCard.fromHostHistoryModel(
                          model: rModel.reviews[idx],
                          onTap: () {
                            Map<String, String> queryParameters = {
                              'revieweeNickname': rModel.reviewee.nickname
                            };
                            if (participationId != null) {
                              queryParameters['participationId'] =
                                  participationId.toString();
                            }

                            Map<String, String> pathParameters = {
                              'reviewId': rModel.reviews[idx].id.toString(),
                              'gameId': gameId.toString(),
                            };

                            context.pushNamed(
                              ReviewDetailScreen.routeName,
                              pathParameters: pathParameters,
                              queryParameters: queryParameters,
                            );
                          },
                        );
                      }
                    },
                    separatorBuilder: (_, idx) => Container(height: 8.h),
                    itemCount: itemCount,
                  );
                },
              )
            ],
          )),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final int id;
  final int rating;
  final String nickname;
  final List<PlayerReviewTagType> tags;
  final String? comment;
  final VoidCallback onTap;

  const ReviewCard(
      {super.key,
      required this.id,
      required this.rating,
      required this.tags,
      this.comment,
      required this.onTap,
      required this.nickname});

  factory ReviewCard.fromHistoryModel(
      {required ReviewHistoryModel model, required VoidCallback onTap}) {
    final tags = model.tags.length > 2 ? model.tags.sublist(0, 2) : model.tags;

    return ReviewCard(
      id: model.id,
      rating: model.rating,
      tags: tags,
      onTap: onTap,
      nickname: model.reviewer.nickname,
    );
  }

  factory ReviewCard.fromGuestHistoryModel(
      {required BaseGuestReviewResponse model, required VoidCallback onTap}) {
    final tags = model.tags.length > 2 ? model.tags.sublist(0, 2) : model.tags;

    return ReviewCard(
      id: model.id,
      rating: model.rating,
      tags: tags,
      onTap: onTap,
      nickname: model.reviewer.nickname,
    );
  }

  factory ReviewCard.fromHostHistoryModel(
      {required BaseHostReviewResponse model, required VoidCallback onTap}) {
    final tags = model.tags.length > 2 ? model.tags.sublist(0, 2) : model.tags;

    return ReviewCard(
      id: model.id,
      rating: model.rating,
      tags: tags,
      onTap: onTap,
      nickname: model.reviewer.nickname,
    );
  }

  factory ReviewCard.fromWrittenModel(
      {required BaseWrittenReviewResponse model, required VoidCallback onTap}) {
    final tags = model.tags.length > 2 ? model.tags.sublist(0, 2) : model.tags;

    return ReviewCard(
      id: model.id,
      rating: model.rating,
      tags: tags,
      onTap: onTap,
      nickname: model.reviewee.nickname,
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
          ? 'star_s_half'
          : rating >= i + 1
              ? 'star_s_full'
              : 'star_s_empty';
      result.add(SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.icon, name: star),
        height: 16.r,
        width: 16.r,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final reviewChips = tags.map(
      (t) => Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: ReviewChip(selected: true, onTap: () {}, title: t.name),
      ),
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 21.w,
          vertical: 24.h,
        ),
        color: MITIColor.gray750,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        "$nickname 님",
                        style: MITITextStyle.smBold
                            .copyWith(color: MITIColor.gray100),
                      )
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(
                        '평점',
                        style: MITITextStyle.xxsm
                            .copyWith(color: MITIColor.gray100),
                      ),
                      SizedBox(width: 32.h),
                      ...getStar(rating.toDouble()),
                      SizedBox(width: 6.h),
                      Text(
                        '$rating',
                        style:
                            MITITextStyle.sm.copyWith(color: MITIColor.gray100),
                      )
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text(
                        '좋았던 점',
                        style: MITITextStyle.xxsm
                            .copyWith(color: MITIColor.gray100),
                      ),
                      SizedBox(width: 16.h),
                      ...reviewChips,
                    ],
                  ),
                  if (comment != null && comment!.isNotEmpty)
                    SizedBox(height: 12.h),
                  if (comment != null && comment!.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          '한줄평',
                          style: MITITextStyle.xxsm
                              .copyWith(color: MITIColor.gray100),
                        ),
                        SizedBox(width: 20.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          height: 28.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: MITIColor.gray700),
                          child: Text(
                            comment!,
                            style: MITITextStyle.xxsmLight.copyWith(
                              color: MITIColor.gray100,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                ],
              ),
            ),
            SvgPicture.asset(AssetUtil.getAssetPath(
                type: AssetType.icon, name: 'chevron_right'))
          ],
        ),
      ),
    );
  }
}
