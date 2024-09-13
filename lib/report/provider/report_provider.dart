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
  BaseModel build() {
    get();
    return LoadingModel();
  }

  Future<void> get() async {
    state = LoadingModel();
    final repository = ref.watch(reportRepositoryProvider);
    repository.get().then((value) {
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
    {required int gameId, required HostReportCategoryType category}) async {
  final param = ref.read(reportFormProvider(category: category));
  return await ref
      .watch(reportRepositoryProvider)
      .report(
        gameId: gameId,
        param: param,
      )
      .then<BaseModel>((value) {
    logger.i('create report !');
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
