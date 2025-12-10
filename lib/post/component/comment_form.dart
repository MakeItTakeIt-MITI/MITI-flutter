import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/chat/view/chat_room_screen.dart';
import 'package:miti/post/component/image_form_component.dart';
import 'package:miti/util/model/image_path.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

class PostCommentFormComponent extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final TextEditingController textController;
  final VoidCallback sendMessage;
  final VoidCallback onGallery;

  // Provider 대신 직접적인 데이터와 콜백 사용
  final String content;
  final List<ImagePath> localImages;
  final ValueChanged<String> onContentChanged;
  final ValueChanged<ImagePath> onImageDelete;

  const PostCommentFormComponent({
    super.key,
    required this.focusNode,
    required this.textController,
    required this.sendMessage,
    required this.onGallery,
    required this.content,
    required this.localImages,
    required this.onContentChanged,
    required this.onImageDelete,
  });

  @override
  ConsumerState<PostCommentFormComponent> createState() => _CommentFormState();
}

class _CommentFormState extends ConsumerState<PostCommentFormComponent> {
  @override
  void initState() {
    super.initState();
    widget.textController.addListener(() {
      // Provider 직접 참조 대신 콜백 사용
      widget.onContentChanged(widget.textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(
                color: MITIColor.gray750,
              ))),
      child: Column(
        children: [
          // 선택된 이미지들을 보여주는 부분
          if (widget.localImages.isNotEmpty)
            Container(
              height: 80.h,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.bottomLeft,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (_, idx) {
                  return ImageFormComponent(
                    imagePath: widget.localImages[idx],
                    onDelete: () {
                      // 콜백을 통해 이미지 삭제 처리
                      widget.onImageDelete(widget.localImages[idx]);
                    },
                  );
                },
                separatorBuilder: (_, idx) => SizedBox(width: 12.w),
                itemCount: widget.localImages.length,
              ),
            ),

          // 댓글 입력 폼
          Container(
            padding: EdgeInsets.only(left: 14.w, right: 14.w, top: 8.h, bottom: 30.h),

            child: Row(
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
                    hintText: "댓글을 입력해주세요",
                    // style: MITITextStyle.xxsmLight150,
                  ),
                ),
                SizedBox(width: 10.w),
                SizedBox(
                  width: 41.w,
                  height: 30.h,
                  child: Builder(
                    builder: (context) {
                      // 이미지가 로딩 중인지 확인
                      final isImageLoading = widget.localImages.any((e) => e.isLoading);
                      final enabled = widget.content.isNotEmpty && !isImageLoading;

                      return TextButton(
                          onPressed: enabled
                              ? () async {
                            widget.sendMessage();
                          }
                              : null,
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: enabled
                                  ? V2MITIColor.primary5
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
            ),
          ),
        ],
      ),
    );
  }
}
