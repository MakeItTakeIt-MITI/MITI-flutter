import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/cursor_model.dart';
import '../model/default_model.dart';
import '../model/model_id.dart';
import '../param/pagination_param.dart';
import '../repository/base_pagination_repository.dart';

class CursorPaginationProvider<T extends Base, S extends DefaultParam,
        U extends IBaseCursorPaginationRepository<T, S>>
    extends StateNotifier<BaseModel> {
  final U repository;
  final CursorPaginationParam cursorPageParams;
  final S? param;
  final int? path;

  CursorPaginationProvider({
    required this.repository,
    required this.cursorPageParams,
    this.param,
    this.path,
  }) : super(LoadingModel()) {
    log("pagination Provider init");
    log("param ${param}");
    paginate(
      cursorPaginationParams: cursorPageParams,
      param: param,
      path: path,
    );
  }

  Future<void> paginate(
      {required CursorPaginationParam cursorPaginationParams,
      S? param,
      int? path,
      bool fetchMore = false,
      bool forceRefetch = false}) async {
    try {
      log('prev state type = ${state.runtimeType}');

      if (state is ResponseModel<CursorPaginationModel> && !forceRefetch) {
        final pState = (state as ResponseModel<CursorPaginationModel>).data!;
        // 다음 페이지가 없을 경우
        if (!pState.hasMore) {
          log('다음 페이지가 없을 경우');
          return;
        }
      }
      final isLoading = state is LoadingModel;
      final isRefetching = state is ResponseModel<CursorPaginationModelRefetching>;
      final isFetchingMore =
          state is ResponseModel<CursorPaginationModelFetchingMore>;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }
      log("fetchMore = $fetchMore");
      if (fetchMore) {
        final pState = state as ResponseModel<CursorPaginationModel<T>>;
        state = ResponseModel(
            status_code: pState.status_code,
            message: pState.message,
            data: CursorPaginationModelFetchingMore<T>(
                pageFirstCursor: pState.data!.pageFirstCursor,
                pageLastCursor: pState.data!.pageLastCursor,
                hasMore: pState.data!.hasMore,
                items: pState.data!.items));

        cursorPaginationParams =
            cursorPaginationParams.copyWith(cursor: pState.data!.pageLastCursor!);
      } else {
        if (state is ResponseModel<CursorPaginationModel> && !forceRefetch) {
          final pState = state as ResponseModel<CursorPaginationModel<T>>;
          state = ResponseModel(
              status_code: pState.status_code,
              message: pState.message,
              data: CursorPaginationModelRefetching<T>(
                  pageFirstCursor: pState.data!.pageFirstCursor,
                  pageLastCursor: pState.data!.pageLastCursor,
                  hasMore: pState.data!.hasMore,
                  items: pState.data!.items));
        } else {
          state = LoadingModel();
        }
      }

      final resp = await repository.paginate(
        cursorPaginationParams: cursorPaginationParams,
        param: param,
        path: path,
      );
      log("resp type = ${resp.runtimeType}");
      log("mid state type = ${state.runtimeType} ");
      if (state is ResponseModel<CursorPaginationModelFetchingMore>) {
        final pState = state as ResponseModel<CursorPaginationModelFetchingMore<T>>;
        final data = pState.data!.copyWith(
            pageFirstCursor: resp.data!.pageFirstCursor,
            pageLastCursor: resp.data!.pageLastCursor,
            hasMore: resp.data!.hasMore,
            items: [
          ...pState.data!.items,
          ...resp.data!.items,
        ]);

        state = resp.copyWith(
          data: data,
        );
        log("change state type = ${state.runtimeType} ");
      } else {
        state = resp;
      }
      log("after state type = ${state.runtimeType} ");
    } catch (e, stack) {
      log("pagination error = $e}");
      log("pagination stack = $stack}");
      state = ErrorModel.respToError(e);
    }
  }
}
