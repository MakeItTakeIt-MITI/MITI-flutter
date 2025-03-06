import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/view/review_form_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../../game/model/game_player_model.dart';
import '../../game/model/v2/game/game_with_court_response.dart';
import '../../review/component/skeleton/review_detail_skeleton.dart';
import '../../review/model/v2/guest_review_response.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String revieweeNickname;
  final int gameId;
  final int reviewId;
  final int? participationId;

  static String get routeName => 'reviewDetail';

  const ReviewDetailScreen({
    super.key,
    required this.reviewId,
    this.participationId,
    required this.gameId,
    required this.revieweeNickname,
  });

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
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

  Widget getDivider() {
    return Divider(
      color: MITIColor.gray600,
      indent: 13.w,
      endIndent: 13.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray750,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          final nickname = widget.revieweeNickname.length > 6
              ? '${widget.revieweeNickname.substring(0, 6)}...'
              : widget.revieweeNickname;
          return [
            DefaultAppBar(
              backgroundColor: MITIColor.gray750,
              title: '$nickname님에게 남긴 리뷰',
              isSliver: true,
              hasBorder: false,
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result = ref.watch(reviewDetailProvider(
                    gameId: widget.gameId,
                    participationId: widget.participationId,
                    reviewId: widget.reviewId,
                  ));
                  if (result is LoadingModel) {
                    return const ReviewDetailSkeleton(
                      reviewType: ReviewType.guest_review,
                    );
                  } else if (result is ErrorModel) {
                    // final userApiType =
                    //     UserReviewType.written == widget.reviewType
                    //         ? UserApiType.writtenReviewDetail
                    //         : UserApiType.receiveReviewDetail;
                    // UserError.fromModel(model: result)
                    //     .responseError(context, userApiType, ref);
                    return Text('에러');
                  }
                  final model =
                      (result as ResponseModel<GuestReviewResponse>).data!;

                  return Column(
                    children: [
                      UserInfoComponent(
                        nickname: model.reviewer.nickname,
                        title: '리뷰 작성자',
                        profileImageUrl: model.reviewer.profileImageUrl,
                      ),
                      getDivider(),
                      GameInfoComponent.fromModel(model: model.game),
                      getDivider(),
                      ReviewInfoComponent.fromModel(model: model),
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

class UserInfoComponent extends StatelessWidget {
  final String title;
  final String profileImageUrl;
  final String nickname;

  const UserInfoComponent(
      {super.key,
      required this.nickname,
      required this.title,
      required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              if (profileImageUrl != null)
                CircleAvatar(
                  radius: 18.r,
                  backgroundImage: NetworkImage(profileImageUrl, scale: 36.r),
                )
              else
                SvgPicture.asset(
                  AssetUtil.getAssetPath(
                      type: AssetType.icon, name: 'user_thum'),
                  width: 36.r,
                  height: 36.r,
                ),
              SizedBox(width: 12.w),
              Text(
                '$nickname 님',
                style: MITITextStyle.smBold.copyWith(color: MITIColor.gray100),
              )
            ],
          )
        ],
      ),
    );
  }
}

class GameInfoComponent extends StatelessWidget {
  final String title;
  final String period;
  final String address;
  final String fee;

  const GameInfoComponent(
      {super.key,
      required this.title,
      required this.period,
      required this.address,
      required this.fee});

  factory GameInfoComponent.fromModel({required GameWithCourtResponse model}) {
    final st = DateTime.parse(model.startDate);
    final et = DateTime.parse(model.endDate);
    final fe = DateFormat('yyyy년 MM월 dd일 (E)', 'ko');

    final startDate = fe.format(st);
    final endDate = fe.format(et);
    final period = model.startDate == model.endDate
        ? "$startDate ${model.startTime.substring(0, 5)}~${model.endTime.substring(0, 5)}"
        : "$startDate ${model.startTime.substring(0, 5)} ~\n$endDate ${model.endTime.substring(0, 5)}";

    return GameInfoComponent(
      title: model.title,
      period: period,
      address: model.court.address + (" ${model.court.addressDetail ?? ''}"),
      fee:
          model.fee == 0 ? '무료' : "${NumberUtil.format(model.fee.toString())}원",
    );
  }

  Row getGameInfo({required String title, required String desc}) {
    return Row(
      children: [
        Text(
          title,
          style: MITITextStyle.xxsmLight.copyWith(
            color: MITIColor.gray400,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MITITextStyle.xxsm.copyWith(
              color: MITIColor.gray300,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '경기 정보',
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 8.h),
          getGameInfo(title: '경기 일시', desc: period),
          SizedBox(height: 4.h),
          getGameInfo(title: '경기 장소', desc: address),
          SizedBox(height: 4.h),
          getGameInfo(title: '참여 비용', desc: fee),
        ],
      ),
    );
  }
}

class ReviewInfoComponent extends StatelessWidget {
  final int rating;
  final List<PlayerReviewTagType> tags;
  final String? comment;

  const ReviewInfoComponent(
      {super.key,
      required this.rating,
      required this.tags,
      required this.comment});

  factory ReviewInfoComponent.fromModel({required GuestReviewResponse model}) {
    return ReviewInfoComponent(
      rating: model.rating,
      tags: model.tags,
      comment: model.comment,
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
      result.add(Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: SvgPicture.asset(
          AssetUtil.getAssetPath(type: AssetType.icon, name: star),
          height: 40.r,
          width: 40.r,
        ),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "리뷰 내용",
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Text(
            '평점',
            style: MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray200),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ...getStar(rating.toDouble()),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            '잘했던 점',
            style: MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray200),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.r,
            runSpacing: 12.r,
            children: [
              ...tags.map(
                (t) => ReviewChip(selected: true, onTap: () {}, title: t.name),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (comment != null && comment!.isNotEmpty)
            Text(
              '한줄평',
              style:
                  MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray200),
            ),
          if (comment != null && comment!.isNotEmpty) SizedBox(height: 12.h),
          if (comment != null && comment!.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: MITIColor.gray700),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Text(
                comment!,
                style: MITITextStyle.sm150.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
            )
        ],
      ),
    );
  }
}
