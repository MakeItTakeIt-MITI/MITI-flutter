import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/chat/view/chat_room_screen.dart';
import 'package:miti/post/provider/post_comment_form_provider.dart';
import 'package:miti/post/provider/post_comment_provider.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class PostCommentForm extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final TextEditingController textController;
  final VoidCallback sendMessage;
  final VoidCallback onGallery;

  const PostCommentForm({
    super.key,
    required this.focusNode,
    required this.textController,
    required this.sendMessage,
    required this.onGallery,
  });

  @override
  ConsumerState<PostCommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends ConsumerState<PostCommentForm> {
  @override
  void initState() {
    super.initState();
    widget.textController.addListener(() {
      setState(() {
        ref
            .read(postCommentFormProvider().notifier)
            .update(content: widget.textController.text);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 8.h, bottom: 30.h),
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
                onTap: widget.onGallery,
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
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: MultiLineTextField(
                  focusNode: widget.focusNode,
                  controller: widget.textController,
                  hintText: hintText,
                  // style: MITITextStyle.xxsmLight150,
                ),
              ),
              SizedBox(width: 10.w),
              SizedBox(
                width: 41.w,
                height: 30.h,
                child: Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final content = ref.watch(
                        postCommentFormProvider().select((e) => e.content));
                    final enabled = content.isNotEmpty;
                    return TextButton(
                        onPressed: enabled
                            ? () async {
                                widget.sendMessage();
                              }
                            : null,
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: enabled
                                ? MITIColor.primary
                                : MITIColor.gray500),
                        child: Text(
                          "작성",
                          style: MITITextStyle.xxsm.copyWith(
                            color:
                                enabled ? MITIColor.gray800 : MITIColor.gray50,
                          ),
                        ));
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
