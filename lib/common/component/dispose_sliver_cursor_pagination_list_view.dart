import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/pagination_list_view.dart';
import 'package:miti/common/error/view/error_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../model/cursor_model.dart';
import '../model/default_model.dart';
import '../model/model_id.dart';
import '../param/pagination_param.dart';
import '../provider/cursor_pagination_provider.dart';

class DisposeSliverCursorPaginationListView<T extends Base, S>
    extends ConsumerStatefulWidget {
  final AutoDisposeStateNotifierProvider<CursorPaginationProvider, BaseModel>
      provider;
  final PaginationWidgetBuilder<T> itemBuilder;
  final S? param;
  final Widget skeleton;
  final double separateSize;
  final ScrollController controller;
  final Widget emptyWidget;

  const DisposeSliverCursorPaginationListView({
    required this.provider,
    required this.itemBuilder,
    required this.skeleton,
    required this.controller,
    this.param,
    this.separateSize = 16,
    required this.emptyWidget,
    super.key,
  });

  @override
  ConsumerState<DisposeSliverCursorPaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends Base>
    extends ConsumerState<DisposeSliverCursorPaginationListView> {
  // final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_scrollListener);
    // widget.controller.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // log("scrolling!!");
    final family = widget.provider.argument as PaginationStateParam;
    if (widget.controller.position.pixels >
        widget.controller.position.maxScrollExtent - 150) {
      // log("scroll end");
      ref.read(widget.provider.notifier).paginate(
            cursorPaginationParams: const CursorPaginationParam(),
            param: widget.param,
            fetchMore: true,
            path: family.path,
          );
      // 스크롤이 끝에 도달했을 때 새로운 항목 로드
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    // 완전 처음 로딩일때
    if (state is LoadingModel) {
      return SliverToBoxAdapter(
        child: widget.skeleton,
      );
    }
    // 에러
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

    final cp = state as ResponseModel<CursorPaginationModel<T>>;
    log('state.data!.page_content = ${state.data!.items.length}');
    if (state.data!.items.isEmpty) {
      return SliverFillRemaining(child: widget.emptyWidget);
    }
    return SliverList.separated(
      itemCount: cp.data!.items.length + 1,
      itemBuilder: (_, index) {
        if (index == (cp.data!.items.length)) {
          if (cp is! ResponseModel<CursorPaginationModelFetchingMore>) {
            WidgetsBinding.instance.addPostFrameCallback((_) {});
          }
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Center(
              child: cp is ResponseModel<CursorPaginationModelFetchingMore>
                  ? const CircularProgressIndicator()
                  : Container(),
            ),
          );
        }

        final pItem = cp.data!.items[index];

        return widget.itemBuilder(
          context,
          index,
          pItem,
        );
      },
      separatorBuilder: (_, index) {
        return Container(
          color: Colors.transparent,
          height: widget.separateSize.h,
          width: widget.separateSize.w,
        );
      },
    );
  }
}
