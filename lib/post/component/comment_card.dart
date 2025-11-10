import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/post/component/post_writer_info.dart';
import 'package:miti/post/component/reply_comment_component.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../report/view/report_list_screen.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../user/model/v2/base_user_response.dart';
import '../error/post_error.dart';
import '../model/base_post_comment_response.dart';
import '../model/base_reply_comment_response.dart';
import '../provider/post_bottom_sheet_button.dart';
import '../provider/post_comment_provider.dart';
import '../provider/post_reply_comment_provider.dart';
import '../view/post_comment_form_screen.dart';
import 'comment_util_button.dart';

class CommentCard extends ConsumerStatefulWidget {
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
      required int replyCommentId,
      required VoidCallback onTap}) {
    return CommentCard(
      content: model.content,
      createdAt: model.createdAt.toString(),
      writer: model.writer,
      images: model.images,
      likedUsers: model.likedUsers,
      commentId: commentId,
      postId: postId,
      replyCommentId: replyCommentId,
      onTap: onTap,
    );
  }

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authProvider)?.id;
    final isSelected = widget.likedUsers.contains(userId);
    final isComment = widget.replyCommentId == null;

    return Column(
      children: [
        PostWriterInfo.fromModel(
          model: widget.writer,
          createdAt: widget.createdAt,
          isAnonymous: false,
          onTap: widget.onTap,
        ),
        Padding(
          padding: EdgeInsets.only(left: 40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Linkify(
                onOpen: _onOpen,
                text: widget.content,
                style: MITITextStyle.xxsm.copyWith(color: MITIColor.gray100),
                options: const LinkifyOptions(
                  humanize: false,
                  removeWww: false,
                ),
              ),
              SizedBox(height: 7.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.images
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
              Row(
                children: [
                  CommentUtilButton(
                    icon: 'good',
                    title: '좋아요',
                    cnt: widget.likedUsers.length,
                    isSelected: isSelected,
                    onTap: () async {
                      if (isSelected) {
                        if (isComment) {
                          final result = await ref.read(
                              postCommentUnLikeProvider(
                                      commentId: widget.commentId,
                                      postId: widget.postId)
                                  .future);
                          if (result is ErrorModel) {
                            PostError.fromModel(model: result).responseError(
                                context, PostApiType.unLikeComment, ref);
                          }
                        } else {
                          final result = await ref.read(
                              postReplyCommentUnLikeProvider(
                                      commentId: widget.commentId,
                                      postId: widget.postId,
                                      replyCommentId: widget.replyCommentId!,
                                      fromDetail: true)
                                  .future);
                          if (result is ErrorModel) {
                            PostError.fromModel(model: result).responseError(
                                context, PostApiType.unLikeReplyComment, ref);
                          }
                        }
                      } else {
                        if (isComment) {
                          final result = await ref.read(postCommentLikeProvider(
                                  commentId: widget.commentId,
                                  postId: widget.postId)
                              .future);
                          if (result is ErrorModel) {
                            PostError.fromModel(model: result).responseError(
                                context, PostApiType.likeComment, ref);
                          }
                        } else {
                          final result = await ref.read(
                              postReplyCommentLikeProvider(
                                      commentId: widget.commentId,
                                      postId: widget.postId,
                                      replyCommentId: widget.replyCommentId!,
                                      fromDetail: true)
                                  .future);
                          if (result is ErrorModel) {
                            PostError.fromModel(model: result).responseError(
                                context, PostApiType.likeReplyComment, ref);
                          }
                        }
                      }
                    },
                  ),
                  SizedBox(width: 15.w),
                  if (widget.replyComments != null)
                    CommentUtilButton(
                      icon: 'comments',
                      title: '대댓글',
                      cnt: widget.replyComments!.length,
                    ),
                ],
              ),
              if (widget.replyComments != null)
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, idx) {
                    return ReplyCommentComponent.fromModel(
                      model: widget.replyComments![idx],
                      commentId: widget.commentId,
                      postId: widget.postId,
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (_) {
                              return PostBottomSheetButton(
                                isWriter:
                                    widget.replyComments![idx].writer.id ==
                                        userId,
                                onDelete: () async {
                                  final result = await ref.read(
                                      postReplyCommentDeleteProvider(
                                              postId: widget.postId,
                                              commentId: widget.commentId,
                                              replyCommentId:
                                                  widget.replyComments![idx].id)
                                          .future);

                                  if (result is! ErrorModel) {
                                    context.pop();
                                  } else {
                                    PostError.fromModel(model: result)
                                        .responseError(
                                            context,
                                            PostApiType.deleteReplyComment,
                                            ref);
                                  }
                                },
                                onUpdate: () {
                                  log("reply navigation");
                                  context.pop();
                                  // // 대댓글 수정
                                  Map<String, String> pathParameters = {
                                    'postId': widget.postId.toString(),
                                    'commentId': widget.commentId.toString(),
                                  };
                                  Map<String, String> queryParameters = {
                                    'replyCommentId':
                                        widget.replyComments![idx].id.toString()
                                  };
                                  context.pushNamed(
                                      PostCommentFormScreen.routeName,
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters);
                                },
                                onReport: () {
                                  // // 대댓글 신고
                                  Map<String, String> queryParameters = {
                                    'replyCommentId': widget
                                        .replyComments![idx].id
                                        .toString(),
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
                    );
                  },
                  separatorBuilder: (_, idx) => SizedBox(
                    height: 8.h,
                  ),
                  itemCount: widget.replyComments!.length,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
