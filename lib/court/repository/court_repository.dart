import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/court/model/court_model.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/game_model.dart';

part 'court_repository.g.dart';

final courtRepositoryProvider = Provider<CourtRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CourtRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class CourtRepository {
  factory CourtRepository(Dio dio) = _CourtRepository;

  @GET('/courts')
  Future<ResponseModel<PaginationModel<CourtAddressModel>>> getCourtList(
      {@Query('search') required String search});
}
