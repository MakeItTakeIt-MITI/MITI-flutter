import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miti/support/model/support_model.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/support/base_user_question_response.dart';
import '../../user/model/user_model.dart';
import '../../user/param/user_profile_param.dart';
import '../param/support_param.dart';

part 'support_repository.g.dart';

final supportPRepositoryProvider = Provider<SupportPRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return SupportPRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class SupportPRepository
    extends IBasePaginationRepository<BaseUserQuestionResponse, SupportParam> {
  factory SupportPRepository(Dio dio, {String baseUrl}) = _SupportPRepository;

  /// 나의 문의 내역 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/qna')
  Future<ResponseModel<PaginationModel<BaseUserQuestionResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() SupportParam? param,
    @Path('userId') int? path,
  });

  /// 문의 작성 API
  @Headers({'token': 'true'})
  @POST('/users/{userId}/qna')
  Future<ResponseModel<BaseUserQuestionResponse>> createSupport({
    @Body() required SupportParam param,
    @Path() required int userId,
  });

  /// 나의 문의 내역 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/qna/{questionId}')
  Future<ResponseModel<QuestionModel>> getQuestion({
    @Path() required int questionId,
    @Path() required int userId,
  });

  /// FAQ 목록 조회 API
  @GET('/support/faq')
  Future<ResponseListModel<FAQModel>> getFAQ({
    @Query('search') String? search,
  });

  /// 서비스 이용 안내 조회 API
  @GET('/support/guide')
  Future<ResponseListModel<GuideModel>> getGuide(
      {@Query('category') String? category});
}
//
// final faqRepositoryProvider = Provider<FAQRepository>((ref) {
//   final dio = ref.watch(dioProvider);
//   return FAQRepository(dio);
// });
//
// @RestApi(baseUrl: serverURL)
// abstract class FAQRepository
//     extends IBasePaginationRepository<FAQModel, SupportParam> {
//   factory FAQRepository(Dio dio) = _FAQRepository;
//
//   @override
//   @GET('/support/faq')
//   Future<ResponseModel<PaginationModel<FAQModel>>> paginate({
//     @Queries() required PaginationParam paginationParams,
//     @Queries() SupportParam? param,
//     @Path('userId') int? path,
//   });
// }
