import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/post/component/comment_card.dart';
import 'package:miti/post/provider/post_comment_provider.dart';
import 'package:miti/post/view/post_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/default_appbar.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../component/comment_form.dart';
import '../component/comment_util_button.dart';
import '../component/post_writer_info.dart';
import '../model/base_post_comment_response.dart';
import '../model/base_reply_comment_response.dart';
import '../provider/post_reply_comment_provider.dart';

class PostCommentDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'postCommentDetail';
  final int postId;
  final int commentId;

  const PostCommentDetailScreen({
    super.key,
    required this.postId,
    required this.commentId,
  });

  @override
  ConsumerState<PostCommentDetailScreen> createState() =>
      _PostCommentDetailScreenState();
}

class _PostCommentDetailScreenState
    extends ConsumerState<PostCommentDetailScreen> {
  late final TextEditingController textController;
  late final FocusNode focusNode;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    scrollController = ScrollController();
    scrollController.addListener(() {});
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(postCommentDetailProvider(
        postId: widget.postId, commentId: widget.commentId));
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      return CircularProgressIndicator();
    }

    final model = (result as ResponseModel<BasePostCommentResponse>).data!;

    return Scaffold(
      appBar: DefaultAppBar(
        title: '댓글',
        backgroundColor: MITIColor.gray900,
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: 'more'),
              width: 24.r,
              height: 24.r,
              colorFilter:
                  const ColorFilter.mode(MITIColor.gray100, BlendMode.srcIn),
            ),
          )
        ],
      ),
      backgroundColor: MITIColor.gray900,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  CommentInfoComponent(
                    postId: widget.postId,
                    commentId: widget.commentId,
                    model: model,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 11.5.w),
                    child: Container(
                      width: double.infinity,
                      height: 78.h,
                      color: MITIColor.gray400,
                      child: Text("광고 섹션"),
                    ),
                  ),
                  _ReplyCommentComponent(
                    replyComments: model.replyComments,
                    postId: widget.postId,
                    commentId: widget.commentId,
                  ),
                ],
              ),
            ),
          ),
          PostCommentForm(
            textController: textController,
            sendMessage: () async {
              final result = await ref.read(postReplyCommentCreateProvider(
                      postId: widget.postId, commentId: widget.commentId)
                  .future);
              if (result is! ErrorModel) {
                textController.clear();
                FlashUtil.showFlash(context, '대댓글 작성이 완료되었습니다');
                Future.delayed(
                    const Duration(milliseconds: 200),
                    () => {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                        });
              }
            },
            focusNode: focusNode,
          )
        ],
      ),
    );
  }
}

class CommentInfoComponent extends ConsumerWidget {
  final int postId;
  final int commentId;
  final BasePostCommentResponse model;

  const CommentInfoComponent({
    super.key,
    required this.postId,
    required this.commentId,
    required this.model,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider)?.id;
    final isSelected = model.likedUsers.contains(userId);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostWriterInfo.fromModel(
            model: model.writer,
            createdAt: model.createdAt.toString(),
            isAnonymous: false,
          ),
          SizedBox(height: 25.h),
          Text(
            model.content,
            style: MITITextStyle.xxsm.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10.h),
              itemBuilder: (_, idx) {
                return Image.network(model.images[idx]);
              },
              separatorBuilder: (_, idx) => SizedBox(height: 7.h),
              itemCount: model.images.length),
          SizedBox(height: 25.h),
          CommentUtilButton(
            icon: 'good',
            title: '좋아요',
            cnt: model.likedUsers.length,
            isSelected: isSelected,
            onTap: () async {
              if (isSelected) {
                ref.read(postCommentUnLikeProvider(
                        commentId: commentId,
                        postId: postId,
                        fromCommentDetail: true)
                    .future);
              } else {
                ref.read(postCommentLikeProvider(
                        commentId: commentId,
                        postId: postId,
                        fromCommentDetail: true)
                    .future);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ReplyCommentComponent extends StatelessWidget {
  final int postId;
  final int commentId;
  final List<BaseReplyCommentResponse> replyComments;

  const _ReplyCommentComponent(
      {super.key,
      required this.replyComments,
      required this.postId,
      required this.commentId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              "대댓글",
              style: MITITextStyle.smBold.copyWith(
                color: MITIColor.gray100,
              ),
            ),
          ),
          if (replyComments.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 25.h),
              child: Text(
                "가장 먼저 댓글을 작성해보세요!",
                style: MITITextStyle.sm150.copyWith(color: MITIColor.gray300),
                textAlign: TextAlign.center,
              ),
            ),
          ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 12.h),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, idx) {
                return CommentCard.fromReplyModel(
                  postId: postId,
                  commentId: commentId,
                  model: replyComments[idx],
                  replyCommentId: replyComments[idx].id,
                );
              },
              separatorBuilder: (_, idx) => Divider(
                    color: MITIColor.gray700,
                    height: 20.h,
                    thickness: 1.h,
                  ),
              itemCount: replyComments.length)
        ],
      ),
    );
  }
}
