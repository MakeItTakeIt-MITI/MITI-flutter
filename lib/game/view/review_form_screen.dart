import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/game/view/game_participation_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:collection/collection.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/router_provider.dart';
import 'game_detail_screen.dart';

class ReviewScreen extends StatefulWidget {
  final int gameId;
  final int ratingId;
  final int? participationId;
  final int bottomIdx;

  static String get routeName => 'reviewForm';

  const ReviewScreen(
      {super.key,
      required this.gameId,
      this.participationId,
      required this.ratingId,
      required this.bottomIdx});

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
      height: 5.h,
      color: const Color(0xFFF8F8F8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom > 80.h
        ? MediaQuery.of(context).viewInsets.bottom - 80.h
        : 0.0;
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            DefaultAppBar(
              title: widget.participationId != null ? '게스트 리뷰' : '호스트 리뷰',
              isSliver: true,
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              sliver: SliverToBoxAdapter(
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
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final form = ref.watch(reviewFormProvider);
                        final valid =
                            form.rating != null && form.comment.isNotEmpty;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: TextButton(
                            onPressed: valid
                                ? () async {
                                    createReview(ref, context, '닉네임');
                                  }
                                : () {},
                            style: TextButton.styleFrom(
                                backgroundColor: valid
                                    ? const Color(0xFF4065F5)
                                    : const Color(0xFFE8E8E8)),
                            child: Text(
                              '리뷰 작성하기',
                              style: MITITextStyle.btnTextBStyle.copyWith(
                                  color: valid
                                      ? Colors.white
                                      : const Color(0xff969696)),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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
    } else {
      if (context.mounted) {
        await ref
            .read(gamePlayersProvider(gameId: widget.gameId).notifier)
            .getPlayers(gameId: widget.gameId);
        final extra = CustomDialog(
          title: '리뷰 작성 완료',
          content: '$nickname 님의 리뷰를 작성하였습니다.',
          onPressed: () {
            Map<String, String> pathParameters = {
              'gameId': widget.gameId.toString()
            };
            Map<String, String> queryParameters = {
              'bottomIdx': widget.bottomIdx.toString()
            };

            context.goNamed(
              GameParticipationScreen.routeName,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
            );
          },
        );
        context.pushNamed(DialogPage.routeName, extra: extra);
      }
    }
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
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            participationId != null ? '게스트 평점' : '호스트 평점',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 12.r),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getStarForm(1),
              SizedBox(width: 10.w),
              getStarForm(2),
              SizedBox(width: 10.w),
              getStarForm(3),
              SizedBox(width: 10.w),
              getStarForm(4),
              SizedBox(width: 10.w),
              getStarForm(5),
            ],
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
      '경기 진행이 매끄럽습니다.',
      '음료수를 제공해주셨어요.',
      '아주 친절하십니다.',
      '직접 작성',
    ];
    final selected = ref.watch(selectedProvider);
    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            participationId != null ? '게스트 한줄평' : '호스트 한줄평',
            style: MITITextStyle.sectionTitleStyle.copyWith(
              color: const Color(0xff222222),
            ),
          ),
          SizedBox(height: 12.r),
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (_, idx) {
                return getComments(idx, comments[idx]);
              },
              separatorBuilder: (_, idx) {
                return SizedBox(height: 3.h);
              },
              itemCount: comments.length),
          SizedBox(height: 12.r),
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
                    enabled: selected == 3,
                    textAlignVertical: TextAlignVertical.top,
                    style: MITITextStyle.inputValueMStyle.copyWith(
                      color: Colors.black,
                    ),
                    onChanged: (val) {
                      ref.read(reviewFormProvider.notifier).updateComment(val);
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),

                      // constraints: BoxConstraints(
                      //   minHeight: 68.h,
                      //   maxHeight: 500.h,
                      // ),
                      hintText: '리뷰를 작성해주세요.',
                      hintStyle: MITITextStyle.placeHolderMStyle
                          .copyWith(color: const Color(0xFF969696)),
                      hintMaxLines: 10,
                      fillColor: const Color(0xFFF7F7F7),
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 12.h),
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
