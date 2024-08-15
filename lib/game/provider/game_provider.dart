import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:miti/game/model/game_model.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:miti/game/provider/widget/game_filter_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/game/repository/game_repository.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../court/view/court_map_screen.dart';
import '../../user/provider/user_pagination_provider.dart';
import '../../user/repository/user_repository.dart';

part 'game_provider.g.dart';

@Riverpod(keepAlive: false)
class GameList extends _$GameList {
  @override
  BaseModel build() {
    getList();
    return LoadingModel();
  }

  Future<void> getList() async {
    state = LoadingModel();
    final repository = ref.watch(gameRepositoryProvider);
    final param = ref.read(gameFilterProvider);
    repository.getGameList(param: param).then((value) {
      logger.i(value);
      ref.read(selectGameListProvider.notifier).update((state) => value.data!);
      state = value;
      // state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@Riverpod(keepAlive: false)
class GameDetail extends _$GameDetail {
  @override
  BaseModel build({required int gameId}) {
    get(gameId: gameId);
    return LoadingModel();
  }

  Future<void> get({required int gameId}) async {
    final repository = ref.watch(gameRepositoryProvider);
    // final response =
    //     await Dio().request('https://dev.makeittakeit.kr/games/1229');
    // final data = response.data['data'];
    // log('data $data');

    repository.getGameDetail(gameId: gameId).then((value) {
      logger.i(value);
      log('value.data!.is_host = ${value.data!.is_host} value.data!.is_participated ${value.data!.is_participated}');
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@riverpod
Future<BaseModel> gameCreate(GameCreateRef ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  final param = ref.watch(gameFormProvider);

  return await repository.createGame(param: param).then<BaseModel>((value) {
    logger.i(value);
    final userId = ref.read(authProvider)!.id!;
    ref
        .read(userHostingPProvider(PaginationStateParam(path: userId)).notifier)
        .paginate(
          path: userId,
          forceRefetch: true,
          paginationParams: const PaginationParam(page: 1),
        );
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> gameUpdate(GameUpdateRef ref, {required int gameId}) async {
  final repository = ref.watch(gameRepositoryProvider);
  final form = ref.read(gameFormProvider);
  final param = GameUpdateParam.fromForm(form: form);
  return await repository
      .updateGame(param: param, gameId: gameId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(gameDetailProvider(gameId: gameId).notifier).get(gameId: gameId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> gameFree(GameFreeRef ref, {required int gameId}) async {
  final repository = ref.watch(gameRepositoryProvider);

  return await repository
      .freeGame(gameId: gameId)
      .then<BaseModel>((value) async {
    logger.i(value);
    await ref
        .read(gameDetailProvider(gameId: gameId).notifier)
        .get(gameId: gameId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> gameCancel(GameCancelRef ref,
    {required int gameId, required int participationId}) async {
  final repository = ref.watch(gameRepositoryProvider);

  return await repository
      .cancelGame(gameId: gameId, participationId: participationId)
      .then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
class Host extends _$Host {
  @override
  BaseModel build({required int gameId}) {
    getHost(gameId: gameId);
    return LoadingModel();
  }

  void getHost({required int gameId}) {
    final repository = ref.watch(gameRepositoryProvider);
    repository.getHost(gameId: gameId).then<BaseModel>((value) {
      logger.i(value);
      state = value;
      return value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      return error;
    });
  }
}

@riverpod
class Payment extends _$Payment {
  @override
  BaseModel build({required int gameId}) {
    getPayment(gameId: gameId);
    return LoadingModel();
  }

  void getPayment({required int gameId}) {
    final repository = ref.watch(gameRepositoryProvider);
    repository.getPayment(gameId: gameId).then<BaseModel>((value) {
      logger.i(value);
      state = value;
      return value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      return error;
    });
  }
}

@Riverpod(keepAlive: false)
class RefundInfo extends _$RefundInfo {
  @override
  BaseModel build({required int gameId, required int participationId}) {
    get(gameId: gameId, participationId: participationId);
    return LoadingModel();
  }

  // todo 환불 정보 조회시  에러  경기 시작 6시간 이내에는 참여를 취소할 수 없습니다.
  // 명세 갱신 필요
  //  status_code = 403
  // error.error_code = 470
  Future<void> get({required int gameId, required int participationId}) async {
    final repository = ref.watch(gameRepositoryProvider);
    repository
        .refundInfo(gameId: gameId, participationId: participationId)
        .then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@Riverpod(keepAlive: false)
class GamePlayers extends _$GamePlayers {
  @override
  BaseModel build({required int gameId}) {
    getPlayers(gameId: gameId);
    return LoadingModel();
  }

  Future<void> getPlayers({required int gameId}) async {
    state = LoadingModel();
    final repository = ref.watch(gameRepositoryProvider);
    repository.getPlayers(gameId: gameId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@Riverpod(keepAlive: false)
class Rating extends _$Rating {
  @override
  BaseModel build({required int ratingId}) {
    getRating(ratingId: ratingId);
    return LoadingModel();
  }

  Future<void> getRating({required int ratingId}) async {
    state = LoadingModel();
    final repository = ref.watch(gameRepositoryProvider);
    repository.getRating(ratingId: ratingId).then((value) {
      logger.i(value);
      state = value;
      // state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@riverpod
Future<BaseModel> guestReview(
  GuestReviewRef ref, {
  required int gameId,
  required int participationId,
}) async {
  final repository = ref.watch(gameRepositoryProvider);
  final param = ref.read(reviewFormProvider);

  return await repository
      .createGuestReview(
          param: param, gameId: gameId, participationId: participationId)
      .then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> hostReview(
  HostReviewRef ref, {
  required int gameId,
}) async {
  final repository = ref.watch(gameRepositoryProvider);
  final param = ref.read(reviewFormProvider);

  return await repository
      .createHostReview(
    param: param,
    gameId: gameId,
  )
      .then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> gameRecentHosting(GameRecentHostingRef ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  final userId = ref.read(authProvider)!.id!;
  return await repository
      .getRecentHostings(userId: userId)
      .then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> cancelRecruitGame(CancelRecruitGameRef ref,
    {required int gameId}) async {
  final repository = ref.watch(gameRepositoryProvider);
  return await repository
      .cancelRecruitGame(gameId: gameId)
      .then<BaseModel>((value) {
    logger.i(value);
    final userId = ref.read(authProvider)?.id!;

    ref
        .read(userHostingPProvider(PaginationStateParam(path: userId)).notifier)
        .paginate(
          path: userId,
          forceRefetch: true,
          paginationParams: const PaginationParam(page: 1),
        );
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
