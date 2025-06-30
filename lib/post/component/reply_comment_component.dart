import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/post/component/post_writer_info.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/model/default_model.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../user/model/v2/base_user_response.dart';
import '../error/post_error.dart';
import '../model/base_reply_comment_response.dart';
import '../provider/post_reply_comment_provider.dart';
import 'comment_util_button.dart';

class ReplyCommentComponent extends ConsumerWidget {
  final int commentId;
  final int postId;
  final int replyCommentId;
  final String content;
  final String createdAt;
  final BaseUserResponse writer;
  final List<String> images;
  final List<int> likedUsers;
  final VoidCallback onTap;

  const ReplyCommentComponent({
    super.key,
    required this.commentId,
    required this.postId,
    required this.replyCommentId,
    required this.content,
    required this.createdAt,
    required this.writer,
    required this.images,
    required this.likedUsers,
    required this.onTap,
  });

  factory ReplyCommentComponent.fromModel({
    required BaseReplyCommentResponse model,
    required int commentId,
    required int postId,
    required VoidCallback onTap,
  }) {
    return ReplyCommentComponent(
      replyCommentId: model.id,
      content: model.content,
      createdAt: model.createdAt.toString(),
      writer: model.writer,
      images: model.images,
      likedUsers: model.likedUsers,
      commentId: commentId,
      postId: postId,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider)?.id;
    final isSelected = likedUsers.contains(userId);
    return Column(
      children: [
        PostWriterInfo.fromModel(
          model: writer,
          createdAt: createdAt,
          isAnonymous: false,
          onTap: onTap,
        ),
        Padding(
          padding: EdgeInsets.only(left: 40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                content,
                style: MITITextStyle.xxsm.copyWith(color: MITIColor.gray100),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: images
                    .map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 7.h),
                  child: Image.network(
                    e,
                    fit: BoxFit.contain,
                    alignment: Alignment.topLeft,
                  ),
                ))
                    .toList(),
              ),
              SizedBox(height: 7.h),
              CommentUtilButton(
                icon: 'good',
                title: '좋아요',
                cnt: likedUsers.length,
                isSelected: isSelected,
                onTap: () async {
                  if (isSelected) {
                    final result = await ref.read(
                        postReplyCommentUnLikeProvider(
                                commentId: commentId,
                                postId: postId,
                                replyCommentId: replyCommentId)
                            .future);
                    if (result is ErrorModel) {
                      PostError.fromModel(model: result)
                          .responseError(context, PostApiType.unLikeReplyComment, ref);
                    }
                  } else {
                    final result = await ref.read(postReplyCommentLikeProvider(
                            commentId: commentId,
                            postId: postId,
                            replyCommentId: replyCommentId)
                        .future);
                    if (result is ErrorModel) {
                      PostError.fromModel(model: result)
                          .responseError(context, PostApiType.likeReplyComment, ref);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
