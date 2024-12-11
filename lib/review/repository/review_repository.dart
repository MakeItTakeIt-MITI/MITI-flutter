import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/game_model.dart';
import '../../game/param/game_param.dart';
import '../model/review_model.dart';

part 'review_repository.g.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepository(dio);
});

@RestApi(baseUrl: devServerURL)
abstract class ReviewRepository {
  factory ReviewRepository(Dio dio) = _ReviewRepository;

  @Headers({'token': 'true'})
  @GET('/games/{gameId}/participations/{participationId}/reviews')
  Future<ResponseModel<ReviewListModel>> getParticipationReviewList({
    @Path() required int gameId,
    @Path() required int participationId,
  });

  @Headers({'token': 'true'})
  @GET('/games/{gameId}/reviews')
  Future<ResponseModel<ReviewListModel>> getHostReviewList({
    @Path() required int gameId,
  });
}
