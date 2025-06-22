import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/post/model/base_post_response.dart';
import 'package:miti/user/model/v2/base_user_response.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/model/entity_enum.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../component/post_card.dart';
import '../component/post_category.dart';

class PostListScreen extends StatelessWidget {
  static String get routeName => 'postList';

  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  createdAt: DateTime.now(),
                  images: List<String>.generate(
                      3,
                      (index) =>
                          "https://avatars.githubusercontent.com/u/41150502?s=40&v=4"),
                  likedUsers: [1, 23, 4, 5],
                  writer: BaseUserResponse(
                      nickname: "nickname",
                      profileImageUrl:
                          "https://avatars.githubusercontent.com/u/41150502?s=40&v=4")),
              onTap: () {},
            ));

    return Scaffold(
      backgroundColor: MITIColor.gray900,
      floatingActionButton: GestureDetector(
        onTap: () => context.pushNamed(""),
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
            const categories = PostCategoryType.values;
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
                      color: MITIColor.gray900,
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(
                              horizontal: 13.w, vertical: 8.h),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, idx) {
                            return PostCategoryChip(
                              category: categories[idx],
                              onTap: () {},
                            );
                          },
                          separatorBuilder: (_, __) => SizedBox(width: 8.w),
                          itemCount: categories.length),
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

class PostCategoryChip extends StatelessWidget {
  final PostCategoryType category;
  final VoidCallback onTap;

  const PostCategoryChip(
      {super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        height: 32.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: MITIColor.gray600, width: .5),
        ),
        child: Row(
          children: [
            Text(category.displayName,
                style: MITITextStyle.xxsm.copyWith(color: MITIColor.gray300)),
            SizedBox(width: 2.w),
            SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: "search"),
              height: 12.r,
              width: 12.r,
            )
          ],
        ),
      ),
    );
  }
}
