import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/advertisement/advertisement_response.dart';
import '../../game/model/v2/advertisement/base_advertisement_response.dart';

part 'advertise_repository.g.dart';

final advertiseRepositoryProvider = Provider<AdvertiseRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return AdvertiseRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class AdvertiseRepository {
  factory AdvertiseRepository(Dio dio, {String baseUrl}) = _AdvertiseRepository;

  /// 광고 랜덤 조회 API
  @Headers({'token': 'true'})
  @GET('/support/active-advertisement')
  Future<ResponseModel<BaseAdvertisementResponse>> getRandomAdvertise();

  /// 광고 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/support/advertisements/{advertisementId}')
  Future<ResponseModel<AdvertisementResponse>> getAdvertiseDetail(
      {@Path() required int advertisementId});
}
