import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/game/base_game_court_by_date_response.dart';
import '../../game/model/v2/game/base_game_response.dart';
import '../model/v2/court_map_response.dart';
import '../model/v2/court_operations_response.dart';
import '../param/court_pagination_param.dart';

part 'court_repository.g.dart';

final courtRepositoryProvider = Provider<CourtRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return CourtRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class CourtRepository {
  factory CourtRepository(Dio dio, {String baseUrl}) = _CourtRepository;
  /// 경기장 상세 조회 API
  @GET('/courts/{courtId}')
  Future<ResponseModel<CourtOperationsResponse>> getDetail({
    @Path('courtId') required int courtId,
  });
}

final courtCursorPaginationRepositoryProvider =
    Provider<CourtCursorPaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return CourtCursorPaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class CourtCursorPaginationRepository
    extends IBaseCursorPaginationRepository<CourtMapResponse, CourtPaginationParam> {
  factory CourtCursorPaginationRepository(Dio dio, {String baseUrl}) =
      _CourtCursorPaginationRepository;

  /// 경기장 목록 조회 API
  @override
  @GET('/courts')
  Future<ResponseModel<CursorPaginationModel<CourtMapResponse>>> paginate({
    @Queries() required CursorPaginationParam cursorPaginationParams,
    @Queries() CourtPaginationParam? param,
    @Query('path') int? path,
  });
}

final courtGameCursorPaginationRepositoryProvider =
    Provider<CourtGameCursorPaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return CourtGameCursorPaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class CourtGameCursorPaginationRepository extends IBaseCursorPaginationRepository<
    BaseGameResponse, CourtPaginationParam> {
  factory CourtGameCursorPaginationRepository(Dio dio, {String baseUrl}) =
      _CourtGameCursorPaginationRepository;

  /// 경기장 경기 목록 조회 API
  @override
  @GET('/courts/{courtId}/games')
  Future<ResponseModel<CursorPaginationModel<BaseGameResponse>>> paginate({
    @Queries() required CursorPaginationParam cursorPaginationParams,
    @Queries() CourtPaginationParam? param,
    @Path('courtId') int? path,
  });
}
