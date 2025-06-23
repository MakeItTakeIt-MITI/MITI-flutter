import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/post/model/base_post_response.dart';
import 'package:miti/post/view/post_detail_screen.dart';
import 'package:miti/post/view/post_form_screen.dart';
import 'package:miti/user/model/v2/base_user_response.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../component/post_card.dart';
import '../component/post_category.dart';
import '../component/post_category_chip.dart';
import '../provider/select_post_category_provider.dart';

class PostListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'postList';

  const PostListScreen({super.key});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  final globalKeys =
      List.generate(PostCategoryType.values.length, (idx) => GlobalKey());
  late final ScrollController _categoryScrollController;

  @override
  void initState() {
    super.initState();
    _categoryScrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedPostCategoryProvider);
    final postList = List.generate(
        20,
        (idx) => PostCard.fromModel(
              model: BasePostResponse(
                  id: 1,
                  category: PostCategoryType.general,
                  isAnonymous: true,
                  title: "title",
                  content: "content",
                  numOfComments: 10,
                  createdAt: DateTime.now().toString(),
                  images: List<String>.generate(
                      3,
                      (index) =>
                          "https://avatars.githubusercontent.com/u/41150502?s=40&v=4"),
                  likedUsers: [1, 23, 4, 5],
                  writer: BaseUserResponse(
                      nickname: "nickname",
                      profileImageUrl:
                          "https://avatars.githubusercontent.com/u/41150502?s=40&v=4")),
              onTap: () {
                Map<String, String> pathParameters = {'postId': '6'};
                context.pushNamed(PostDetailScreen.routeName,
                    pathParameters: pathParameters);
              },
            ));

    return Scaffold(
      backgroundColor: MITIColor.gray900,
      floatingActionButton: GestureDetector(
        onTap: () => context.pushNamed(PostFormScreen.routeName),
        child: Container(
          padding:
              EdgeInsets.only(left: 12.w, right: 16.w, top: 10.h, bottom: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            color: MITIColor.primary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                color: MITIColor.gray800,
              ),
              Text(
                '글쓰기',
                style: MITITextStyle.md.copyWith(
                  color: MITIColor.gray800,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            final categories = PostCategoryType.values.toList();
            categories.remove(PostCategoryType.all);
            return [
              DefaultAppBar(
                isSliver: true,
                hasBorder: false,
                backgroundColor: MITIColor.gray900,
                title: "게시판",
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      AssetUtil.getAssetPath(
                          type: AssetType.icon, name: "search"),
                      height: 24.r,
                      width: 24.r,
                      colorFilter: const ColorFilter.mode(
                          MITIColor.gray50, BlendMode.srcIn),
                    ),
                  )
                ],
              ),
              SliverPersistentHeader(
                delegate: SliverAppBarDelegate(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: MITIColor.gray900,
                          border: Border(
                              bottom: BorderSide(
                            color: MITIColor.gray800,
                          ))),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14.w,
                          ),
                          PostCategoryChip(
                            category: PostCategoryType.all,
                            onTap: () {
                              ref
                                  .read(selectedPostCategoryProvider.notifier)
                                  .update((e) => PostCategoryType.all);
                            },
                            isSelected:
                                selectedCategory == PostCategoryType.all,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: VerticalDivider(
                              width: 1.w,
                              indent: 8.h,
                              endIndent: 8.h,
                              color: MITIColor.gray600,
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(
                                    right: 13.w, top: 8.h, bottom: 8.h),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, idx) {
                                  return PostCategoryChip(
                                    category: categories[idx],
                                    onTap: () {
                                      // todo 중앙 스크롤 수정
                                      // focusScrollable(idx, globalKeys);
                                      ref
                                          .read(selectedPostCategoryProvider
                                              .notifier)
                                          .update((e) => categories[idx]);
                                    },
                                    isSelected:
                                        selectedCategory == categories[idx],
                                  );
                                },
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: 8.w),
                                itemCount: categories.length),
                          ),
                        ],
                      ),
                    ),
                    height: 48.h),
                pinned: true,
              ),
            ];
          },
          body: RefreshIndicator(
            onRefresh: () async {},
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  sliver: SliverList.builder(
                    itemBuilder: (_, idx) => postList[idx],
                    itemCount: postList.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
