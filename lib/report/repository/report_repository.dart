import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/report/model/agreement_policy_model.dart';
import 'package:miti/report/model/report_model.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../user/param/user_profile_param.dart';
import '../param/report_param.dart';

part 'report_repository.g.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReportRepository(dio);
});

@RestApi(baseUrl: devServerURL)
abstract class ReportRepository {
  factory ReportRepository(Dio dio) = _ReportRepository;

  @Headers({'token': 'true'})
  @GET('/reports/report-reasons')
  Future<ResponseListModel<ReportModel>> get();

  @Headers({'token': 'true'})
  @GET('/reports/report-reasons/{reportId}')
  Future<ResponseModel<ReportDetailModel>> getDetail(
      {@Path() required int reportId});

  @Headers({'token': 'true'})
  @POST('/games/{gameId}/reports')
  Future<ResponseModel<CreateReportModel>> report({
    @Path() required int gameId,
    @Body() required ReportParam param,
  });

  @GET('/agreement-policies/{type}')
  Future<ResponseListModel<AgreementPolicyModel>> getAgreementPolicy({
    @Path() required AgreementRequestType type,
  });
}
