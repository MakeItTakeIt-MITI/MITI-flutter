import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/post/component/comment_card.dart';
import 'package:miti/post/component/comment_form.dart';
import 'package:miti/post/provider/post_comment_provider.dart';
import 'package:miti/post/view/post_comment_form_screen.dart';
import 'package:miti/post/view/post_detail_screen.dart';
import 'package:miti/support/provider/random_advertise_provider.dart';
import 'package:miti/support/view/advertise_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/component/defalut_flashbar.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/v2/advertisement/base_advertisement_response.dart';
import '../../report/view/report_list_screen.dart';
import '../../theme/text_theme.dart';
import '../../util/image_upload_util.dart';
import '../../util/util.dart';
import '../component/comment_util_button.dart';
import '../component/post_writer_info.dart';
import '../error/post_error.dart';
import '../model/base_post_comment_response.dart';
import '../model/base_reply_comment_response.dart';
import '../provider/post_bottom_sheet_button.dart';
import '../provider/post_comment_form_provider.dart';
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
  late ImageUploadUtil _imageUploadUtil;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    scrollController = ScrollController();
    scrollController.addListener(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _imageUploadUtil = ImageUploadUtil(
      ref: ref,
      context: context,
      callback: PostCommentFormImageUploadAdapter(
        ref: ref,
        postId: widget.postId,
        commentId: widget.commentId,
        // replyCommentId는 null (새 대댓글 작성이므로)
      ),
    );
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
      return const Center(child: CircularProgressIndicator());
    } else if (result is ErrorModel) {
      PostError.fromModel(model: result)
          .responseError(context, PostApiType.getCommentDetail, ref);
      return const Center(child: CircularProgressIndicator());
    }

    final model = (result as ResponseModel<BasePostCommentResponse>).data!;
    final userId = ref.watch(authProvider)?.id;

    return Scaffold(
      appBar: DefaultAppBar(
        title: '댓글',
        backgroundColor: MITIColor.gray900,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (_) {
                    return PostBottomSheetButton(
                      isWriter: model.writer.id == userId,
                      onDelete: () async {
                        final result = await ref.read(postCommentDeleteProvider(
                                postId: widget.postId,
                                commentId: widget.commentId)
                            .future);

                        if (result is! ErrorModel) {
                          Map<String, String> pathParameters = {
                            'postId': widget.postId.toString()
                          };
                          context.pushNamed(PostDetailScreen.routeName,
                              pathParameters: pathParameters);
                        } else {
                          PostError.fromModel(model: result).responseError(
                              context, PostApiType.deleteComment, ref);
                        }
                      },
                      onUpdate: () {
                        context.pop();
                        // 댓글 수정
                        Map<String, String> pathParameters = {
                          'postId': widget.postId.toString(),
                          'commentId': widget.commentId.toString(),
                        };
                        context.pushNamed(
                          PostCommentFormScreen.routeName,
                          pathParameters: pathParameters,
                        );
                      },
                      onReport: () {
                        Map<String, String> queryParameters = {
                          'userId': model.writer.id.toString(),
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
            child: RefreshIndicator(
              onRefresh: refresh,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: scrollController,
                child: Column(
                  children: [
                    CommentInfoComponent(
                      postId: widget.postId,
                      commentId: widget.commentId,
                      model: model,
                    ),
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final result = ref.watch(randomAdvertiseProvider);
                        if (result is LoadingModel) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (result is ErrorModel) {
                          // todo advertise error
                          // PostError.fromModel(model: result).responseError(
                          //     context, PostApiType.deleteComment, ref);
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final model =
                            (result as ResponseModel<BaseAdvertisementResponse>)
                                .data!;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 11.5.w),
                          child: GestureDetector(
                            onTap: () {
                              Map<String, String> pathParameters = {
                                'advertisementId': model.id.toString()
                              };
                              context.pushNamed(AdvertiseDetailScreen.routeName,
                                  pathParameters: pathParameters);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Container(
                                width: double.infinity,
                                height: 78.h,
                                decoration: BoxDecoration(
                                  color: MITIColor.gray400,
                                  image: DecorationImage(
                                    image:
                                        NetworkImage(model.thumbnailImageUrl),
                                  ),
                                ),
                                // child: Text("광고 섹션"),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _ReplyCommentComponent(
                      replyComments: model.replyComments,
                      postId: widget.postId,
                      commentId: widget.commentId,
                      userId: userId,
                    ),
                  ],
                ),
              ),
            ),
          ), // todo 폼 수정
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final commentForm = ref.watch(postCommentFormProvider(
                postId: widget.postId,
                commentId: widget.commentId,
                // replyCommentId는 null (새 대댓글 작성)
              ));

              return PostCommentFormComponent(
                focusNode: focusNode,
                textController: textController,
                content: commentForm.content,
                localImages: commentForm.localImages,
                onContentChanged: (content) {
                  ref
                      .read(postCommentFormProvider(
                        postId: widget.postId,
                        commentId: widget.commentId,
                      ).notifier)
                      .update(content: content);
                },
                onImageDelete: (imagePath) {
                  ref
                      .read(postCommentFormProvider(
                        postId: widget.postId,
                        commentId: widget.commentId,
                      ).notifier)
                      .removeLocalImage(imagePath);
                },
                sendMessage: () async {
                  // 이미지 설정 (업로드된 이미지 URL을 images 배열에 복사)
                  ref
                      .read(postCommentFormProvider(
                        postId: widget.postId,
                        commentId: widget.commentId,
                      ).notifier)
                      .setImages();

                  final result = await ref.read(postReplyCommentCreateProvider(
                          postId: widget.postId, commentId: widget.commentId)
                      .future);
                  if (result is! ErrorModel) {
                    textController.clear();
                    // 대댓글 작성 후 폼 상태 완전 초기화
                    ref
                        .read(postCommentFormProvider(
                          postId: widget.postId,
                          commentId: widget.commentId,
                        ).notifier)
                        .reset();

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
                  } else {
                    PostError.fromModel(model: result).responseError(
                        context, PostApiType.createReplyComment, ref);
                  }
                },
                onGallery: () async {
                  final limit = ref
                      .read(postCommentFormProvider(
                        postId: widget.postId,
                        commentId: widget.commentId,
                      ).notifier)
                      .getLimitImageCnt();
                  // 갤러리 기능 구현
                  await _imageUploadUtil.pickMultipleImages(limit: limit);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> refresh() async {
    ref
        .read(postCommentDetailProvider(
                postId: widget.postId, commentId: widget.commentId)
            .notifier)
        .get(postId: widget.postId, commentId: widget.commentId);
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(height: 10.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: model.images
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
          SizedBox(height: 25.h),
          CommentUtilButton(
            icon: 'good',
            title: '좋아요',
            cnt: model.likedUsers.length,
            isSelected: isSelected,
            onTap: () async {
              if (isSelected) {
                final result = await ref.read(postCommentUnLikeProvider(
                        commentId: commentId,
                        postId: postId,
                        fromCommentDetail: true)
                    .future);
                if (result is ErrorModel) {
                  PostError.fromModel(model: result)
                      .responseError(context, PostApiType.unLikeComment, ref);
                }
              } else {
                final result = await ref.read(postCommentLikeProvider(
                        commentId: commentId,
                        postId: postId,
                        fromCommentDetail: true)
                    .future);
                if (result is ErrorModel) {
                  PostError.fromModel(model: result)
                      .responseError(context, PostApiType.likeComment, ref);
                }
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
  final int? userId;

  const _ReplyCommentComponent(
      {super.key,
      required this.replyComments,
      required this.postId,
      required this.commentId,
      this.userId});

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
                  onTap: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (_) {
                          return Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              return PostBottomSheetButton(
                                isWriter:
                                    replyComments[idx].writer.id == userId,
                                onDelete: () async {
                                  final result = await ref.read(
                                      postReplyCommentDeleteProvider(
                                              postId: postId,
                                              commentId: commentId,
                                              replyCommentId:
                                                  replyComments[idx].id)
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
                                  context.pop();
                                  // 대댓글 수정
                                  Map<String, String> pathParameters = {
                                    'postId': postId.toString(),
                                    'commentId': commentId.toString(),
                                  };
                                  Map<String, String> queryParameters = {
                                    'replyCommentId':
                                        replyComments[idx].id.toString()
                                  };
                                  context.pushNamed(
                                      PostCommentFormScreen.routeName,
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters);
                                },
                                onReport: () {
                                  Map<String, String> queryParameters = {
                                    'userId':
                                        replyComments[idx].writer.id.toString(),
                                  };
                                  context.pop();
                                  context.pushNamed(
                                    ReportListScreen.routeName,
                                    queryParameters: queryParameters,
                                    extra: ReportCategoryType.user_report,
                                  );
                                },
                              );
                            },
                          );
                        });
                  },
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
