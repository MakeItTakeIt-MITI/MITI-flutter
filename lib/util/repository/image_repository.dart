import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/advertisement/advertisement_response.dart';
import '../../game/model/v2/advertisement/base_advertisement_response.dart';
import '../model/image_upload_url_response.dart';

part 'image_repository.g.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return ImageRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class ImageRepository {
  factory ImageRepository(Dio dio, {String baseUrl}) = _ImageRepository;

  /// 이미지 업로드 url 조회 API
  @Headers({'token': 'true'})
  @GET('/image-upload-url')
  Future<ResponseModel<BaseImageUploadUrlResponse>> getImageUploadUrls({
    @Field("category") required ImageType category,
    @Field("count") required int count,
  });
}
