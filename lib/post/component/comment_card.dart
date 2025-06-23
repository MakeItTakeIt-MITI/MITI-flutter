import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/post/component/post_writer_info.dart';
import 'package:miti/post/component/reply_comment_component.dart';

import '../../auth/provider/auth_provider.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../user/model/v2/base_user_response.dart';
import '../model/base_post_comment_response.dart';
import '../model/base_reply_comment_response.dart';
import '../provider/post_comment_provider.dart';
import '../provider/post_reply_comment_provider.dart';
import '../view/post_detail_screen.dart';
import 'comment_util_button.dart';

class CommentCard extends ConsumerWidget {
  final int commentId;
  final int postId;
  final int? replyCommentId;
  final String content;
  final String createdAt;
  final BaseUserResponse writer;
  final List<String> images;
  final List<int> likedUsers;
  final List<BaseReplyCommentResponse>? replyComments;
  final VoidCallback? onTap;

  const CommentCard({
    super.key,
    required this.commentId,
    required this.postId,
    this.replyCommentId,
    required this.content,
    required this.createdAt,
    required this.writer,
    required this.images,
    required this.likedUsers,
    this.replyComments,
    this.onTap,
  });

  factory CommentCard.fromModel(
      {required BasePostCommentResponse model,
      required int postId,
      required VoidCallback onTap}) {
    return CommentCard(
      content: model.content,
      createdAt: model.createdAt.toString(),
      writer: model.writer,
      images: model.images,
      likedUsers: model.likedUsers,
      replyComments: model.replyComments,
      onTap: onTap,
      commentId: model.id,
      postId: postId,
    );
  }

  factory CommentCard.fromReplyModel(
      {required BaseReplyCommentResponse model,
      required int postId,
      required int commentId,
      required int replyCommentId}) {
    return CommentCard(
      content: model.content,
      createdAt: model.createdAt.toString(),
      writer: model.writer,
      images: model.images,
      likedUsers: model.likedUsers,
      commentId: commentId,
      postId: postId,
      replyCommentId: replyCommentId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider)?.id;
    final isSelected = likedUsers.contains(userId);
    final isComment = replyCommentId == null;

    return Column(
      children: [
        PostWriterInfo.fromModel(
          model: writer,
          createdAt: createdAt,
          isAnonymous: false,
          onTap: () {},
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
              // todo image 추가
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (_, idx) {
                    return Image.network(images[idx]);
                  },
                  separatorBuilder: (_, idx) => SizedBox(height: 7.h),
                  itemCount: images.length),
              SizedBox(height: 7.h),
              Row(
                children: [
                  CommentUtilButton(
                    icon: 'good',
                    title: '좋아요',
                    cnt: likedUsers.length,
                    isSelected: isSelected,
                    onTap: () async {
                      if (isSelected) {
                        if (isComment) {
                          ref.read(postCommentUnLikeProvider(
                                  commentId: commentId, postId: postId)
                              .future);
                        } else {
                          ref.read(postReplyCommentUnLikeProvider(
                                  commentId: commentId,
                                  postId: postId,
                                  replyCommentId: replyCommentId!,
                                  fromDetail: true)
                              .future);
                        }
                      } else {
                        if (isComment) {
                          ref.read(postCommentLikeProvider(
                                  commentId: commentId, postId: postId)
                              .future);
                        } else {
                          ref.read(postReplyCommentLikeProvider(
                                  commentId: commentId,
                                  postId: postId,
                                  replyCommentId: replyCommentId!,
                                  fromDetail: true)
                              .future);
                        }
                      }
                    },
                  ),
                  SizedBox(width: 15.w),
                  if (replyComments != null)
                    CommentUtilButton(
                      icon: 'comments',
                      title: '대댓글',
                      cnt: replyComments!.length,
                    ),
                ],
              ),
              if (replyComments != null)
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, idx) {
                    return ReplyCommentComponent.fromModel(
                      model: replyComments![idx],
                      commentId: commentId,
                      postId: postId,
                    );
                  },
                  separatorBuilder: (_, idx) => SizedBox(
                    height: 8.h,
                  ),
                  itemCount: replyComments!.length,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
