import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/post/model/base_post_response.dart';
import 'package:miti/post/provider/post_list_provider.dart';
import 'package:miti/post/provider/post_search_provider.dart';
import 'package:miti/post/view/post_detail_screen.dart';
import 'package:miti/post/view/post_form_screen.dart';
import 'package:miti/post/view/post_search_screen.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/param/cursor_pagination_param.dart';
import '../../court/view/court_map_screen.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../component/popular_post_component.dart';
import '../component/post_card.dart';
import '../component/post_category_chip.dart';
import '../error/post_error.dart';


class PostListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'postList';

  const PostListScreen({super.key});

  @override
  ConsumerState<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends ConsumerState<PostListScreen> {
  late final ScrollController scrollController;
  final globalKeys =
      List.generate(PostCategoryType.values.length, (idx) => GlobalKey());
  late final ScrollController _categoryScrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    _categoryScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((s) {
      ref
          .read(scrollControllerProvider.notifier)
          .update((s) => scrollController);
    });
  }

  Future<void> refresh() async {
    final form = ref.read(postSearchProvider(false));
    ref
        .read(postPaginationProvider(false,
                cursorParam: const CursorPaginationParam())
            .notifier)
        .getPostPagination(
            cursorParam: const CursorPaginationParam(),
            param: form,
            forceRefetch: true);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(postSearchProvider(false), (prev, after) {
      ref
          .read(postPaginationProvider(false,
                  cursorParam: const CursorPaginationParam())
              .notifier)
          .getPostPagination(param: after, forceRefetch: true);
    });

    // ref.watch(postSearchProvider(false));
    final selectedCategory =
        ref.watch(postSearchProvider(false).select((s) => s.category));
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
                    onPressed: () =>
                        context.pushNamed(PostSearchScreen.routeName),
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
                                  .read(postSearchProvider(false).notifier)
                                  .update(
                                    category: PostCategoryType.all,
                                    isAll: true,
                                  );
                            },
                            isSelected: selectedCategory == null,
                            globalKey: globalKeys[0],
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
                                controller: _categoryScrollController,
                                padding: EdgeInsets.only(
                                    right: 13.w, top: 8.h, bottom: 8.h),
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, idx) {
                                  return PostCategoryChip(
                                    globalKey: globalKeys[idx + 1],
                                    category: categories[idx],
                                    onTap: () {
                                      ref
                                          .read(postSearchProvider(false)
                                              .notifier)
                                          .update(
                                            category: categories[idx],
                                            isAll: false,
                                          );
                                      // 정확한 중앙 스크롤
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _scrollToIndexSafe(idx);
                                      });
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
            onRefresh: refresh,
            child: CustomScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                const SliverToBoxAdapter(
                  child: PopularPostComponent(),
                ),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final state = ref.watch(postPaginationProvider(false,
                        cursorParam: const CursorPaginationParam()));

                    // 완전 처음 로딩일때
                    if (state is LoadingModel) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ); // todo 스켈레톤 일반화
                    }

                    if (state is ErrorModel) {
                      PostError.fromModel(model: state)
                          .responseError(context, PostApiType.getPostList, ref);

                      return SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '일시적으로 화면을 불러올 수 없습니다.\n잠시후 다시 이용해주세요.',
                              style: MITITextStyle.pageMainTextStyle,
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                context.pop();
                              },
                              child: const Text(
                                '뒤로가기',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // CursorPagination
                    // CursorPaginationFetchingMore
                    // CursorPaginationRefetching

                    final cp = state as ResponseModel<
                        CursorPaginationModel<BasePostResponse>>;
                    log('state.data!.page_content = ${state.data!.items.length}');
                    if (state.data!.items.isEmpty) {
                      return SliverFillRemaining(
                          child: Center(
                              child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${selectedCategory?.displayName ?? ''} 게시글이 없습니다.",
                            style: MITITextStyle.xxl140,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            "${selectedCategory?.displayName ?? ''} 게시글을 작성해보세요!",
                            style: MITITextStyle.sm,
                          ),
                        ],
                      )));
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      sliver: SliverList.builder(
                        itemBuilder: (_, index) {
                          if (index == (cp.data!.items.length)) {
                            if (cp is! ResponseModel<
                                CursorPaginationModelFetchingMore>) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) {});
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Center(
                                child: cp is ResponseModel<
                                        CursorPaginationModelFetchingMore>
                                    ? const CircularProgressIndicator()
                                    : Container(),
                              ),
                            );
                          }

                          final pItem = cp.data!.items[index];
                          return PostCard.fromModel(
                            model: pItem,
                            onTap: () {
                              Map<String, String> pathParameters = {
                                'postId': pItem.id.toString()
                              };
                              context.pushNamed(PostDetailScreen.routeName,
                                  pathParameters: pathParameters);
                            },
                          );
                        },
                        itemCount: cp.data!.items.length + 1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollListener() {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 300) {
      final form = ref.read(postSearchProvider(false));

      ref
          .read(postPaginationProvider(false,
                  cursorParam: const CursorPaginationParam())
              .notifier)
          .getPostPagination(
            cursorParam: const CursorPaginationParam(),
            fetchMore: true,
            param: form,
          );
      // 스크롤이 끝에 도달했을 때 새로운 항목 로드
    }
  }

  void _scrollToIndexSafe(int categoryIndex) {
    // categories 배열의 인덱스를 받아서 globalKeys 배열의 인덱스로 변환
    final int globalKeyIndex = categoryIndex + 1; // "전체" 카테고리가 0번 인덱스

    if (!_categoryScrollController.hasClients) {
      print('ScrollController가 아직 연결되지 않음');
      return;
    }

    if (globalKeyIndex >= globalKeys.length) {
      print('인덱스가 범위를 벗어남: $globalKeyIndex >= ${globalKeys.length}');
      return;
    }

    // 약간의 지연을 두고 실행 (위젯이 완전히 빌드된 후)
    Future.delayed(const Duration(milliseconds: 50), () {
      final GlobalKey targetKey = globalKeys[globalKeyIndex];
      final BuildContext? context = targetKey.currentContext;

      if (context == null) {
        print('타겟 위젯의 context를 찾을 수 없음');
        return;
      }

      Scrollable.ensureVisible(
        context,
        alignment: 0.5, // 0.5 = 중앙
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}
