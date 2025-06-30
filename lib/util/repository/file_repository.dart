import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/advertisement/advertisement_response.dart';
import '../../game/model/v2/advertisement/base_advertisement_response.dart';
import '../model/file_upload_url_response.dart';
import '../param/file_upload_param.dart';

part 'file_repository.g.dart';

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return FileRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class FileRepository {
  factory FileRepository(Dio dio, {String baseUrl}) = _FileRepository;

  /// 파일 업로드 url 조회 API
  @Headers({'token': 'true'})
  @GET('/file-upload-url')
  Future<ResponseModel<FileUploadUrlResponse>> getFileUploadUrls(
      {@Queries() required FileUploadParam param});
}
