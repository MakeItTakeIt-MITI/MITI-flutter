import 'dart:developer';
import 'dart:math' hide log;

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/component/form/keyboard_visibility_builder.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:collection/collection.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/error/view/error_screen.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/router_provider.dart';
import '../../util/util.dart';
import '../model/widget/user_reivew_short_info_model.dart';
import 'game_detail_screen.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final int gameId;

  // final int ratingId;
  final int? participationId;
  final UserReviewShortInfoModel userInfoModel;

  static String get routeName => 'reviewForm';

  const ReviewScreen({
    super.key,
    required this.gameId,
    this.participationId,
    required this.userInfoModel,
    // required this.ratingId,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late Throttle<int> _throttler;
  late final ScrollController _scrollController;
  int throttleCnt = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) async {
      setState(() {
        isLoading = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
      await createReview(ref, context, widget.userInfoModel.nickname);
      setState(() {
        isLoading = false;
      });
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _throttler.cancel();
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    // log("bottomPadding = $bottomPadding");
    return Scaffold(
      appBar: DefaultAppBar(
        title: widget.participationId != null ? '게스트 리뷰' : '호스트 리뷰',
        backgroundColor: MITIColor.gray750,
      ),
      backgroundColor: MITIColor.gray750,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: BottomButton(
          button: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final form = ref.watch(reviewFormProvider);
              final valid = form.rating > 0 && form.tags.length > 1;
              // log("valid  = $valid");

              return TextButton(
                onPressed: valid && !isLoading
                    ? () async {
                        _throttler.setValue(throttleCnt + 1);
                      }
                    : () {},
                style: TextButton.styleFrom(
                    backgroundColor:
                        valid && !isLoading ? MITIColor.primary : MITIColor.gray500),
                child: Text(
                  '작성 완료',
                  style: MITITextStyle.mdBold.copyWith(
                      color: valid && !isLoading ? MITIColor.gray800 : MITIColor.gray50),
                ),
              );
            },
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                UserShortInfoComponent.fromModel(
                  model: widget.userInfoModel,
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
                const Padding(
                  padding: EdgeInsets.only(bottom: (200)),
                  child: _ReviewForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> createReview(
      WidgetRef ref, BuildContext context, String nickname) async {
    BaseModel result;
    if (widget.participationId != null) {
      result = await ref.read(createGuestReviewProvider(
              gameId: widget.gameId, participationId: widget.participationId!)
          .future);
    } else {
      result = await ref.read(createHostReviewProvider(
        gameId: widget.gameId,
      ).future);
    }
    if (result is ErrorModel) {
      if (context.mounted) {
        final gameApiType = widget.participationId != null
            ? GameApiType.createGuestReview
            : GameApiType.createHostReview;
        WidgetsBinding.instance.addPostFrameCallback((s) {
          GameError.fromModel(model: result as ErrorModel)
              .responseError(context, gameApiType, ref);
        });
      }
    } else {
      ref
          .read(gamePlayersProvider(gameId: widget.gameId).notifier)
          .getPlayers(gameId: widget.gameId);
      if (context.mounted) {
        showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            builder: (context) {
              return BottomDialog(
                title: '리뷰 작성 완료',
                content: '$nickname 님의 리뷰를 작성하였습니다.',
                btn: TextButton(
                  onPressed: () {
                    context.pop();
                    context.pop();
                  },
                  child: const Text("확인"),
                ),
              );
            });
      }
    }
  }
}

class _ReviewForm extends ConsumerWidget {
  const _ReviewForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "자유로운 후기를 남겨주세요!",
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.r),
          Flexible(
              child: ConstrainedBox(
            constraints: BoxConstraints.tight(Size(double.infinity, 100.h)),
            child: MultiLineTextFormField(
              onChanged: (val) {
                ref.read(reviewFormProvider.notifier).updateComment(val);
              },
              hint: '리뷰를 작성해주세요.',
              context: context,
            ),
          )),
        ],
      ),
    );
  }
}

class MultiLineTextFormField extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final BuildContext context;
  final TextEditingController? editTextController;
  final FocusNode? focusNode;
  final VoidCallback? onTap;

  const MultiLineTextFormField(
      {super.key,
      this.onChanged,
      required this.hint,
      required this.context,
      this.editTextController,
      this.focusNode,
      this.onTap});

  @override
  State<MultiLineTextFormField> createState() => _MultiLineTextFormFieldState();
}

class _MultiLineTextFormFieldState extends State<MultiLineTextFormField> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      onVisibilityChange: (bool isKeyboardVisible) {},
      child: Align(
        child: RawScrollbar(
          controller: _scrollController,
          thumbColor: MITIColor.gray500,
          crossAxisMargin: 4.w,
          thickness: 2.w,
          radius: Radius.circular(100.r),
          trackVisibility: true,
          child: TextField(
              scrollController: _scrollController,
              focusNode: widget.focusNode,
              controller: widget.editTextController,
              onTap: widget.onTap,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              autocorrect: true,
              expands: true,
              style: MITITextStyle.sm150.copyWith(
                color: MITIColor.gray100,
              ),
              textAlignVertical: TextAlignVertical.top,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                // constraints: BoxConstraints(
                //   minHeight: 68.h,
                //   maxHeight: 200.h,
                // ),
                hintText: widget.hint,
                hintStyle:
                    MITITextStyle.sm150.copyWith(color: MITIColor.gray500),
                hintMaxLines: 10,
                fillColor: MITIColor.gray700,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                // isDense: true,
              )),
        ),
      ),
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
    final chips = PlayerReviewTagType.values.toList();

    final selected = ref.watch(selectedProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 점이 좋았나요? (최소 2개)',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.r),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...chips.map((e) => Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final tags = ref.watch(
                          reviewFormProvider.select((form) => form.tags));

                      return ReviewChip(
                          selected: tags.contains(e),
                          onTap: () {
                            ref.read(reviewFormProvider.notifier).updateChip(e);
                          },
                          title: e.name);
                    },
                  ))
            ],
          ),
        ],
      ),
    );
  }
}

class ReviewChip extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String title;

  const ReviewChip(
      {super.key,
      required this.selected,
      required this.onTap,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
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
        ),
        // alignment: Alignment(0,0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: MITITextStyle.smSemiBold.copyWith(
                color: selected ? MITIColor.gray800 : MITIColor.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
