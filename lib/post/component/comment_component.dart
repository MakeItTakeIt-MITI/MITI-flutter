import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/post/provider/post_comment_provider.dart';

import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../report/view/report_list_screen.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../error/post_error.dart';
import '../model/base_post_comment_response.dart';
import '../provider/post_bottom_sheet_button.dart';
import '../view/post_comment_detail_screen.dart';
import '../view/post_comment_form_screen.dart';
import 'comment_card.dart';

class CommentComponent extends ConsumerWidget {
  final int postId;
  final List<BasePostCommentResponse> comments;

  const CommentComponent(
      {super.key, required this.comments, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider)?.id;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "댓글",
            style: MITITextStyle.smBold.copyWith(color: MITIColor.gray100),
          ),
          SizedBox(height: 10.h),
          if (comments.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25.h),
              child: Text(
                "아직 댓글이 없습니다!\n가장 먼저 댓글을 작성해보세요!",
                style: MITITextStyle.sm150.copyWith(color: MITIColor.gray300),
                textAlign: TextAlign.center,
              ),
            ),
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, idx) {
                return InkWell(
                  onTap: () {
                    Map<String, String> pathParameters = {
                      'postId': postId.toString(),
                      'commentId': comments[idx].id.toString(),
                    };
                    context.pushNamed(
                      PostCommentDetailScreen.routeName,
                      pathParameters: pathParameters,
                    );
                  },
                  highlightColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  child: CommentCard.fromModel(
                    postId: postId,
                    model: comments[idx],
                    onTap: () {
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (_) {
                            return PostBottomSheetButton(
                              isWriter: comments[idx].writer.id == userId,
                              onDelete: () async {
                                final result = await ref.read(
                                    postCommentDeleteProvider(
                                            postId: postId,
                                            commentId: comments[idx].id)
                                        .future);

                                if (result is! ErrorModel) {
                                  context.pop();
                                } else {
                                  PostError.fromModel(model: result)
                                      .responseError(context,
                                          PostApiType.deleteComment, ref);
                                }
                              },
                              onUpdate: () {
                                context.pop();
                                // 댓글 수정
                                Map<String, String> pathParameters = {
                                  'postId': postId.toString(),
                                  'commentId': comments[idx].id.toString(),
                                };
                                context.pushNamed(
                                  PostCommentFormScreen.routeName,
                                  pathParameters: pathParameters,
                                );
                              },
                              onReport: () {
                                // 댓글 신고
                                Map<String, String> queryParameters = {
                                  'userId': comments[idx].writer.id.toString(),
                                };
                                context.pop();
                                context.pushNamed(
                                  ReportListScreen.routeName,
                                  queryParameters: queryParameters,
                                  extra: ReportCategoryType.user_report,
                                );
                              },
                            );
                          });
                    },
                  ),
                );
              },
              separatorBuilder: (_, idx) => Divider(
                    color: MITIColor.gray700,
                    height: 20.h,
                    thickness: 1.h,
                  ),
              itemCount: comments.length)
        ],
      ),
    );
  }
}
