import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/report/model/agreement_policy_model.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/report/base_guest_report_response.dart';
import '../../game/model/v2/report/base_host_report_response.dart';
import '../../game/model/v2/report/base_report_reason_response.dart';
import '../../game/model/v2/report/base_report_type_response.dart';
import '../param/report_param.dart';

part 'report_repository.g.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final baseUrl =
  dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return ReportRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class ReportRepository {
  factory ReportRepository(Dio dio, {String baseUrl}) = _ReportRepository;

  /// 신고 사유 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/reports/report-reasons')
  Future<ResponseListModel<BaseReportTypeResponse>> get({
    @Query('report_type') ReportCategoryType? reportType,
  });

  /// 신고 사유 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/reports/report-reasons/{reportId}')
  Future<ResponseModel<BaseReportReasonResponse>> getDetail(
      {@Path() required int reportId});

  /// 경기 호스트 신고 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/host-reports')
  Future<ResponseModel<BaseHostReportResponse>> reportHost({
    @Path() required int gameId,
    @Body() required ReportParam param,
  });

  /// 경기 게스트 신고 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/participations/{participationId}/guest-reports')
  Future<ResponseModel<BaseGuestReportResponse>> reportGuest({
    @Path() required int gameId,
    @Path() required int participationId,
    @Body() required ReportParam param,
  });

  /// 게시글 신고 API
  @Headers({'token': 'true'})
  @POST('/posts/{postId}/reports')
  Future<CompletedModel> reportPost({
    @Path() required int postId,
    @Body() required ReportParam param,
  });

  /// 사용자 신고 API
  @Headers({'token': 'true'})
  @POST('/users/{userId}/reports')
  Future<CompletedModel> reportUser({
    @Path() required int userId,
    @Body() required ReportParam param,
  });

  /// 게시글 댓글 신고 API
  @Headers({'token': 'true'})
  @POST('/comments/{commentId}/reports')
  Future<CompletedModel> reportComment({
    @Path() required int commentId,
    @Body() required ReportParam param,
  });

  /// 게시글 대댓글 신고 API
  @Headers({'token': 'true'})
  @POST('/reply-comments/{reply_commentId}/reports')
  Future<CompletedModel> reportReplyComment({
    @Path("reply_commentId") required int replyCommentId,
    @Body() required ReportParam param,
  });

  /// 요청별 동의 항목 조회 API
  // @Headers({'token': 'true'})
  @GET('/agreement-policies/{type}')
  Future<ResponseListModel<AgreementPolicyModel>> getAgreementPolicy({
    @Path() required AgreementRequestType type,
  });
}
