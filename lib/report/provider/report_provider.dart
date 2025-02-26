import 'dart:developer';

import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/notification/param/push_setting_param.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:miti/report/provider/widget/report_form_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
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
Future<BaseModel> createReport(CreateReportRef ref,
    {required int gameId, required int reportId, int? participationId}) async {
  final param = ref.read(reportFormProvider(reportReason: reportId));
  final repository = ref.watch(reportRepositoryProvider);
  final result = participationId == null
      ? repository.reportHost(
          gameId: gameId,
          param: param,
        )
      : repository.reportGuest(
          gameId: gameId, participationId: participationId, param: param);

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
