import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/post/provider/popular_search_provider.dart';
import 'package:miti/post/view/post_detail_screen.dart';
import 'package:collection/collection.dart';
import '../../chat/view/chat_room_screen.dart';
import '../../common/component/default_appbar.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/error/view/error_screen.dart';
import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/param/cursor_pagination_param.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../component/post_card.dart';
import '../component/post_category_chip.dart';
import '../component/recent_search_history_component.dart';
import '../component/search_form.dart';
import '../model/base_post_response.dart';
import '../model/popular_search_word_list_response.dart';
import '../provider/post_list_provider.dart';
import '../provider/post_search_provider.dart';
import '../provider/search_history_provider.dart';

class PostSearchScreen extends ConsumerStatefulWidget {
  static String get routeName => 'postSearch';

  const PostSearchScreen({super.key});

  @override
  ConsumerState<PostSearchScreen> createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends ConsumerState<PostSearchScreen> {
  late final FocusNode focusNode;
  late final TextEditingController textEditingController;
  late final ScrollController scrollController;
  final globalKeys =
      List.generate(PostCategoryType.values.length, (idx) => GlobalKey());
  late final ScrollController _categoryScrollController;
  bool showTextField = true;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    textEditingController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    scrollController = ScrollController()..addListener(_scrollListener);
    _categoryScrollController = ScrollController();
  }

  Future<void> refresh() async {
    final form = ref.read(postSearchProvider(true));
    ref.read(postPaginationProvider(isSearch: true).notifier).getPostPagination(
        cursorParam: const CursorPaginationParam(),
        param: form,
        forceRefetch: true);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 300) {
      final form = ref.read(postSearchProvider(true));

      ref
          .read(postPaginationProvider(isSearch: true).notifier)
          .getPostPagination(
            cursorParam: const CursorPaginationParam(),
            fetchMore: true,
            param: form,
          );
      // 스크롤이 끝에 도달했을 때 새로운 항목 로드
    }
  }

  void search(String text) {
    log("search  ${text}");
    ref.read(postSearchProvider(true).notifier).update(search: text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(postSearchProvider(true), (prev, after) {
      showTextField = false;
      ref
          .read(postPaginationProvider(isSearch: true).notifier)
          .getPostPagination(param: after, forceRefetch: true);
    });

    final searchForm = ref.watch(postSearchProvider(true));
    final categories = PostCategoryType.values.toList();
    categories.remove(PostCategoryType.all);
    bool isSearching = searchForm.search == null || showTextField;
    return Scaffold(
      backgroundColor: MITIColor.gray900,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                if (isSearching) {
                  return [
                    SliverPersistentHeader(
                      delegate: SliverAppBarDelegate(
                        height: 44.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 13.w),
                              child: IconButton(
                                constraints:
                                    BoxConstraints.tight(Size(24.r, 24.r)),
                                padding: EdgeInsets.zero,
                                onPressed: () => context.pop(),
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: SvgPicture.asset(
                                  AssetUtil.getAssetPath(
                                    type: AssetType.icon,
                                    name: 'back_arrow',
                                  ),
                                  height: 24.r,
                                  width: 24.r,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 13.w),
                                child: SearchForm(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  hintText: "검색어를 입력해주세요",
                                  maxLength: 100,
                                  onSubmitted: search,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: textEditingController.text.isNotEmpty
                                  ? () {
                                      search(textEditingController.text);
                                      focusNode.unfocus();
                                    }
                                  : null,
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
                      ),
                    ),
                  ];
                }
                return [
                  DefaultAppBar(
                    isSliver: true,
                    hasBorder: false,
                    backgroundColor: MITIColor.gray900,
                    title: "게시판",
                    actions: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showTextField = true;
                          });
                        },
                        icon: SvgPicture.asset(
                          AssetUtil.getAssetPath(
                              type: AssetType.icon, name: "search"),
                          height: 24.r,
                          width: 24.r,
                          colorFilter: const ColorFilter.mode(
                              MITIColor.gray50, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                  SliverPersistentHeader(
                    delegate: SliverAppBarDelegate(
                      height: 88.h,
                      child: Container(
                        alignment: Alignment.topCenter,
                        decoration: const BoxDecoration(
                            color: MITIColor.gray900,
                            border: Border(
                                bottom: BorderSide(
                              color: MITIColor.gray800,
                            ))),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14.w,
                                  ),
                                  PostCategoryChip(
                                    category: PostCategoryType.all,
                                    onTap: () {
                                      ref
                                          .read(
                                              postSearchProvider(true).notifier)
                                          .update(
                                            category: PostCategoryType.all,
                                            isAll: true,
                                          );
                                    },
                                    isSelected: searchForm.category == null,
                                    globalKey: globalKeys[0],
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    child: VerticalDivider(
                                      width: 1.w,
                                      thickness: 1.w,
                                      // indent: 8.h,
                                      // endIndent: 8.h,
                                      color: MITIColor.gray600,
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 32.h,
                                      child: ListView.separated(
                                          shrinkWrap: true,
                                          controller: _categoryScrollController,
                                          padding: EdgeInsets.only(right: 13.w),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (_, idx) {
                                            return PostCategoryChip(
                                              globalKey: globalKeys[idx + 1],
                                              category: categories[idx],
                                              onTap: () {
                                                ref
                                                    .read(
                                                        postSearchProvider(true)
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
                                              isSelected: searchForm.category ==
                                                  categories[idx],
                                            );
                                          },
                                          separatorBuilder: (_, __) =>
                                              SizedBox(width: 8.w),
                                          itemCount: categories.length),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "“",
                                        style: MITITextStyle.lgBold
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "${searchForm.search}",
                                        style: MITITextStyle.lgBold
                                            .copyWith(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "“ 검색결과",
                                        style: MITITextStyle.lgBold
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: CustomScrollView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  if (isSearching)
                    SliverPadding(
                      padding: EdgeInsets.all(12.r),
                      sliver: SliverMainAxisGroup(slivers: [
                        SliverToBoxAdapter(
                          child: SearchChipComponent(
                            title: "카테고리",
                            contents: categories
                                .mapIndexed((idx, e) => Text(
                                      e.displayName,
                                      style: MITITextStyle.xxsm
                                          .copyWith(color: MITIColor.gray300),
                                    ))
                                .toList(),
                            onSelect: (int index) {},
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                        SliverToBoxAdapter(
                          child: Consumer(
                            builder: (BuildContext context, WidgetRef ref,
                                Widget? child) {
                              final result = ref.watch(popularSearchProvider);
                              if (result is LoadingModel) {
                                return Container();
                              } else if (result is ErrorModel) {
                                return const Text("error");
                              }
                              final model = (result as ResponseListModel<
                                      PopularSearchWordListResponse>)
                                  .data!;

                              final contents = model
                                  .map((e) => Text(
                                        e.searchWord,
                                        style: MITITextStyle.xxsm
                                            .copyWith(color: MITIColor.gray300),
                                      ))
                                  .toList();
                              if (contents.isEmpty) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      '인기검색어',
                                      style: MITITextStyle.mdBold
                                          .copyWith(color: Colors.white),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      "인기검색어가 아직 없습니다.",
                                      textAlign: TextAlign.center,
                                      style: MITITextStyle.sm,
                                    ),
                                  ],
                                );
                              }

                              return SearchChipComponent(
                                title: "인기 검색어",
                                contents: contents,
                                onSelect: (int index) {
                                  ref
                                      .read(postSearchProvider(true).notifier)
                                      .update(search: model[index].searchWord);
                                },
                              );
                            },
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                        SliverToBoxAdapter(
                          child: RecentSearchHistoryComponent(
                            onSearch: (String text) {
                              ref
                                  .read(postSearchProvider(true).notifier)
                                  .update(search: text);
                            },
                          ),
                        )
                      ]),
                    )
                  else
                    Consumer(
                      builder:
                          (BuildContext context, WidgetRef ref, Widget? child) {
                        final state =
                            ref.watch(postPaginationProvider(isSearch: true));

                        // 완전 처음 로딩일때
                        if (state is LoadingModel) {
                          return const SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ); // todo 스켈레톤 일반화
                        }

                        if (state is ErrorModel) {
                          WidgetsBinding.instance.addPostFrameCallback((s) {
                            context.pushReplacementNamed(ErrorScreen.routeName);
                          });
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
                                "${searchForm.category?.displayName ?? ''} 게시글이 없습니다.",
                                style: MITITextStyle.xxl140,
                              ),
                              SizedBox(height: 20.h),
                              Text(
                                "${searchForm.category?.displayName ?? ''} 게시글을 작성해보세요!",
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
              )),
        ),
      ),
    );
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

class SearchChipComponent extends StatelessWidget {
  final String title;
  final List<Widget> contents;
  final OnSelect onSelect;

  const SearchChipComponent({
    super.key,
    required this.title,
    required this.contents,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: MITITextStyle.mdBold.copyWith(color: Colors.white),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 32.h,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, idx) => SearchChip(
                    content: contents[idx],
                    onTap: () {
                      onSelect(idx);
                    },
                    isSelected: false,
                  ),
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemCount: contents.length),
        )
      ],
    );
  }
}

class SearchChip extends StatelessWidget {
  final GlobalKey? globalKey;
  final Widget content;
  final bool isSelected;
  final VoidCallback onTap;
  final Color backgroundColor;

  const SearchChip({
    super.key,
    required this.content,
    required this.onTap,
    required this.isSelected,
    this.backgroundColor = MITIColor.gray900,
    this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      key: globalKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        height: 32.h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
                color: isSelected ? MITIColor.primaryLight : MITIColor.gray600,
                width: .5),
            color: isSelected ? MITIColor.primaryLight : backgroundColor),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}
