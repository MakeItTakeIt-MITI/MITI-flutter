import 'package:flutter/material.dart';
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
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:share_plus/share_plus.dart';

import '../../user/model/v2/base_user_response.dart';
import '../../util/util.dart';
import '../component/comment_card.dart';
import '../component/comment_component.dart';
import '../component/comment_form.dart';
import '../component/post_writer_info.dart';
import '../component/reply_comment_component.dart';
import '../model/base_post_comment_response.dart';
import '../model/base_reply_comment_response.dart';
import '../model/post_response.dart';
import '../provider/post_reply_comment_provider.dart';

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

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(postDetailProvider(postId: widget.postId));
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      return CircularProgressIndicator();
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
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (_) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 18.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 48.h,
                            child: TextButton(
                              onPressed: () async {
                                final result = ref.read(
                                    postDeleteProvider(postId: widget.postId)
                                        .future);

                                if (result is! ErrorModel) {
                                  context.pop();
                                  context.pop();
                                }
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: MITIColor.gray800),
                              child: Text(
                                "삭제하기",
                                style: MITITextStyle.md
                                    .copyWith(color: MITIColor.error),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          SizedBox(
                            height: 48.h,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                  backgroundColor: MITIColor.gray800),
                              child: Text(
                                "수정하기",
                                style: MITITextStyle.md
                                    .copyWith(color: MITIColor.gray100),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          TextButton(
                              onPressed: () => context.pop(),
                              style: TextButton.styleFrom(
                                  backgroundColor: MITIColor.gray800),
                              child: Text(
                                "닫기",
                                style: MITITextStyle.md
                                    .copyWith(color: MITIColor.gray400),
                              )),
                        ],
                      ),
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// 게시글 영역
                  Padding(
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
                        Text(
                          model.title,
                          style: MITITextStyle.mdSemiBold150
                              .copyWith(color: MITIColor.gray50),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          model.content,
                          style: MITITextStyle.sm150
                              .copyWith(color: MITIColor.gray50),
                        ),
                        SizedBox(height: 5.h),
                      ],
                    ),
                  ),
                  PostUtilComponent(
                    likedUsers: model.likedUsers,
                    onLikeTap: () async {
                      if (isSelected) {
                        ref.read(
                            postUnLikeProvider(postId: widget.postId).future);
                      } else {
                        ref.read(
                            postLikeProvider(postId: widget.postId).future);
                      }
                    },
                    onShareTap: () async {
                      final result = await Share.shareUri(Uri(
                        scheme: 'https',
                        host: "www.makeittakeit.kr",
                        path: 'post/${widget.postId}',
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
                        return CircularProgressIndicator();
                      } else if (result is ErrorModel) {
                        return CircularProgressIndicator();
                      }

                      final model =
                          (result as ResponseListModel<BasePostCommentResponse>)
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
          PostCommentForm(
            textController: textController,
            sendMessage: () async {
              final result = await ref.read(
                  postCommentCreateProvider(postId: widget.postId).future);
              if (result is! ErrorModel) {
                textController.clear();
              }
            },
            focusNode: focusNode,
          )
        ],
      ),
    );
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
