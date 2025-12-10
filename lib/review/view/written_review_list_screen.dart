import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/dispose_sliver_cursor_pagination_list_view.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../theme/color_theme.dart';
import '../../user/param/user_profile_param.dart';
import '../../user/provider/user_pagination_provider.dart';
import '../../user/provider/user_provider.dart';
import '../component/skeleton/written_review_list_skeleton.dart';
import '../model/v2/base_written_review_response.dart';
import 'my_review_detail_screen.dart';
import 'review_list_screen.dart';

class WrittenReviewListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'writtenReviewList';

  const WrittenReviewListScreen({super.key});

  @override
  ConsumerState<WrittenReviewListScreen> createState() =>
      _WrittenReviewListScreenState();
}

class _WrittenReviewListScreenState
    extends ConsumerState<WrittenReviewListScreen> {
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
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                isSliver: true,
                title: '내가 작성한 리뷰',
                hasBorder: false,
              )
            ];
          },
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              DisposeSliverCursorPaginationListView(
                provider: userWrittenReviewsPProvider(
                    PaginationStateParam(path: userId)),
                itemBuilder: (BuildContext context, int index, Base pModel) {
                  final model = (pModel as BaseWrittenReviewResponse);
                  return ReviewCard.fromWrittenModel(
                    model: pModel,
                    onTap: () {
                      final Map<String, String> pathParameters = {
                        "reviewId": model.reviewId.toString()
                      };

                      final Map<String, String> queryParameters = {
                        'userReviewType': UserReviewType.written.value,
                        'reviewType': model.reviewType.value,
                      };

                      context.pushNamed(
                        MyReviewDetailScreen.routeName,
                        pathParameters: pathParameters,
                        queryParameters: queryParameters,
                      );
                    },
                  );
                },
                skeleton: const WrittenReviewListSkeleton(),
                param: UserReviewParam(),
                controller: _scrollController,
                separateSize: 4,
                emptyWidget: Container(
                  color: MITIColor.gray750,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '작성하신 리뷰가 없습니다.',
                        style: MITITextStyle.xxl140.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        '경기에 참여하시고 리뷰를 작성해 주세요!',
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
