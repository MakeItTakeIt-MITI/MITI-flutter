import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:miti/post/param/post_search_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/default_model.dart';
import '../../common/param/cursor_pagination_param.dart';

part 'post_list_provider.g.dart';

@Riverpod()
class PostPagination extends _$PostPagination {
  final searchDebounce = Debouncer(const Duration(milliseconds: 300),
      initialValue: const PostSearchParam(), checkEquality: false);

  @override
  BaseModel build(bool isSearch,
      {PostSearchParam? param, required CursorPaginationParam cursorParam}) {
    // paginate(
    //   paginationParams: pageParams,
    //   param: param,
    //   path: path,
    // );
    log("init post pagination isSearch = ${isSearch} param= $param cursorParam = $cursorParam");
    _initializeData(param, cursorParam);
    searchDebounce.values.listen((PostSearchParam state) {
      getPostPagination(
        cursorParam: cursorParam,
        param: state,
        forceRefetch: true,
      );
    });
    return LoadingModel();
  }

  // 초기화 메서드 분리
  void _initializeData(
      PostSearchParam? param, CursorPaginationParam cursorParam) {
    // 다음 프레임에서 실행되도록 지연
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPostPagination(cursorParam: cursorParam, param: param);
    });
  }

  void updateDebounce({required PostSearchParam param}) {
    searchDebounce.setValue(param);
  }

  Future<void> getPostPagination(
      {PostSearchParam? param,
      CursorPaginationParam cursorParam = const CursorPaginationParam(),
      bool fetchMore = false,
      bool forceRefetch = false}) async {
    // try {
    //   log('prev state type = ${state.runtimeType}');
    //
    //   if (state is ResponseModel<CursorPaginationModel> && !forceRefetch) {
    //     final pState = (state as ResponseModel<CursorPaginationModel>).data!;
    //
    //     // log('earliestCursor = ${pState.earliestCursor} lastCursor = ${pState.lastCursor}');
    //     // 다음 페이지가 없을 경우
    //     if (pState.earliestCursor == pState.lastCursor ||
    //         pState.lastCursor == null) {
    //       log('다음 페이지가 없을 경우');
    //       return;
    //     }
    //   }
    //
    //   final isLoading = state is LoadingModel;
    //   final isRefetching =
    //       state is ResponseModel<CursorPaginationModelRefetching>;
    //   final isFetchingMore =
    //       state is ResponseModel<CursorPaginationModelFetchingMore>;
    //
    //   if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
    //     return;
    //   }
    //   log("fetchMore = $fetchMore");
    //
    //   if (fetchMore) {
    //     final pState =
    //         state as ResponseModel<CursorPaginationModel<BasePostResponse>>;
    //
    //     state = ResponseModel(
    //         status_code: pState.status_code,
    //         message: pState.message,
    //         data: CursorPaginationModelFetchingMore<BasePostResponse>(
    //           latestCursor: pState.data!.latestCursor,
    //           earliestCursor: pState.data!.earliestCursor,
    //           items: pState.data!.items,
    //           firstCursor: pState.data!.firstCursor,
    //           lastCursor: pState.data!.lastCursor,
    //         ));
    //
    //     // 마지막 커서 위치부터 다음 10개 요청
    //     cursorParam = cursorParam.copyWith(cursor: pState.data!.lastCursor);
    //   } else {
    //     if (state is ResponseModel<CursorPaginationModel> && !forceRefetch) {
    //       final pState =
    //           state as ResponseModel<CursorPaginationModel<BasePostResponse>>;
    //       state = ResponseModel(
    //           status_code: pState.status_code,
    //           message: pState.message,
    //           data: CursorPaginationModelRefetching<BasePostResponse>(
    //             latestCursor: pState.data!.latestCursor,
    //             earliestCursor: pState.data!.earliestCursor,
    //             items: pState.data!.items,
    //             firstCursor: pState.data!.firstCursor,
    //             lastCursor: pState.data!.lastCursor,
    //           ));
    //     } else {
    //       state = LoadingModel();
    //     }
    //   }
    //
    //   final repository = ref.watch(postRepositoryProvider);
    //   final resp = await repository.getPostList(
    //     params: param,
    //     cursorParams: cursorParam,
    //   );
    //
    //   if (param != null && param.search != null) {
    //     ref.read(searchHistoryProvider.notifier).addSearch(param.search!);
    //   }
    //
    //   log("resp type = ${resp.runtimeType}");
    //   log("mid state type = ${state.runtimeType} ");
    //
    //   if (state is ResponseModel<CursorPaginationModelFetchingMore>) {
    //     final pState = state as ResponseModel<
    //         CursorPaginationModelFetchingMore<BasePostResponse>>;
    //     final data = pState.data!.copyWith(
    //       items: [
    //         ...pState.data!.items,
    //         ...resp.data!.items,
    //       ],
    //
    //       // 요청한 커서로 갱신
    //       lastCursor: resp.data!.lastCursor,
    //     );
    //
    //     state = resp.copyWith(
    //       data: data,
    //     );
    //     log("change state type = ${state.runtimeType} ");
    //   } else {
    //     state = resp;
    //   }
    //   log("after state type = ${state.runtimeType} ");
    // } catch (e, stack) {
    //   log("cursorPagination error = $e}");
    //   log("cursorPagination stack = $stack}");
    //   state = ErrorModel.respToError(e);
    // }
  }
}
