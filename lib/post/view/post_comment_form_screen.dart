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
import '../../util/util.dart';
import '../model/base_post_comment_response.dart';
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
    final form = ref.read(postCommentFormProvider(
        postId: widget.postId,
        commentId: widget.commentId,
        replyCommentId: widget.replyCommentId));
    contentTextController.text = form.content;
  }

  @override
  void dispose() {
    _throttler.cancel();
    contentTextController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
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
      FlashUtil.showFlash(context, '요청이 정상적으로 처리되지 않았습니다.',
          textColor: MITIColor.error);
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
        postId: widget.postId,
        commentId: widget.commentId,
        replyCommentId: widget.replyCommentId));
    return form.content.isNotEmpty && form.content.length <= 1000;
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(postCommentFormProvider(
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
                  Container(
                    color: Colors.red,
                    width: double.infinity,
                    height: 100.h,
                  )
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
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                const hintText = "댓글을 입력해주세요";
                return Row(
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
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
