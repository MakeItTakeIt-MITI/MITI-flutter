import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/game_model.dart';
import '../../game/param/game_param.dart';

part 'review_repository.g.dart';

final gameRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class ReviewRepository {
  factory ReviewRepository(Dio dio) = _ReviewRepository;

  // @Headers({'token': 'true'})
  @GET('/games')
  Future<ResponseModel<GameModel>> getGameList(
      {@Queries() required GameListParam param});
}
