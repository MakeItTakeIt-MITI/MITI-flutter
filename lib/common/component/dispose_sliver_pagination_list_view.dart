import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/pagination_list_view.dart';
import 'package:miti/common/error/view/error_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../user/param/user_profile_param.dart';
import '../../user/repository/user_repository.dart';
import '../model/default_model.dart';
import '../model/model_id.dart';
import '../param/pagination_param.dart';
import '../provider/pagination_provider.dart';

class DisposeSliverPaginationListView<T extends Base, S>
    extends ConsumerStatefulWidget {
  final AutoDisposeStateNotifierProvider<PaginationProvider, BaseModel>
      provider;
  final PaginationWidgetBuilder<T> itemBuilder;
  final S? param;
  final Widget skeleton;
  final double separateSize;
  final ScrollController controller;
  final Widget emptyWidget;

  const DisposeSliverPaginationListView({
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
  ConsumerState<DisposeSliverPaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends Base>
    extends ConsumerState<DisposeSliverPaginationListView> {
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
            paginationParams: const PaginationParam(page: 1),
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
      ); // todo 스켈레톤 일반화
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

    final cp = state as ResponseModel<PaginationModel<T>>;
    log('state.data!.page_content = ${state.data!.page_content.length}');
    if (state.data!.page_content.isEmpty) {
      return SliverFillRemaining(child: widget.emptyWidget);
    }
    return SliverList.separated(
      itemCount: cp.data!.page_content.length + 1,
      itemBuilder: (_, index) {
        if (index == (cp.data!.page_content.length)) {
          if (cp is! ResponseModel<PaginationModelFetchingMore>) {
            WidgetsBinding.instance.addPostFrameCallback((_) {});
          }
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Center(
              child: cp is ResponseModel<PaginationModelFetchingMore>
                  ? const CircularProgressIndicator()
                  : Container(),
            ),
          );
        }

        final pItem = cp.data!.page_content[index];

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
