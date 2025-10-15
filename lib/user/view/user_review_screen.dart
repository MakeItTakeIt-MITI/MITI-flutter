import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/custom_drop_down_button.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_pagination_provider.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/component/dispose_sliver_cursor_pagination_list_view.dart';
import '../../common/model/default_model.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/cursor_pagination_provider.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../review/model/v2/base_received_review_response.dart';
import '../../review/model/v2/base_written_review_response.dart';
import '../param/user_profile_param.dart';

class UserWrittenReviewScreen extends ConsumerStatefulWidget {
  final UserReviewType type;
  final int bottomIdx;

  static String get routeName => 'review';

  const UserWrittenReviewScreen({
    super.key,
    required this.type,
    required this.bottomIdx,
  });

  @override
  ConsumerState<UserWrittenReviewScreen> createState() =>
      _UserWrittenReviewScreenState();
}

class _UserWrittenReviewScreenState
    extends ConsumerState<UserWrittenReviewScreen> {
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

  ReviewType? getReviewType(String? value) {
    switch (value) {
      case '호스트리뷰':
        return ReviewType.host_review;
      case '게스트리뷰':
        return ReviewType.guest_review;
      default:
        return null;
    }
  }

  Future<void> refresh() async {
    final id = ref.read(authProvider)!.id!;
    final reviewType =
        getReviewType(ref.read(dropDownValueProvider(DropButtonType.review)));
    final provider = widget.type == UserReviewType.written
        ? userWrittenReviewsPProvider(PaginationStateParam(path: id))
        : userReceiveReviewsPProvider(PaginationStateParam(path: id))
            as AutoDisposeStateNotifierProvider<
                CursorPaginationProvider<Base, DefaultParam,
                    IBaseCursorPaginationRepository<Base, DefaultParam>>,
                BaseModel>;
    ref.read(provider.notifier).paginate(
          path: id,
          forceRefetch: true,
          param: UserReviewParam(
            review_type: reviewType,
          ),
          cursorPaginationParams: const CursorPaginationParam(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      '호스트리뷰',
      '게스트리뷰',
      '전체 보기',
    ];

    final id = ref.watch(authProvider)!.id!;

    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              DefaultAppBar(
                title: widget.type == UserReviewType.written ? '작성 리뷰' : '내 리뷰',
                isSliver: true,
              )
            ];
          },
          body: RefreshIndicator(
            onRefresh: refresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: 14.w, top: 14.h, bottom: 14.h),
                    child: Row(
                      children: [
                        const Spacer(),
                        CustomDropDownButton(
                          initValue: '전체 보기',
                          onChanged: (value) {
                            changeDropButton(value, id);
                          },
                          items: items,
                          type: DropButtonType.review,
                        )
                      ],
                    ),
                  ),
                ),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final reviewType = getReviewType(ref
                        .watch(dropDownValueProvider(DropButtonType.review)));
                    final provider = widget.type == UserReviewType.written
                        ? userWrittenReviewsPProvider(
                                PaginationStateParam(path: id))
                            as AutoDisposeStateNotifierProvider<
                                CursorPaginationProvider<
                                    Base,
                                    DefaultParam,
                                    IBaseCursorPaginationRepository<Base,
                                        DefaultParam>>,
                                BaseModel>
                        : userReceiveReviewsPProvider(
                            PaginationStateParam(path: id));
                    return SliverPadding(
                      padding: EdgeInsets.only(
                          right: 12.w, left: 12.w, bottom: 12.h),
                      sliver: DisposeSliverCursorPaginationListView(
                        provider: provider,
                        itemBuilder:
                            (BuildContext context, int index, Base pModel) {
                          if (widget.type == UserReviewType.written) {
                            pModel as BaseWrittenReviewResponse;
                            // return ReviewCard.fromWrittenModel(
                            //   model: pModel,
                            //   bottomIdx: widget.bottomIdx,
                            // );
                          } else {
                            pModel as BaseReceivedReviewResponse;
                            // return ReviewCard.fromReceiveModel(
                            //   model: pModel,
                            //   bottomIdx: widget.bottomIdx,
                            // );
                          }
                          return Container();
                        },
                        skeleton: Container(),
                        param: UserReviewParam(
                          review_type: reviewType,
                        ),
                        controller: _scrollController,
                        emptyWidget: getEmptyWidget(widget.type),
                      ),
                    );
                  },
                ),
              ],
            ),
          )),
    );
  }

  void changeDropButton(String? value, int id) {
    ref
        .read(dropDownValueProvider(DropButtonType.review).notifier)
        .update((state) => value);
    final reviewType = getReviewType(value);
    final provider = widget.type == UserReviewType.written
        ? userWrittenReviewsPProvider(PaginationStateParam(path: id))
        : userReceiveReviewsPProvider(PaginationStateParam(path: id))
            as AutoDisposeStateNotifierProvider<
                CursorPaginationProvider<Base, DefaultParam,
                    IBaseCursorPaginationRepository<Base, DefaultParam>>,
                BaseModel>;
    ref.read(provider.notifier).paginate(
          path: id,
          forceRefetch: true,
          param: UserReviewParam(
            review_type: reviewType,
          ),
          cursorPaginationParams: const CursorPaginationParam(),
        );
  }

  Widget getEmptyWidget(UserReviewType type) {
    final title = type == UserReviewType.written ? '작성하신' : '';
    final content = type == UserReviewType.written
        ? '경기에 참여하신 후 리뷰를 작성해주세요!'
        : '다른 사용자에게 먼저 리뷰를 작성해보세요!';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title 리뷰가 없습니다.',
          style: MITITextStyle.pageMainTextStyle,
        ),
        SizedBox(height: 20.h),
        Text(
          content,
          style: MITITextStyle.pageSubTextStyle,
        )
      ],
    );
  }
}
