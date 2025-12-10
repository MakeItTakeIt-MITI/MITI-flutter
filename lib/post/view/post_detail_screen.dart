import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/post/component/post_category.dart';
import 'package:miti/post/provider/post_comment_provider.dart';
import 'package:miti/post/provider/post_provider.dart';
import 'package:miti/post/view/post_form_screen.dart';
import 'package:miti/post/view/post_list_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/component/defalut_flashbar.dart';
import '../../report/view/report_list_screen.dart';
import '../../util/image_upload_util.dart';
import '../../util/util.dart';
import '../component/comment_component.dart';
import '../component/comment_form.dart';
import '../component/post_writer_info.dart';
import '../error/post_error.dart';
import '../model/base_post_comment_response.dart';
import '../model/post_response.dart';
import '../provider/post_bottom_sheet_button.dart';
import '../provider/post_comment_form_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'postDetail';
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  late final TextEditingController textController;
  late final FocusNode focusNode;
  late final FocusNode contentFocusNode;
  late final ScrollController scrollController;
  late ImageUploadUtil _imageUploadUtil;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
    contentFocusNode = FocusNode();
    scrollController = ScrollController();
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
        // commentId와 replyCommentId는 필요에 따라 설정
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    contentFocusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (!await launchUrl(Uri.parse(link.url))) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(postDetailProvider(postId: widget.postId));

    log("rresult type = ${result.runtimeType}");
    if (result is LoadingModel) {
      return const Center(child: CircularProgressIndicator());
    } else if (result is ErrorModel) {
      PostError.fromModel(model: result)
          .responseError(context, PostApiType.getDetail, ref);
      return const Center(child: CircularProgressIndicator());
    }
    final model = (result as ResponseModel<PostResponse>).data!;

    final userId = ref.watch(authProvider)?.id;
    final isSelected = model.likedUsers.contains(userId);

    return Scaffold(
      appBar: DefaultAppBar(
        hasBorder: false,
        backgroundColor: MITIColor.gray900,
        actions: [
          IconButton(
            onPressed: () {
              showPostBottomSheet(context, model);
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
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    /// 게시글 영역
                    SelectableRegion(
                      focusNode: contentFocusNode,
                      selectionControls: materialTextSelectionControls,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 15.h, bottom: 30.h, left: 14.w, right: 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PostCategory(category: model.category),
                            SizedBox(height: 10.h),
                            PostWriterInfo.fromModel(
                              model: model.writer,
                              createdAt: model.createdAt,
                              isAnonymous: model.isAnonymous,
                            ),
                            SizedBox(height: 25.h),
                            Linkify(
                              onOpen: _onOpen,
                              text: model.title,
                              style: MITITextStyle.mdSemiBold150
                                  .copyWith(color: MITIColor.gray50),
                              options: const LinkifyOptions(
                                humanize: false,
                                removeWww: false,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Linkify(
                              onOpen: _onOpen,
                              text: model.content,
                              style: MITITextStyle.sm150
                                  .copyWith(color: MITIColor.gray50),
                              options: const LinkifyOptions(
                                humanize: false,
                                removeWww: false,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: model.images
                                  .map((e) => Padding(
                                        padding: EdgeInsets.only(bottom: 5.h),
                                        child: Image.network(
                                          e,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.topLeft,
                                          // 너비에 맞추고 높이는 비율에 따라 자동 조정
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              height: 200.h,
                                              color: MITIColor.gray700,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              height: 200.h,
                                              color: MITIColor.gray700,
                                              child: const Icon(
                                                Icons.error,
                                                color: V2MITIColor.red5,
                                              ),
                                            );
                                          },
                                        ),
                                      ))
                                  .toList(),
                            )
                          ],
                        ),
                      ),
                    ),
                    PostUtilComponent(
                      likedUsers: model.likedUsers,
                      onLikeTap: () async {
                        if (isSelected) {
                          final result = await ref.read(
                              postUnLikeProvider(postId: widget.postId).future);
                          if (result is ErrorModel) {
                            PostError.fromModel(model: result).responseError(
                                context, PostApiType.unLikePost, ref);
                          }
                        } else {
                          final result = await ref.read(
                              postLikeProvider(postId: widget.postId).future);
                          if (result is ErrorModel) {
                            PostError.fromModel(model: result).responseError(
                                context, PostApiType.likePost, ref);
                          }
                        }
                      },
                      onShareTap: () async {
                        final result = await Share.shareUri(Uri(
                          scheme: 'https',
                          host: "www.makeittakeit.kr",
                          path: '/post/${widget.postId}',
                        ));
                      },
                      isSelected: isSelected,
                    ),

                    /// 댓글 영역
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final result = ref.watch(
                            postCommentListProvider(postId: widget.postId));
                        if (result is LoadingModel) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (result is ErrorModel) {
                          PostError.fromModel(model: result).responseError(
                              context, PostApiType.getCommentList, ref);
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final model = (result
                                as ResponseListModel<BasePostCommentResponse>)
                            .data!;
                        return CommentComponent(
                          comments: model,
                          postId: widget.postId,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final commentForm =
                  ref.watch(postCommentFormProvider(postId: widget.postId));

              return PostCommentFormComponent(
                // 필수 파라미터들
                focusNode: focusNode,
                textController: textController,

                // 데이터 파라미터들
                content: commentForm.content,
                localImages: commentForm.localImages,

                // 콜백 파라미터들
                onContentChanged: (content) {
                  log("text = $content");
                  ref
                      .read(postCommentFormProvider(postId: widget.postId)
                          .notifier)
                      .update(content: content);
                },
                onImageDelete: (imagePath) {
                  ref
                      .read(postCommentFormProvider(postId: widget.postId)
                          .notifier)
                      .removeLocalImage(imagePath);
                },
                sendMessage: () async {
                  // 이미지 설정 (업로드된 이미지 URL을 images 배열에 복사)
                  ref
                      .read(postCommentFormProvider(postId: widget.postId)
                          .notifier)
                      .setImages();

                  final result = await ref.read(
                      postCommentCreateProvider(postId: widget.postId).future);
                  if (result is! ErrorModel) {
                    textController.clear();
                    // 댓글 작성 후 폼 상태 완전 초기화
                    ref
                        .read(postCommentFormProvider(postId: widget.postId)
                            .notifier)
                        .reset();

                    FlashUtil.showFlash(context, '댓글 작성이 완료되었습니다');
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
                    PostError.fromModel(model: result)
                        .responseError(context, PostApiType.createComment, ref);
                  }
                },
                onGallery: () async {
                  final limit = ref
                      .read(postCommentFormProvider(postId: widget.postId)
                          .notifier)
                      .getLimitImageCnt();
                  // 갤러리 기능 구현
                  await _imageUploadUtil.pickMultipleImages(limit: limit, category: FileCategoryType.comment_image);
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
        .read(postDetailProvider(postId: widget.postId).notifier)
        .get(postId: widget.postId);
  }

  void showPostBottomSheet(BuildContext context, PostResponse model) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (_) {
          return PostBottomSheetButton(
            isWriter: model.isWriter,
            onDelete: () async {
              final result = await ref
                  .read(postDeleteProvider(postId: widget.postId).future);

              if (result is! ErrorModel) {
                context.goNamed(PostListScreen.routeName);
              } else {
                PostError.fromModel(model: result)
                    .responseError(context, PostApiType.deletePost, ref);
              }
            },
            onUpdate: () {
              context.pop();
              Map<String, String> queryParameters = {
                'postId': widget.postId.toString()
              };
              context.pushNamed(PostFormScreen.routeName,
                  queryParameters: queryParameters);
            },
            onReport: () {
              Map<String, String> queryParameters = {
                'postId': widget.postId.toString(),
              };
              context.pop();
              context.pushNamed(
                ReportListScreen.routeName,
                queryParameters: queryParameters,
                extra: ReportCategoryType.post_report,
              );
            },
          );
        });
  }
}

class PostUtilComponent extends ConsumerWidget {
  final VoidCallback onLikeTap;
  final VoidCallback onShareTap;
  final List<int> likedUsers;
  final bool isSelected;

  const PostUtilComponent({
    super.key,
    required this.onLikeTap,
    required this.onShareTap,
    required this.likedUsers,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: MITIColor.gray500, width: .5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _LikeButton(
              cnt: likedUsers.length,
              onTap: onLikeTap,
              isSelected: isSelected,
            ),
          ),
          Expanded(
            child: _ShareButton(
              onTap: onShareTap,
            ),
          )
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final int cnt;
  final bool isSelected;
  final VoidCallback onTap;

  const _LikeButton(
      {super.key,
      required this.onTap,
      required this.cnt,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: 'heart'),
              height: 24.r,
              width: 24.r,
              colorFilter: ColorFilter.mode(
                  isSelected ? MITIColor.primary : MITIColor.gray500,
                  BlendMode.srcIn),
            ),
            SizedBox(width: 10.w),
            Text(
              "좋아요",
              style: MITITextStyle.xxsmSemiBold.copyWith(
                color: MITIColor.gray500,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              cnt.toString(),
              style: MITITextStyle.xxsmSemiBold.copyWith(
                color: MITIColor.gray500,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShareButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetUtil.getAssetPath(type: AssetType.icon, name: 'share'),
            height: 24.r,
            width: 24.r,
            colorFilter:
                const ColorFilter.mode(MITIColor.gray500, BlendMode.srcIn),
          ),
          SizedBox(width: 10.w),
          Text(
            "공유하기",
            style: MITITextStyle.xxsmSemiBold.copyWith(
              color: MITIColor.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
