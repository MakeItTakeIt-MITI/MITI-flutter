import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/game_model.dart';
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

  @GET('/courts')
  Future<ResponseModel<PaginationModel<CourtSearchModel>>> getCourtList({
    @Query('search') required String search,
    @Query('page') int? page,
  });

  @GET('/courts/{courtId}')
  Future<ResponseModel<CourtDetailModel>> getDetail({
    @Path('courtId') required int courtId,
  });
}

final courtPaginationRepositoryProvider =
    Provider<CourtPaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return CourtPaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class CourtPaginationRepository
    extends IBasePaginationRepository<CourtSearchModel, CourtPaginationParam> {
  factory CourtPaginationRepository(Dio dio, {String baseUrl}) =
      _CourtPaginationRepository;

  @override
  @GET('/courts')
  Future<ResponseModel<PaginationModel<CourtSearchModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() CourtPaginationParam? param,
    @Query('path') int? path,
  });
}

final courtGamePaginationRepositoryProvider =
    Provider<CourtGamePaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return CourtGamePaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class CourtGamePaginationRepository extends IBasePaginationRepository<
    GameListByDateModel, CourtPaginationParam> {
  factory CourtGamePaginationRepository(Dio dio, {String baseUrl}) =
      _CourtGamePaginationRepository;

  @override
  @GET('/courts/{courtId}/games')
  Future<ResponseModel<PaginationModel<GameListByDateModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() CourtPaginationParam? param,
    @Path('courtId') int? path,
  });
}
