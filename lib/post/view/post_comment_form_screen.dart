import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../common/component/defalut_flashbar.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/form/multi_line_text_field.dart';
import '../../common/model/default_model.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/image_upload_util.dart'; // 새로 만든 유틸리티 import
import '../../util/util.dart';
import '../component/image_form_component.dart';
import '../error/post_error.dart';
import '../provider/post_comment_form_provider.dart';
import '../provider/post_comment_provider.dart';
import '../provider/post_reply_comment_provider.dart';

class PostCommentFormScreen extends ConsumerStatefulWidget {
  static String get routeName => 'postCommentForm';
  final int postId;
  final int commentId;
  final int? replyCommentId;

  const PostCommentFormScreen({
    super.key,
    required this.postId,
    required this.commentId,
    this.replyCommentId,
  });

  @override
  ConsumerState<PostCommentFormScreen> createState() =>
      _PostCommentFormScreenState();
}

class _PostCommentFormScreenState extends ConsumerState<PostCommentFormScreen> {
  bool get isReply => widget.replyCommentId != null;

  late final TextEditingController contentTextController;
  FocusNode focusNode = FocusNode();

  late Throttle<int> _throttler;
  int throttleCnt = 0;
  bool isLoading = false;

  // 이미지 업로드 유틸리티를 위한 지연 초기화 변수
  late ImageUploadUtil _imageUploadUtil;

  @override
  void initState() {
    super.initState();
    contentTextController = TextEditingController();

    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) async {
      setState(() {
        isLoading = true;
      });
      await submit();
      throttleCnt++;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ImageUploadUtil 초기화 (수정용)
    _imageUploadUtil = ImageUploadUtil(
      ref: ref,
      context: context,
      callback: PostCommentFormImageUploadAdapter(
        isEdit: true,
        ref: ref,
        postId: widget.postId,
        commentId: widget.commentId,
        replyCommentId: widget.replyCommentId,
      ),
    );

    final form = ref.read(postCommentFormProvider(
      isEdit: true,
      postId: widget.postId,
      commentId: widget.commentId,
      replyCommentId: widget.replyCommentId,
    ));
    contentTextController.text = form.content;
  }

  @override
  void dispose() {
    _throttler.cancel();
    contentTextController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    // 이미지 설정 (업로드된 이미지 URL을 images 배열에 복사)
    ref
        .read(postCommentFormProvider(
          isEdit: true,
          postId: widget.postId,
          commentId: widget.commentId,
          replyCommentId: widget.replyCommentId,
        ).notifier)
        .setImages();

    final result = isReply
        ? await ref.read(postReplyCommentUpdateProvider(
                postId: widget.postId,
                commentId: widget.commentId,
                replyCommentId: widget.replyCommentId!)
            .future)
        : await ref.read(postCommentUpdateProvider(
            postId: widget.postId,
            commentId: widget.commentId,
          ).future);
    if (result is ErrorModel) {
      late final PostApiType postApiType;
      postApiType =
          isReply ? PostApiType.updateReplyComment : PostApiType.updateComment;

      PostError.fromModel(model: result)
          .responseError(context, postApiType, ref);
    } else {
      context.pop();
      String flashText = "";
      if (isReply) {
        flashText = "대댓글이 수정되었습니다.";
      } else {
        flashText = "댓글이 수정되었습니다.";
      }
      Future.delayed(const Duration(milliseconds: 200), () {
        FlashUtil.showFlash(
          context,
          flashText,
        );
      });
    }
  }

  bool validButton() {
    final form = ref.watch(postCommentFormProvider(
        isEdit: true,
        postId: widget.postId,
        commentId: widget.commentId,
        replyCommentId: widget.replyCommentId));

    // 이미지가 로딩 중인지 확인
    final isImageLoading = form.localImages.any((e) => e.isLoading);

    return form.content.isNotEmpty &&
        form.content.length <= 1000 &&
        !isImageLoading;
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(postCommentFormProvider(
        isEdit: true,
        postId: widget.postId,
        commentId: widget.commentId,
        replyCommentId: widget.replyCommentId));

    return Scaffold(
      backgroundColor: MITIColor.gray900,
      appBar: DefaultAppBar(
        title: "댓글 수정",
        backgroundColor: MITIColor.gray900,
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final valid = validButton() && !isLoading;

              return IconButton(
                onPressed: valid
                    ? () {
                        _throttler.setValue(throttleCnt + 1);
                      }
                    : null,
                icon: Text(
                  '수정',
                  style: MITITextStyle.xxsmLight.copyWith(
                      color: valid ? MITIColor.primary : MITIColor.gray400),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
              child: Column(
                children: [
                  Flexible(
                    child: MultiLineTextField(
                      focusNode: focusNode,
                      textController: contentTextController,
                      inputBorder: OutlineInputBorder(),
                      onChanged: (String value) {
                        if (value.length > 1000) {
                          return;
                        }

                        ref
                            .read(postCommentFormProvider(
                                    isEdit: true,
                                    postId: widget.postId,
                                    commentId: widget.commentId,
                                    replyCommentId: widget.replyCommentId)
                                .notifier)
                            .update(content: value);
                      },
                      hintText: '',
                      textStyle: MITITextStyle.sm150,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  // 선택된 이미지들을 보여주는 부분
                  if (form.localImages.isNotEmpty)
                    Container(
                      height: 80.h,
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 12.h),
                      alignment: Alignment.bottomLeft,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (_, idx) {
                          return ImageFormComponent(
                            imagePath: form.localImages[idx],
                            onDelete: () {
                              ref
                                  .read(postCommentFormProvider(
                                          isEdit: true,
                                          postId: widget.postId,
                                          commentId: widget.commentId,
                                          replyCommentId: widget.replyCommentId)
                                      .notifier)
                                  .removeLocalImage(form.localImages[idx]);
                            },
                          );
                        },
                        separatorBuilder: (_, idx) => SizedBox(width: 12.w),
                        itemCount: form.localImages.length,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                left: 14.w, right: 14.w, top: 8.h, bottom: 30.h),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: MITIColor.gray750,
            ))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: 'gallery'),
                      width: 20.r,
                      height: 20.r,
                      colorFilter: const ColorFilter.mode(
                          MITIColor.gray600, BlendMode.srcIn),
                    ),
                  ),
                  onTap: () async {
                    final limit = ref
                        .read(postCommentFormProvider(
                                isEdit: true,
                                postId: widget.postId,
                                commentId: widget.commentId,
                                replyCommentId: widget.replyCommentId)
                            .notifier)
                        .getLimitImageCnt();
                    // 갤러리 기능 구현
                    await _imageUploadUtil.pickMultipleImages(limit: limit);
                  },
                ),
                Spacer(),
                // 이미지 개수 및 상태 표시 (선택사항)
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final localImages = form.localImages;
                    final loadingCount =
                        localImages.where((e) => e.isLoading).length;

                    if (localImages.isNotEmpty) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: MITIColor.gray700,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          loadingCount > 0
                              ? '업로드 중... ${localImages.length - loadingCount}/${localImages.length}'
                              : '이미지 ${localImages.length}개',
                          style: MITITextStyle.xxsm.copyWith(
                            color: loadingCount > 0
                                ? MITIColor.primary
                                : MITIColor.gray300,
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
