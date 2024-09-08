import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/dispose_sliver_pagination_list_view.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../game/view/review_form_screen.dart';
import '../../theme/color_theme.dart';
import '../../user/model/review_model.dart';
import '../../user/param/user_profile_param.dart';
import '../../user/provider/user_pagination_provider.dart';
import '../../util/util.dart';

class ReceiveReviewListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'receiveReviewList';

  const ReceiveReviewListScreen({super.key});

  @override
  ConsumerState<ReceiveReviewListScreen> createState() =>
      _ReceiveReviewListScreenState();
}

class _ReceiveReviewListScreenState
    extends ConsumerState<ReceiveReviewListScreen> {
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
    final userId = ref.watch(authProvider)!.id!;
    return Scaffold(
      backgroundColor: MITIColor.gray900,
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                isSliver: true,
                title: '나를 평가한 리뷰',
                backgroundColor: MITIColor.gray750,
              )
            ];
          },
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              DisposeSliverPaginationListView(
                provider: userReceiveReviewsPProvider(
                    PaginationStateParam(path: userId)),
                itemBuilder: (BuildContext context, int index, Base pModel) {
                  pModel as ReceiveReviewModel;

                  return _ReceiveReviewCard.fromModel(model: pModel);
                },
                skeleton: Container(),
                param: UserReviewParam(),
                controller: _scrollController,
                separateSize: 8,
                emptyWidget: Container(
                  color: MITIColor.gray750,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '아직 평가한 내용이 없습니다.',
                        style: MITITextStyle.xxl140.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        '더 많은 경기에 참여해 보세요!',
                        style: MITITextStyle.sm.copyWith(
                          color: MITIColor.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class _ReceiveReviewCard extends StatelessWidget {
  final int id;
  final String reviewer;
  final ReviewType review_type;
  final int rating;
  final List<PlayerReviewTagType> tags;
  final String? comment;

  const _ReceiveReviewCard(
      {super.key,
      required this.id,
      required this.reviewer,
      required this.review_type,
      required this.rating,
      required this.tags,
      this.comment});

  factory _ReceiveReviewCard.fromModel({required ReceiveReviewModel model}) {
    final tags = model.tags.length > 2 ? model.tags.sublist(0, 2) : model.tags;

    return _ReceiveReviewCard(
      id: model.id,
      reviewer: model.reviewer,
      review_type: model.review_type,
      rating: model.rating,
      tags: tags,
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
    return Container(
      color: MITIColor.gray750,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 24.h),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "$reviewer 님",
                style: MITITextStyle.smBold.copyWith(color: MITIColor.gray100),
              )
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: MITIColor.gray700,
            ),
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
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
                          style: MITITextStyle.sm
                              .copyWith(color: MITIColor.gray100),
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
                  ],
                ),
              ),
              SvgPicture.asset(
                AssetUtil.getAssetPath(
                    type: AssetType.icon, name: 'chevron_right'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}