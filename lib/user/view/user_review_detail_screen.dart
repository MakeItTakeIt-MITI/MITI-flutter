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
import 'package:miti/user/model/review_model.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/util/util.dart';

import '../../account/model/account_model.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/entity_enum.dart';
import '../../court/model/court_model.dart';
import '../../game/model/game_model.dart';
import '../../game/model/game_player_model.dart';
import '../../game/view/game_detail_screen.dart';
import '../error/user_error.dart';

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
                    return CircularProgressIndicator();
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
                      (result as ResponseModel<ReviewDetailModel>).data!;

                  return Column(
                    children: [
                      _UserInfoComponent(
                        nickname: model.reviewer,
                      ),
                      getDivider(),
                      _GameInfoComponent.fromModel(model: model.game),
                      getDivider(),
                      _ReviewInfoComponent.fromModel(model: model),
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

class _UserInfoComponent extends StatelessWidget {
  final String nickname;

  const _UserInfoComponent({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '리뷰 작성자',
            style: MITITextStyle.mdBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              SvgPicture.asset(
                AssetUtil.getAssetPath(type: AssetType.icon, name: 'user_thum'),
                width: 36.r,
                height: 36.r,
              ),
              SizedBox(width: 12.w),
              Text(
                nickname,
                style: MITITextStyle.smBold.copyWith(color: MITIColor.gray100),
              )
            ],
          )
        ],
      ),
    );
  }
}

class _GameInfoComponent extends StatelessWidget {
  final String title;
  final String period;
  final String address;
  final String fee;

  const _GameInfoComponent(
      {super.key,
      required this.title,
      required this.period,
      required this.address,
      required this.fee});

  factory _GameInfoComponent.fromModel({required ReviewGameModel model}) {
    final st = DateTime.parse(model.startdate);
    final et = DateTime.parse(model.startdate);
    final fe = DateFormat('yyyy년 MM월 dd일 (E)', 'ko');

    final startDate = fe.format(st);
    final endDate = fe.format(et);
    final period = model.startdate == model.enddate
        ? "$startDate ${model.starttime.substring(0, 5)}~${model.endtime.substring(0, 5)}"
        : "$startDate ${model.starttime.substring(0, 5)} ~\n$endDate ${model.endtime.substring(0, 5)}";

    return _GameInfoComponent(
      title: model.title,
      period: period,
      address: model.court.address + (" ${model.court.address_detail}" ?? ''),
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

class _ReviewInfoComponent extends StatelessWidget {
  final int rating;
  final List<PlayerReviewTagType> tags;
  final String? comment;

  const _ReviewInfoComponent(
      {super.key,
      required this.rating,
      required this.tags,
      required this.comment});

  factory _ReviewInfoComponent.fromModel({required ReviewDetailModel model}) {
    return _ReviewInfoComponent(
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
