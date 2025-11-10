import 'dart:developer';

import 'package:miti/report/provider/widget/report_form_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';
import '../repository/report_repository.dart';

part 'report_provider.g.dart';

@Riverpod(keepAlive: false)
class Report extends _$Report {
  @override
  BaseModel build({ReportCategoryType? reportType}) {
    get(reportType);
    return LoadingModel();
  }

  Future<void> get(ReportCategoryType? reportType) async {
    state = LoadingModel();
    final repository = ref.watch(reportRepositoryProvider);
    repository.get(reportType: reportType).then((value) {
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
class ReportDetail extends _$ReportDetail {
  @override
  BaseModel build({required int reportId}) {
    get(reportId: reportId);
    return LoadingModel();
  }

  Future<void> get({required int reportId}) async {
    state = LoadingModel();
    final repository = ref.watch(reportRepositoryProvider);
    repository.getDetail(reportId: reportId).then((value) {
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

@riverpod
Future<BaseModel> createReport(
  CreateReportRef ref, {
  required int reportId,
  int? gameId,
  int? participationId,
  int? postId,
  int? userId,
  int? commentId,
  int? replyCommentId,
}) async {
  final param = ref.read(reportFormProvider(reportReason: reportId));
  final repository = ref.watch(reportRepositoryProvider);

  if (postId != null || userId != null || commentId != null || replyCommentId != null) {
    late Future<CompletedModel> result;
    if (postId != null) {
      result = repository.reportPost(
        postId: postId,
        param: param,
      );
    } else if (userId != null) {
      result = repository.reportUser(
        userId: userId,
        param: param,
      );
    } else if (commentId != null) {
      result = repository.reportComment(
        commentId: commentId,
        param: param,
      );
    } else if (replyCommentId != null) {
      result = repository.reportReplyComment(
        replyCommentId: replyCommentId,
        param: param,
      );
    }
    return await result.then<BaseModel>((value) {
      logger.i('create report !');
      return value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      return error;
    });
  }

  late Future<ResponseModel<IModelWithId>> gameResult;

  if (gameId != null && participationId != null) {
    gameResult = repository.reportGuest(
        gameId: gameId, participationId: participationId, param: param);
  } else {
    gameResult = repository.reportHost(
      gameId: gameId!,
      param: param,
    );
  }

  return await gameResult.then<BaseModel>((value) {
    logger.i('create report !');
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@Riverpod(keepAlive: false)
class AgreementPolicy extends _$AgreementPolicy {
  @override
  BaseModel build({required AgreementRequestType type}) {
    get(type: type);
    return LoadingModel();
  }

  Future<void> get({required AgreementRequestType type}) async {
    state = LoadingModel();
    final repository = ref.watch(reportRepositoryProvider);
    log('type.name = ${type.name}');
    repository.getAgreementPolicy(type: type).then((value) {
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
