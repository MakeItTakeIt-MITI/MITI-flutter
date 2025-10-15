import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/user/repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../game/model/v2/game/base_game_response.dart';
import '../param/user_profile_param.dart';

part 'user_host_pagination_provider.g.dart';

@Riverpod()
class UserHostingPagination extends _$UserHostingPagination {
  @override
  BaseModel build(
      {UserGameParam? param,
        required CursorPaginationParam cursorParam}) {
    log("init pagination param= $param cursorParam = $cursorParam");
    _initializeData(param, cursorParam);
    return LoadingModel();
  }

  // 초기화 메서드 분리
  void _initializeData(
      UserGameParam? param, CursorPaginationParam cursorParam) {
    // 다음 프레임에서 실행되도록 지연
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paginate(cursorPaginationParams: cursorParam, param: param);
    });
  }

  Future<void> paginate(
      {UserGameParam? param,
        CursorPaginationParam cursorPaginationParams =
        const CursorPaginationParam(),
        bool fetchMore = false,
        bool forceRefetch = false}) async {
    int? userId = ref.read(authProvider)?.id;
    if (userId == null) {
      return;
    }

    try {
      log('prev state type = ${state.runtimeType}');

      if (state is ResponseModel<CursorPaginationModel> && !forceRefetch) {
        final pState = (state as ResponseModel<CursorPaginationModel>).data!;

        // log('earliestCursor = ${pState.earliestCursor} lastCursor = ${pState.lastCursor}');
        // 다음 페이지가 없을 경우
        if (!pState.hasMore) {
          log('다음 페이지가 없을 경우');
          return;
        }
      }

      final isLoading = state is LoadingModel;
      final isRefetching =
      state is ResponseModel<CursorPaginationModelRefetching>;
      final isFetchingMore =
      state is ResponseModel<CursorPaginationModelFetchingMore>;

      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }
      log("fetchMore = $fetchMore");

      if (fetchMore) {
        final pState =
        state as ResponseModel<CursorPaginationModel<List<BaseGameResponse>>>;

        state = ResponseModel(
            status_code: pState.status_code,
            message: pState.message,
            data: CursorPaginationModelFetchingMore<List<BaseGameResponse>>(
              items: pState.data!.items,
              pageFirstCursor: pState.data!.pageFirstCursor,
              pageLastCursor: pState.data!.pageLastCursor,
              hasMore: pState.data!.hasMore,
            ));

        // 마지막 커서 위치부터 다음 10개 요청
        cursorPaginationParams = cursorPaginationParams.copyWith(
            cursor: pState.data!.pageLastCursor);
      } else {
        if (state is ResponseModel<CursorPaginationModel> && !forceRefetch) {
          final pState =
          state as ResponseModel<CursorPaginationModel<List<BaseGameResponse>>>;
          state = ResponseModel(
              status_code: pState.status_code,
              message: pState.message,
              data: CursorPaginationModelRefetching<List<BaseGameResponse>>(
                items: pState.data!.items,
                pageFirstCursor: pState.data!.pageFirstCursor,
                pageLastCursor: pState.data!.pageLastCursor,
                hasMore: pState.data!.hasMore,
              ));
        } else {
          log("강제 새로고침");
          state = LoadingModel();
        }
      }

      final repository = ref.watch(userHostingPRepositoryProvider);
      final resp = await repository.paginate(
        path: userId,
        param: param,
        cursorPaginationParams: cursorPaginationParams,
      );

      log("resp type = ${resp.runtimeType}");
      log("mid state type = ${state.runtimeType} ");

      if (state is ResponseModel<CursorPaginationModelFetchingMore>) {
        final pState = state as ResponseModel<
            CursorPaginationModelFetchingMore<List<BaseGameResponse>>>;

        final unionItems =
        unionGroupItemsByStartDate(pState.data!.items, resp.data!.items);

        state = ResponseModel<CursorPaginationModel<List<BaseGameResponse>>>(
            data: CursorPaginationModel(
                pageFirstCursor: pState.data!.pageFirstCursor,
                pageLastCursor: resp.data!.pageLastCursor,
                hasMore: resp.data!.hasMore,
                items: unionItems),
            status_code: resp.status_code,
            message: resp.message);
        log("change state type = ${state.runtimeType} ");
      } else {
        final mapItems = groupItemsByStartDate(resp.data!.items);
        state = ResponseModel<CursorPaginationModel<List<BaseGameResponse>>>(
            data: CursorPaginationModel(
                pageFirstCursor: resp.data!.pageFirstCursor,
                pageLastCursor: resp.data!.pageLastCursor,
                hasMore: resp.data!.hasMore,
                items: mapItems),
            status_code: resp.status_code,
            message: resp.message);
      }
      log("after state type = ${state.runtimeType} ");
    } catch (e, stack) {
      log("cursorPagination error = $e}");
      log("cursorPagination stack = $stack}");
      state = ErrorModel.respToError(e);
    }
  }

  // 시작 날짜별로 그룹화
  List<List<BaseGameResponse>> groupItemsByStartDate(
      List<BaseGameResponse> items) {
    final grouped = groupBy(items, (item) => item.startDate);
    return grouped.values.toList();
  }

  // 시작 날짜별로 그룹화
  List<List<BaseGameResponse>> unionGroupItemsByStartDate(
      List<List<BaseGameResponse>> items, List<BaseGameResponse> newItems) {
    List<BaseGameResponse> flattened = items.expand((list) => list).toList();
    flattened.insertAll(items.length, newItems);

    final grouped = groupBy(flattened, (item) => item.startDate);
    return grouped.values.toList();
  }
}
