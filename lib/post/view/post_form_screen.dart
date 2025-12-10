import 'package:collection/collection.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/post/provider/post_provider.dart';
import 'package:miti/post/view/post_detail_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_bottom_sheet.dart';
import '../../common/component/defalut_flashbar.dart';
import '../../common/component/form/multi_line_text_field.dart';
import '../../common/component/form/under_line_text_field.dart';
import '../../common/model/default_model.dart';
import '../../util/image_upload_util.dart';
import '../../util/util.dart';
import '../component/image_form_component.dart';
import '../component/post_category_chip.dart';
import '../error/post_error.dart';
import '../model/post_response.dart';
import '../provider/post_form_provider.dart';

class PostFormScreen extends ConsumerStatefulWidget {
  final int? postId;

  static String get routeName => 'postForm';

  const PostFormScreen({
    super.key,
    this.postId,
  });

  @override
  ConsumerState<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends ConsumerState<PostFormScreen> {
  late final TextEditingController bodyTextController;
  late final TextEditingController titleTextController;

  bool get isEdit => widget.postId != null;

  String get buttonText => isEdit ? "수정" : "작성";

  List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  late ImageUploadUtil _imageUploadUtil;
  final inputBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: MITIColor.gray600, width: .5));

  late Throttle<int> _throttler;
  int throttleCnt = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleTextController = TextEditingController();
    bodyTextController = TextEditingController();

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
    _imageUploadUtil = ImageUploadUtil(
      ref: ref,
      context: context,
      callback: PostFormImageUploadAdapter(
        ref: ref,
        postId: widget.postId,
      ),
    );

    if (isEdit) {
      final form = ref.read(postFormProvider(postId: widget.postId));
      titleTextController.text = form.title;
      bodyTextController.text = form.content;
    }
  }

  @override
  void dispose() {
    _throttler.cancel();
    titleTextController.dispose();
    bodyTextController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    ref.read(postFormProvider(postId: widget.postId).notifier).setImages();

    final result = isEdit
        ? await ref.read(postUpdateProvider(postId: widget.postId!).future)
        : await ref.read(postCreateProvider.future);
    if (result is ErrorModel) {
      late final PostApiType postApiType;
      postApiType = isEdit ? PostApiType.updatePost : PostApiType.createPost;
      PostError.fromModel(model: result)
          .responseError(context, postApiType, ref);
    } else {
      final resultPostId = (result as ResponseModel<PostResponse>).data!.id;
      Map<String, String> pathParameters = {'postId': resultPostId.toString()};
      context.goNamed(
        PostDetailScreen.routeName,
        pathParameters: pathParameters,
      );

      String flashText = "";
      if (isEdit) {
        // 수정
        flashText = "게시글이 수정되었습니다.";
      } else {
        // 생성
        flashText = "게시글이 작성되었습니다.";
      }
      Future.delayed(const Duration(milliseconds: 200), () {
        FlashUtil.showFlash(
          context,
          flashText,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = PostCategoryType.values.toList();
    categories.remove(PostCategoryType.all);

    return Scaffold(
      backgroundColor: MITIColor.gray900,
      appBar: DefaultAppBar(
        title: "글쓰기",
        backgroundColor: MITIColor.gray900,
        leadingIcon: "close",
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final valid = validButton(ref, widget.postId) && !isLoading;

              return IconButton(
                onPressed: valid
                    ? () {
                        _throttler.setValue(throttleCnt + 1);
                      }
                    : null,
                icon: Text(
                  buttonText,
                  style: MITITextStyle.xxsmLight.copyWith(
                      color: valid ? V2MITIColor.primary5 : MITIColor.gray400),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              focusNodes.forEach((e) => e.unfocus());

              showCustomModalBottomSheet(
                  context,
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "게시글 카테고리를 선택해주세요.",
                          style: MITITextStyle.mdBold
                              .copyWith(color: MITIColor.gray100),
                        ),
                        SizedBox(height: 24.h),
                        Consumer(
                          builder: (BuildContext context, WidgetRef ref,
                              Widget? child) {
                            final category = ref.watch(
                                postFormProvider(postId: widget.postId)
                                    .select((s) => s.category));
                            focusNodes.forEach((e) => e.unfocus());

                            return Wrap(
                              spacing: 8.r,
                              runSpacing: 8.r,
                              children: categories.mapIndexed((int index, e) {
                                return PostCategoryChip(
                                  category: e,
                                  onTap: () {
                                    ref
                                        .read(postFormProvider(
                                                postId: widget.postId)
                                            .notifier)
                                        .update(category: e);
                                    context.pop();
                                  },
                                  isSelected: e == category,
                                  backgroundColor: MITIColor.gray800,
                                );
                              }).toList(),
                            );
                          },
                        )
                      ],
                    ),
                  ));
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: MITIColor.gray600, width: .5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final category = ref.watch(
                            postFormProvider(postId: widget.postId)
                                .select((s) => s.category));

                        return Text(
                          category == PostCategoryType.all
                              ? "게시글 카테고리를 선택해주세요."
                              : category.displayName,
                          style: MITITextStyle.sm150
                              .copyWith(color: MITIColor.gray400),
                        );
                      },
                    ),
                    SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: "right"),
                      height: 24.r,
                      width: 24.r,
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                          color: MITIColor.gray750.withOpacity(.5),
                          borderRadius: BorderRadius.circular(10.r)),
                      child: Text(
                        "정치, 홍보에 관한 내용이나 불법 촬영물이 포함된 게시글은\n게시판 운영 정책에 따라 게시글이 삭제될 수 있습니다.",
                        textAlign: TextAlign.center,
                        style: MITITextStyle.xxxsm140
                            .copyWith(color: MITIColor.gray300),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final title = ref.watch(
                          postFormProvider(postId: widget.postId)
                              .select((s) => s.title));
                      return UnderLineTextField(
                        textStyle: MITITextStyle.mdSemiBold150,
                        title: title,
                        textEditingController: titleTextController,
                        onChanged: (v) {
                          if (v.length > 32) {
                            return;
                          }

                          ref
                              .read(postFormProvider(postId: widget.postId)
                                  .notifier)
                              .update(title: v);
                        },
                        hintText: "제목을 입력해주세요!",
                        focusNode: focusNodes[0],
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                SliverFillRemaining(
                  child: Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      final body = ref.watch(
                          postFormProvider(postId: widget.postId)
                              .select((s) => s.content));
                      return child!;
                    },
                    child: Scrollbar(
                      child: MultiLineTextField(
                        textStyle: MITITextStyle.sm150,
                        textController: bodyTextController,
                        inputBorder: inputBorder,
                        onChanged: (v) {
                          if (v.length > 3000) {
                            return;
                          }
                          ref
                              .read(postFormProvider(postId: widget.postId)
                                  .notifier)
                              .update(content: v);
                        },
                        hintText: "농구에 관해 자유롭게 이야기를 나누어보세요!",
                        focusNode: focusNodes[1],
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: MITIColor.gray600,
            ))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final images = ref.watch(
                        postFormProvider(postId: widget.postId)
                            .select((s) => s.localImages));
                    if (images.isEmpty) {
                      return Container();
                    }
                    return Container(
                      height: 80.h,
                      margin: EdgeInsets.only(bottom: 12.h, top: 12.h),
                      alignment: Alignment.bottomLeft,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(left: 20.w, right: 20.w),
                          shrinkWrap: true,
                          itemBuilder: (_, idx) {
                            return ImageFormComponent(
                              imagePath: images[idx],
                              onDelete: () {
                                ref
                                    .read(
                                        postFormProvider(postId: widget.postId)
                                            .notifier)
                                    .removeLocalImage(images[idx]);
                              },
                            );
                          },
                          separatorBuilder: (_, idx) => SizedBox(width: 12.w),
                          itemCount: images.length),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _UtilButton(
                          title: "사진",
                          icon: 'gallery',
                          onTap: () async {
                            _pickMultipleImages();
                          }),
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          final isAnonymous = ref.watch(
                              postFormProvider(postId: widget.postId)
                                  .select((s) => s.isAnonymous));
                          return _UtilButton(
                            title: "익명",
                            icon: 'check_anonymous',
                            onTap: () {
                              ref
                                  .read(postFormProvider(postId: widget.postId)
                                      .notifier)
                                  .update(isAnonymous: !isAnonymous);
                            },
                            isSelected: isAnonymous,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h)
        ],
      ),
    );
  }

  bool validButton(WidgetRef ref, int? postId) {
    final form = ref.watch(postFormProvider(postId: widget.postId));

    // 하나라도 이미지 로딩중이면 안됨
    final isImageLoading = form.localImages.any((e) => e.isLoading);
    return form.title.isNotEmpty &&
        form.title.length <= 32 &&
        form.content.isNotEmpty &&
        form.content.length <= 3000 &&
        form.category != PostCategoryType.all &&
        !isImageLoading;
  }

  Future<void> _pickMultipleImages() async {
    final limit = ref
        .read(postFormProvider(postId: widget.postId).notifier)
        .getLimitImageCnt();
    await _imageUploadUtil.pickMultipleImages(limit: limit, category: FileCategoryType.post_image);
  }
}

class _UtilButton extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UtilButton(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      highlightColor: Colors.transparent,
      icon: Row(
        children: [
          SvgPicture.asset(
            AssetUtil.getAssetPath(type: AssetType.icon, name: icon),
            width: 20.r,
            height: 20.r,
            colorFilter: ColorFilter.mode(
                isSelected ? V2MITIColor.primary5 : MITIColor.gray600,
                BlendMode.srcIn),
          ),
          SizedBox(width: 5.w),
          Text(
            title,
            style: MITITextStyle.xxsm.copyWith(
                color: isSelected ? V2MITIColor.primary5 : MITIColor.gray600),
          )
        ],
      ),
    );
  }
}
