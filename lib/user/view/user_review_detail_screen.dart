import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/model/review_model.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../account/model/account_model.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/entity_enum.dart';
import '../../court/model/court_model.dart';
import '../../game/model/game_model.dart';
import '../../game/view/game_detail_screen.dart';

class ReviewDetailScreen extends StatefulWidget {
  final UserReviewType reviewType;
  final int reviewId;
  final int bottomIdx;

  static String get routeName => 'reviewDetail';

  const ReviewDetailScreen({
    super.key,
    required this.reviewId,
    required this.reviewType,
    required this.bottomIdx,
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
    return Container(
      height: 5.h,
      color: const Color(0xFFF8F8F8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            DefaultAppBar(
              title: widget.reviewType == UserReviewType.written
                  ? '작성 리뷰'
                  : '내 리뷰',
              isSliver: true,
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result = ref.watch(reviewProvider(
                      type: widget.reviewType, reviewId: widget.reviewId));
                  if (result is LoadingModel) {
                    return CircularProgressIndicator();
                  } else if (result is ErrorModel) {
                    return Text('에러');
                  }
                  if (widget.reviewType == UserReviewType.written) {
                    final model =
                        (result as ResponseModel<WrittenReviewDetailModel>)
                            .data!;
                    return Column(
                      children: [
                        HostComponent.fromModel(model: model.reviewee),
                        getDivider(),
                        GameReviewCard.fromModel(model: model.game),
                        getDivider(),
                        _ReviewComponent.fromWrittenModel(model: model),
                      ],
                    );
                  } else {
                    final model =
                        (result as ResponseModel<ReceiveReviewDetailModel>)
                            .data!;
                    return Column(
                      children: [
                        GameReviewCard.fromModel(model: model.game),
                        getDivider(),
                        _ReviewComponent.fromReceiveModel(model: model),
                      ],
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GameReviewCard extends StatelessWidget {
  final int id;
  final String title;
  final String datetime;
  final String address;
  final int fee;

  const GameReviewCard({
    super.key,
    required this.title,
    required this.datetime,
    required this.address,
    required this.id,
    required this.fee,
  });

  factory GameReviewCard.fromModel({required ReviewGameModel model}) {
    final datetime =
        '${model.startdate.replaceAll('-', '.')} ${model.starttime.substring(0, 5)} ~ ${model.enddate.replaceAll('-', '.')} ${model.endtime.substring(0, 5)}';
    return GameReviewCard(
      title: model.title,
      datetime: datetime,
      address: '${model.court.address} ${model.court.address_detail ?? ''}',
      id: model.id,
      fee: model.fee,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '경기 정보',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE8E8E8)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: MITITextStyle.gameTitleCardLStyle.copyWith(
                    color: const Color(0xff333333),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  datetime,
                  style: MITITextStyle.gameTimeCardMStyle.copyWith(
                    color: const Color(0xff999999),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Text(
                        address,
                        style: MITITextStyle.gameTimeCardMStyle.copyWith(
                          color: const Color(0xff999999),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        '₩ $fee',
                        style: MITITextStyle.feeStyle.copyWith(
                          color: const Color(0xff4065f6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ReviewComponent extends StatelessWidget {
  final int rating;
  final String comment;

  const _ReviewComponent({
    super.key,
    required this.rating,
    required this.comment,
  });

  factory _ReviewComponent.fromWrittenModel(
      {required WrittenReviewDetailModel model}) {
    return _ReviewComponent(
      rating: model.rating,
      comment: model.comment,
    );
  }

  factory _ReviewComponent.fromReceiveModel(
      {required ReceiveReviewDetailModel model}) {
    return _ReviewComponent(
      rating: model.rating,
      comment: model.comment,
    );
  }

  List<Widget> getStar(int rating) {
    List<Widget> result = [];
    for (int i = 0; i < 5; i++) {
      final String star = rating >= i + 1 ? 'fill_star2' : 'unfill_star2';
      result.add(SvgPicture.asset(
        'assets/images/icon/$star.svg',
        height: 40.r,
        width: 40.r,
      ));
      result.add(SizedBox(width: 12.w));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '작성리뷰',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '평점',
            style: MITITextStyle.selectionSubtitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...getStar(rating),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '한줄평',
            style: MITITextStyle.selectionSubtitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            comment,
            style: MITITextStyle.plainTextSStyle.copyWith(
              color: const Color(0xff000000),
            ),
          ),
        ],
      ),
    );
  }
}
