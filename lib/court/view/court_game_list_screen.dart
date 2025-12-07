import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/court/provider/court_game_pagination_provider.dart';

import '../../common/error/view/error_screen.dart';
import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../game/component/game_list_component.dart';
import '../../game/model/base_game_meta_response.dart';
import '../param/court_pagination_param.dart';
import 'court_map_screen.dart';

class CourtGameListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'courtGameList';
  final int courtId;

  const CourtGameListScreen({super.key, required this.courtId});

  @override
  ConsumerState<CourtGameListScreen> createState() =>
      _CourtGameListScreenState();
}

class _CourtGameListScreenState extends ConsumerState<CourtGameListScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    ;
    // todo 지우기 여부 확인
    WidgetsBinding.instance.addPostFrameCallback((s) {
      ref
          .read(scrollControllerProvider.notifier)
          .update((s) => _scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              const DefaultAppBar(
                title: '이 경기장에 생성된 경기',
                isSliver: true,
                hasBorder: false,
              ),
            ];
          },
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                sliver: Consumer(builder:
                    (BuildContext context, WidgetRef ref, Widget? child) {
                  final state = ref.watch(courtGamePaginationProvider(
                      courtId: widget.courtId,
                      param: CourtPaginationParam(search: ''),
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
                    WidgetsBinding.instance.addPostFrameCallback((s) {
                      context.pushReplacementNamed(ErrorScreen.routeName);
                    });
                    return SliverToBoxAdapter(child: Container());
                  }

                  final cp = state as ResponseModel<
                      CursorPaginationModel<List<BaseGameMetaResponse>>>;
                  log('state.data!.page_content = ${state.data!.items.length}');
                  print(
                      'state.data!.page_content = ${state.data!.items.length}');
                  if (state.data!.items.isEmpty) {
                    return SliverToBoxAdapter(child: Container());
                  }

                  return SliverList.builder(
                    itemBuilder: (_, index) {
                      if (index == (cp.data!.items.length)) {
                        if (cp is! ResponseModel<
                            CursorPaginationModelFetchingMore>) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {});
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
                      return GameCardByDate.fromModel(
                        model: pItem,
                      );
                    },
                    itemCount: cp.data!.items.length + 1,
                  );
                }),
                padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
              ),
            ],
          )),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300) {
      ref
          .read(courtGamePaginationProvider(
                  courtId: widget.courtId,
                  param: CourtPaginationParam(search: ''),
                  cursorParam: const CursorPaginationParam())
              .notifier)
          .paginate(
            courtId: widget.courtId,
            cursorPaginationParams: const CursorPaginationParam(),
            fetchMore: true,
            param: CourtPaginationParam(search: ''),
          );
      // 스크롤이 끝에 도달했을 때 새로운 항목 로드
    }
  }
}
