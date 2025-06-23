import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../model/base_post_comment_response.dart';
import '../view/post_comment_detail_screen.dart';
import 'comment_card.dart';

class CommentComponent extends StatelessWidget {
  final int postId;
  final List<BasePostCommentResponse> comments;

  const CommentComponent(
      {super.key, required this.comments, required this.postId});

  @override
  Widget build(BuildContext context) {
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
                      // todo 더보기 클릭 시
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
