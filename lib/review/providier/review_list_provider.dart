import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../repository/review_repository.dart';

part 'review_list_provider.g.dart';

@Riverpod(keepAlive: false)
class GuestReviewList extends _$GuestReviewList {
  @override
  BaseModel build({required int gameId, required int participationId}) {
    get(gameId: gameId, participationId: participationId);
    return LoadingModel();
  }

  Future<void> get({required int gameId, required int participationId}) async {
    final repository = ref.watch(reviewRepositoryProvider);

    repository
        .getParticipationReviewList(
            gameId: gameId, participationId: participationId)
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
class HostReviewList extends _$HostReviewList {
  @override
  BaseModel build({required int gameId}) {
    get(gameId: gameId);
    return LoadingModel();
  }

  Future<void> get({required int gameId}) async {
    final repository = ref.watch(reviewRepositoryProvider);

    repository.getHostReviewList(gameId: gameId).then((value) {
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
