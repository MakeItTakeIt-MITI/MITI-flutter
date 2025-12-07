import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/fab_button.dart';
import 'package:miti/game/provider/widget/game_filter_provider.dart';
import 'package:miti/game/view/game_create_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/custom_bottom_sheet.dart';
import '../../common/component/dispose_sliver_cursor_pagination_list_view.dart';
import '../../common/component/sliver_delegate.dart';
import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';
import '../../theme/color_theme.dart';
import '../../util/util.dart';
import '../component/filter_chip_group.dart';
import '../component/game_card.dart';
import '../component/game_status_chip.dart';
import '../component/skeleton/game_search_skeleton.dart';
import '../model/v2/game/game_with_court_map_response.dart';
import '../provider/game_pagination_provider.dart';
import '../provider/widget/game_search_provider.dart';

// ============================================================================
// Constants
// ============================================================================

class _Constants {
  static const String routeName = GameSearchScreen.routeName;
  static const double headerHeight = 58.0;
  static const double toolbarPadding = 16.0;
  static const double bottomPadding = 12.0;
  static const double spacing = 6.0;
  static const double modalSpacing = 20.0;
  static const double buttonSpacing = 12.0;
}

// ============================================================================
// Main Screen
// ============================================================================

class GameSearchScreen extends ConsumerStatefulWidget {
  static const String routeName = 'gameSearch';

  const GameSearchScreen({super.key});

  @override
  ConsumerState<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends ConsumerState<GameSearchScreen> {
  late final ScrollController _scrollController;
  late final SliverOverlapAbsorberHandle _firstHandle;
  late final SliverOverlapAbsorberHandle _secondHandle;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _firstHandle = SliverOverlapAbsorberHandle();
    _secondHandle = SliverOverlapAbsorberHandle();
  }

  @override
  void dispose() {
    _firstHandle.dispose();
    _secondHandle.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 메인 화면에서 filter provider를 watch하여 dispose 방지
    ref.watch(gameFilterProvider(routeName: _Constants.routeName));

    return Scaffold(
      floatingActionButton: _GameCreateFAB(),
      backgroundColor: V2MITIColor.gray12,
      body: SafeArea(
        child: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _GameSearchAppBar(handle: _firstHandle),
            _GameSearchHeader(handle: _secondHandle),
          ],
          body: _GameSearchBody(
            scrollController: _scrollController,
            onRefresh: _handleRefresh,
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final form = ref.read(gameSearchProvider);
    ref.read(gamePageProvider(PaginationStateParam()).notifier).paginate(
        cursorPaginationParams: const CursorPaginationParam(),
        param: form,
        forceRefetch: true);
  }
}

// ============================================================================
// Header Components
// ============================================================================

class _GameCreateFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FABButton(
      onTap: () => context.pushNamed(GameCreateScreen.routeName),
      text: '경기 생성',
    );
  }
}

class _GameSearchAppBar extends StatelessWidget {
  final SliverOverlapAbsorberHandle handle;

  const _GameSearchAppBar({required this.handle});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
        borderSide: const BorderSide(color: V2MITIColor.gray7),
        borderRadius: BorderRadius.circular(100.r));

    return SliverOverlapAbsorber(
        handle: handle,
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              spacing: 12.w,
              children: [
                IconButton(
                  constraints: BoxConstraints.tight(Size(24.r, 24.r)),
                  padding: EdgeInsets.zero,
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: 'header_left',
                    ),
                    height: 24.r,
                    width: 24.r,
                  ),
                ),

                /// 검색 폼
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 16.w),
                              Text(
                                "경기",
                                style: V2MITITextStyle.smallBoldTight
                                    .copyWith(color: V2MITIColor.white),
                              ),
                              VerticalDivider(
                                  color: V2MITIColor.gray7,
                                  thickness: 1.w,
                                  width: 20.w)
                            ],
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: CircleAvatar(
                              backgroundColor: V2MITIColor.gray9,
                              child: SvgPicture.asset(
                                AssetUtil.getAssetPath(
                                    type: AssetType.icon, name: 'search_solid'),
                                width: 12.r,
                                height: 12.r,
                              ),
                            ),
                          ),
                          suffixIconConstraints:
                              BoxConstraints(maxHeight: 36.r, maxWidth: 36.r),
                          prefixIconConstraints:
                              BoxConstraints(maxHeight: 16.h),
                          constraints: BoxConstraints.loose(
                              Size(double.infinity, 100.h)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.r, vertical: 8.h),
                          focusedBorder: border,
                          border: border,
                          hintText: '검색어를 입력해주세요',
                          hintStyle: V2MITITextStyle.smallMediumTight.copyWith(
                            color: V2MITIColor.gray7,
                          ),
                          fillColor: V2MITIColor.gray12,
                          isDense: true,
                        ),
                        style: V2MITITextStyle.smallMediumTight.copyWith(
                          color: V2MITIColor.gray1,
                        ),
                        onChanged: (val) {
                          final form = ref
                              .read(gameSearchProvider.notifier)
                              .update(title: val);
                          ref
                              .read(gamePageProvider(PaginationStateParam())
                                  .notifier)
                              .updateDebounce(param: form);
                        },
                        onFieldSubmitted: (val) {},
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class _GameSearchHeader extends StatelessWidget {
  final SliverOverlapAbsorberHandle handle;

  const _GameSearchHeader({required this.handle});

  @override
  Widget build(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: handle,
      sliver: SliverPersistentHeader(
        pinned: true,
        delegate: SliverAppBarDelegate(
          child: _GameSearchToolbar(),
        ),
      ),
    );
  }
}

class _GameSearchToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: _Constants.toolbarPadding.w,
        right: _Constants.toolbarPadding.w,
        bottom: _Constants.bottomPadding.h,
      ),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: V2MITIColor.gray11))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GameStatusChipsSection(),
          _FilterButton(),
        ],
      ),
    );
  }
}

// ============================================================================
// Filter Components
// ============================================================================

class _GameStatusChipsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GameStatusChips(
      onDeleted: (GameStatusType status) {
        ref.read(gameSearchProvider.notifier).deleteStatus(status);
        _performSearch(ref);
      },
    );
  }

  void _performSearch(WidgetRef ref) {
    final form = ref.read(gameSearchProvider);
    ref.read(gamePageProvider(PaginationStateParam()).notifier).paginate(
        cursorPaginationParams: const CursorPaginationParam(),
        forceRefetch: true,
        param: form);
  }
}

class _FilterButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () => _showFilterModal(context, ref),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.icon, name: 'menu'),
      ),
    );
  }

  void _showFilterModal(BuildContext context, WidgetRef ref) {
    // 모달 열기 전 현재 검색 상태로 필터 초기화
    final gameSearch = ref.read(gameSearchProvider);
    ref
        .read(gameFilterProvider(routeName: _Constants.routeName).notifier)
        .update(
          gameStatus: gameSearch.gameStatus,
          province: gameSearch.province,
        );

    CustomBottomSheet.show(
      context: context,
      title: "경기 필터",
      childrenBuilder: (refreshModal) => [
        GameFilterModal(refreshModal: refreshModal),
      ],
    );
  }
}

// ============================================================================
// Filter Modal
// ============================================================================

class GameFilterModal extends ConsumerWidget {
  final VoidCallback refreshModal;

  const GameFilterModal({super.key, required this.refreshModal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSearchFilter =
        ref.watch(gameFilterProvider(routeName: _Constants.routeName));

    return Column(
      children: [
        _GameStatusFilterSection(
          selectedItems: gameSearchFilter.gameStatus?.toSet() ?? {},
          onItemTap: (category) => _handleStatusToggle(ref, category),
        ),
        SizedBox(height: _Constants.modalSpacing.h),
        _ProvinceFilterSection(
          selectedItems: gameSearchFilter.province?.toSet() ?? {},
          onItemTap: (district) => _handleProvinceToggle(ref, district),
        ),
        SizedBox(height: _Constants.buttonSpacing.h),
        _FilterActionButtons(
          onClear: () => _handleFilterClear(ref),
          onApply: () => _handleFilterApply(context, ref),
        ),
      ],
    );
  }

  void _handleStatusToggle(WidgetRef ref, GameStatusType category) {
    ref
        .read(gameFilterProvider(routeName: _Constants.routeName).notifier)
        .toggleStatus(category);
    refreshModal();
  }

  void _handleProvinceToggle(WidgetRef ref, DistrictType district) {
    ref
        .read(gameFilterProvider(routeName: _Constants.routeName).notifier)
        .toggleProvince(district);
    refreshModal();
  }

  void _handleFilterClear(WidgetRef ref) {
    ref
        .read(gameFilterProvider(routeName: _Constants.routeName).notifier)
        .clear();
    refreshModal();
  }

  void _handleFilterApply(BuildContext context, WidgetRef ref) {
    final gameFilter =
        ref.read(gameFilterProvider(routeName: _Constants.routeName));

    ref.read(gameSearchProvider.notifier).update(
        gameStatus: gameFilter.gameStatus, province: gameFilter.province);

    _performSearch(ref);
    context.pop();
  }

  void _performSearch(WidgetRef ref) {
    final form = ref.read(gameSearchProvider);
    ref.read(gamePageProvider(PaginationStateParam()).notifier).paginate(
        cursorPaginationParams: const CursorPaginationParam(),
        forceRefetch: true,
        param: form);
  }
}

// ============================================================================
// Filter Sections
// ============================================================================

class _GameStatusFilterSection extends StatelessWidget {
  final Set<GameStatusType> selectedItems;
  final Function(GameStatusType) onItemTap;

  const _GameStatusFilterSection({
    required this.selectedItems,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChipGroup<GameStatusType>(
      title: "경기 상태",
      items: GameStatusType.values
          .where((s) => s != GameStatusType.canceled)
          .toList(),
      selectedItems: selectedItems,
      onItemTap: onItemTap,
      itemToString: (category) => category.displayName,
    );
  }
}

class _ProvinceFilterSection extends StatelessWidget {
  final Set<DistrictType> selectedItems;
  final Function(DistrictType) onItemTap;

  const _ProvinceFilterSection({
    required this.selectedItems,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChipGroup<DistrictType>(
      title: "지역",
      items: DistrictType.values,
      selectedItems: selectedItems,
      onItemTap: onItemTap,
      itemToString: (district) => district.name,
    );
  }
}

// ============================================================================
// Filter Action Buttons
// ============================================================================

class _FilterActionButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onApply;

  const _FilterActionButtons({
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ClearButton(onPressed: onClear),
        SizedBox(width: _Constants.buttonSpacing.w),
        Expanded(child: _ApplyButton(onPressed: onApply)),
      ],
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ClearButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
            side: const BorderSide(color: V2MITIColor.gray6),
          ),
        ),
        backgroundColor: WidgetStateProperty.all(V2MITIColor.gray12),
        minimumSize: WidgetStateProperty.all(Size(98.w, 48.h)),
        maximumSize: WidgetStateProperty.all(Size(98.w, 48.h)),
        fixedSize: WidgetStateProperty.all(Size(98.w, 48.h)),
      ),
      child: Text(
        "초기화",
        style: V2MITITextStyle.regularBold.copyWith(
          color: V2MITIColor.gray6,
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ApplyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(V2MITIColor.primary5),
      ),
      child: Text(
        "적용하기",
        style: V2MITITextStyle.regularBold.copyWith(
          color: V2MITIColor.gray12,
        ),
      ),
    );
  }
}

// ============================================================================
// Body Components
// ============================================================================

class _GameSearchBody extends StatelessWidget {
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const _GameSearchBody({
    required this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: 46.h + 8.h),
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: 20.h,
                    left: _Constants.toolbarPadding.w,
                    right: _Constants.toolbarPadding.w,
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: [_GameListSection(controller: scrollController)],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GameListSection extends ConsumerWidget {
  final ScrollController controller;

  const _GameListSection({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(gameSearchProvider);

    return DisposeSliverCursorPaginationListView(
      provider: gamePageProvider(PaginationStateParam()),
      itemBuilder: (context, index, model) {
        final gameModel = model as GameWithCourtMapResponse;
        return GameCard.fromModel(
          model: gameModel,
          showDate: true,
        );
      },
      param: form,
      skeleton: const GameSearchSkeleton(),
      controller: controller,
      separatorWidget: Divider(
        color: V2MITIColor.gray10,
        thickness: 1.h,
        height: 16.h,
      ),
      emptyWidget: _EmptyGameListWidget(),
    );
  }
}

class _EmptyGameListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '검색된 경기가 없습니다.',
          style: V2MITITextStyle.regularMediumNormal.copyWith(
            color: V2MITIColor.gray7,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Enhanced GameStatusChips (기존 컴포넌트 개선)
// ============================================================================

class GameStatusChips extends StatelessWidget {
  final Function(GameStatusType) onDeleted;

  const GameStatusChips({super.key, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final gameStatus =
            ref.watch(gameSearchProvider.select((s) => s.gameStatus));

        if (gameStatus == null || gameStatus.isEmpty) {
          return const SizedBox.shrink();
        }

        final gameChips = gameStatus
            .map((status) => GameStatusChip(
                  text: status.displayName,
                  onDeleted: () => onDeleted(status),
                ))
            .toList();

        return Row(
          spacing: _Constants.spacing.w,
          children: gameChips,
        );
      },
    );
  }
}
