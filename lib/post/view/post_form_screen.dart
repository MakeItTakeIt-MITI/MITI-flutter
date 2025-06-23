import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/post/component/post_category.dart';
import 'package:miti/post/view/post_list_screen.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_bottom_sheet.dart';
import '../../common/component/form/multi_line_text_field.dart';
import '../../common/component/form/under_line_text_field.dart';
import '../../util/util.dart';
import 'package:collection/collection.dart';

import '../component/post_category_chip.dart';
import '../provider/post_form_provider.dart';

class PostFormScreen extends ConsumerStatefulWidget {
  static String get routeName => 'postForm';

  const PostFormScreen({super.key});

  @override
  ConsumerState<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends ConsumerState<PostFormScreen> {
  late final TextEditingController bodyTextController;
  late final TextEditingController titleTextController;

  List<FocusNode> focusNodes = [FocusNode(), FocusNode()];

  final inputBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: MITIColor.gray600, width: .5));

  @override
  void initState() {
    super.initState();
    titleTextController = TextEditingController();
    bodyTextController = TextEditingController();
  }

  @override
  void dispose() {
    titleTextController.dispose();
    bodyTextController.dispose();
    super.dispose();
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
              final valid = validButton(ref);

              return IconButton(
                onPressed: valid ? () {} : null,
                icon: Text(
                  "작성",
                  style: MITITextStyle.xxsmLight.copyWith(
                      color: valid ? MITIColor.primary : MITIColor.gray400),
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
                                postFormProvider.select((s) => s.category));
                            focusNodes.forEach((e) => e.unfocus());

                            return Wrap(
                              spacing: 8.r,
                              runSpacing: 8.r,
                              children: categories.mapIndexed((int index, e) {
                                return PostCategoryChip(
                                  category: e,
                                  onTap: () {
                                    ref
                                        .read(postFormProvider.notifier)
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
                        final category = ref
                            .watch(postFormProvider.select((s) => s.category));

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
                      final title =
                          ref.watch(postFormProvider.select((s) => s.title));
                      return UnderLineTextField(
                        textStyle: MITITextStyle.mdSemiBold150,
                        title: title,
                        textEditingController: titleTextController,
                        onChanged: (v) {
                          if (v.length > 32) {
                            return;
                          }

                          ref.read(postFormProvider.notifier).update(title: v);
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
                      final body =
                          ref.watch(postFormProvider.select((s) => s.content));
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
                              .read(postFormProvider.notifier)
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
                    final images =
                        ref.watch(postFormProvider.select((s) => s.images));
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
                            return SizedBox(
                              width: 80.r,
                              height: 80.r,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: SizedBox(
                                      height: 72.r,
                                      width: 72.r,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                        child: Image.file(
                                          File(images[idx]),
                                          // height: 72.r,
                                          // width: 72.r,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0.r,
                                    right: 0.r,
                                    child: GestureDetector(
                                      onTap: () {
                                        ref
                                            .read(postFormProvider.notifier)
                                            .removeImage(images[idx]);
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: MITIColor.gray700,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(3.r),
                                        child: SvgPicture.asset(
                                          AssetUtil.getAssetPath(
                                              type: AssetType.icon,
                                              name: 'close'),
                                          width: 12.r,
                                          height: 12.r,
                                          colorFilter: const ColorFilter.mode(
                                              MITIColor.white, BlendMode.srcIn),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
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
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (image != null) {
                              ref
                                  .read(postFormProvider.notifier)
                                  .addImage(image.path);
                            }
                          }),
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          final isAnonymous = ref.watch(
                              postFormProvider.select((s) => s.isAnonymous));
                          return _UtilButton(
                            title: "익명",
                            icon: 'check_anonymous',
                            onTap: () {
                              ref
                                  .read(postFormProvider.notifier)
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

  bool validButton(WidgetRef ref) {
    final form = ref.watch(postFormProvider);
    return form.title.isNotEmpty &&
        form.title.length <= 32 &&
        form.content.isNotEmpty &&
        form.content.length <= 3000 &&
        form.category != PostCategoryType.all;
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
                isSelected ? MITIColor.primary : MITIColor.gray600,
                BlendMode.srcIn),
          ),
          SizedBox(width: 5.w),
          Text(
            title,
            style: MITITextStyle.xxsm.copyWith(
                color: isSelected ? MITIColor.primary : MITIColor.gray600),
          )
        ],
      ),
    );
  }
}
