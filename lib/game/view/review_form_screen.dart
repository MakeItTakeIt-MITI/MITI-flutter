import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/game/view/game_participation_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:collection/collection.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/router_provider.dart';
import '../../util/util.dart';
import 'game_detail_screen.dart';

class ReviewScreen extends StatefulWidget {
  final int gameId;
  final int ratingId;
  final int? participationId;

  static String get routeName => 'reviewForm';

  const ReviewScreen({
    super.key,
    required this.gameId,
    this.participationId,
    required this.ratingId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
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
      height: 4.h,
      color: MITIColor.gray900,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray750,
      bottomNavigationBar: BottomButton(
        button: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final form = ref.watch(reviewFormProvider);
            final valid = form.rating != null && form.comment.isNotEmpty;
            return TextButton(
              onPressed: valid
                  ? () async {
                      final result =
                          ref.read(ratingProvider(ratingId: widget.ratingId));
                      if (result is ResponseModel<UserReviewModel>) {
                        final model = (result).data!;
                        createReview(ref, context, model.nickname);
                      } else {
                        createReview(ref, context, '닉네임');
                      }
                    }
                  : () {},
              style: TextButton.styleFrom(
                  backgroundColor:
                      valid ? MITIColor.primary : MITIColor.gray500),
              child: Text(
                '작성 완료',
                style: MITITextStyle.mdBold.copyWith(
                    color: valid ? MITIColor.gray800 : MITIColor.gray50),
              ),
            );
          },
        ),
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            DefaultAppBar(
              title: widget.participationId != null ? '게스트 리뷰' : '호스트 리뷰',
              isSliver: true,
              backgroundColor: MITIColor.gray750,
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _PlayerComponent(
                    participationId: widget.participationId,
                    ratingId: widget.ratingId,
                  ),
                  getDivider(),
                  _RatingForm(
                    participationId: widget.participationId,
                  ),
                  getDivider(),
                  _CommentForm(
                    participationId: widget.participationId,
                  ),
                  getDivider(),
                  _ReviewForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createReview(
      WidgetRef ref, BuildContext context, String nickname) async {
    BaseModel result;
    if (widget.participationId != null) {
      result = await ref.read(guestReviewProvider(
              gameId: widget.gameId, participationId: widget.participationId!)
          .future);
    } else {
      result = await ref.read(hostReviewProvider(
        gameId: widget.gameId,
      ).future);
    }
    if (result is ErrorModel) {
      if (context.mounted) {
        final gameApiType = widget.participationId != null
            ? GameApiType.createGuestReview
            : GameApiType.createHostReview;
        GameError.fromModel(model: result)
            .responseError(context, gameApiType, ref);
      }
    } else {
      if (context.mounted) {
        await ref
            .read(gamePlayersProvider(gameId: widget.gameId).notifier)
            .getPlayers(gameId: widget.gameId);
        final extra = CustomDialog(
          title: '리뷰 작성 완료',
          content: '$nickname님의 리뷰를 작성하였습니다.',
          onPressed: () {
            Map<String, String> pathParameters = {
              'gameId': widget.gameId.toString()
            };

            context.goNamed(
              GameParticipationScreen.routeName,
              pathParameters: pathParameters,
            );
          },
        );
        context.pushNamed(DialogPage.routeName, extra: extra);
      }
    }
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "자유로운 후기를 남겨주세요!",
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.r),
          Scrollbar(
            child: SingleChildScrollView(
              // scrollDirection: Axis.vertical,
              // reverse: true,
              child: IntrinsicHeight(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 110.h,
                    maxHeight: 500.h,
                  ),
                  child: TextFormField(
                    maxLines: null,
                    expands: true,
                    enabled: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: MITITextStyle.sm150.copyWith(
                      color: MITIColor.gray100,
                    ),
                    onChanged: (val) {
                      // ref.read(reviewFormProvider.notifier).updateComment(val);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),

                      // constraints: BoxConstraints(
                      //   minHeight: 68.h,
                      //   maxHeight: 500.h,
                      // ),
                      hintText: '리뷰를 작성해주세요.',
                      hintStyle: MITITextStyle.sm150
                          .copyWith(color: MITIColor.gray500),
                      hintMaxLines: 10,
                      fillColor: MITIColor.gray700,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      // isDense: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerComponent extends ConsumerWidget {
  final int? participationId;
  final int ratingId;

  const _PlayerComponent(
      {super.key, this.participationId, required this.ratingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(ratingProvider(ratingId: ratingId));
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      GameError.fromModel(model: result)
          .responseError(context, GameApiType.getReview, ref);
      return Text('에러');
    }
    final model = (result as ResponseModel<UserReviewModel>).data!;
    return HostComponent.fromModel(
      model: model,
      isHost: participationId == null,
    );
  }
}

class _RatingForm extends StatelessWidget {
  final int? participationId;

  const _RatingForm({super.key, this.participationId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 21.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            // participationId != null ? '게스트 평점' : '호스트 평점',
            '호스트는 어땠나요?',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.r),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return Center(
                child: RatingBar(
                  ratingWidget: RatingWidget(
                    full: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: 'fill_star2'),

                      // 'assets/images/icon/fill_star2.svg',
                      height: 40.r,
                      width: 40.r,
                    ),
                    half: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: 'fill_star2'),
                      // 'assets/images/icon/fill_star2.svg',
                      height: 40.r,
                      width: 40.r,
                    ),
                    empty: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: 'unfill_star2'),
                      // 'assets/images/icon/unfill_star2.svg',
                      height: 40.r,
                      width: 40.r,
                    ),
                  ),
                  itemSize: 42.r,
                  glowColor: const Color(0xffffadd0c),
                  itemPadding: EdgeInsets.symmetric(horizontal: 5.w),
                  onRatingUpdate: (v) {
                    ref
                        .read(reviewFormProvider.notifier)
                        .updateRating((v.toInt()));
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Consumer getStarForm(int idx) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final rating =
            ref.watch(reviewFormProvider.select((value) => value.rating));
        String name;
        if (rating != null && rating >= idx) {
          name = 'fill_star2';
        } else {
          name = 'unfill_star2';
        }
        return GestureDetector(
          onTap: () {
            ref.read(reviewFormProvider.notifier).updateRating(idx);
          },
          child: SvgPicture.asset(
            'assets/images/icon/$name.svg',
            height: 40.r,
            width: 40.r,
          ),
        );
      },
    );
  }
}

class _CommentForm extends ConsumerWidget {
  final int? participationId;

  const _CommentForm({super.key, this.participationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<String> comments = [
      '득점 능력',
      '볼핸들링',
      '수비 적극성',
      '패스',
      '슛 정확도',
      '공간 창출',
      '블로킹',
      '1:1수비',
      '스포츠맨쉽',
      '매너',
      '인사성',
      '리더쉽',
      '팀워크'
    ];
    final selected = ref.watch(selectedProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '어떤 점이 좋았나요?',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.r),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...comments
                  .map((e) =>
                      _ReviewChip(selected: true, onTap: () {}, title: e))
                  .toList()

              // _ReviewChip(
              //   selected: true,
              //   onTap: () {},
              //   title: '득점 능력',
              // ),
              // _ReviewChip(
              //   selected: false,
              //   onTap: () {},
              //   title: '득점 능력',
              // )
            ],
          ),
          // ListView.separated(
          //     physics: const NeverScrollableScrollPhysics(),
          //     padding: EdgeInsets.zero,
          //     shrinkWrap: true,
          //     itemBuilder: (_, idx) {
          //       return getComments(idx, comments[idx]);
          //     },
          //     separatorBuilder: (_, idx) {
          //       return SizedBox(height: 3.h);
          //     },
          //     itemCount: comments.length),
        ],
      ),
    );
  }

  Consumer getComments(int? idx, String comment) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final selected = ref.watch(selectedProvider);
        return InkWell(
          onTap: () {
            ref.read(selectedProvider.notifier).update((state) => idx);
            String comments = idx == 3 ? '' : comment;
            ref.read(reviewFormProvider.notifier).updateComment(comments);
          },
          child: Row(children: [
            SvgPicture.asset(
              'assets/images/icon/system_success.svg',
              colorFilter: ColorFilter.mode(
                  selected == idx
                      ? const Color(0xFF4065F5)
                      : const Color(0xFF666666),
                  BlendMode.srcIn),
            ),
            SizedBox(width: 4.5.w),
            Text(
              comment,
              style: MITITextStyle.textChoiceStyle.copyWith(
                  color: selected == idx
                      ? const Color(0xff4065f5)
                      : const Color(0xff666666)),
            )
          ]),
        );
      },
    );
  }
}

class _ReviewChip extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String title;

  const _ReviewChip(
      {super.key,
      required this.selected,
      required this.onTap,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [
                      Color(0xFFAFFEFF),
                      Color(0xFF7EFDFF),
                    ])
              : null,
          color: selected ? null : MITIColor.gray800,
          // border: selected
          //     ? Border.all(
          //         color: MITIColor.primary,
          //       )
          //     : null
          // color: selected ?
        ),
        child: Text(
          title,
          style: MITITextStyle.smSemiBold.copyWith(
            color: selected ? MITIColor.gray800 : MITIColor.gray300,
          ),
        ),
      ),
    );
  }
}
