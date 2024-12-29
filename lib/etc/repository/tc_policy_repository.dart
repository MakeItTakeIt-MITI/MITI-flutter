import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:miti/etc/model/tc_policy_model.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/default_model.dart';
import '../../court/model/court_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';

part 'tc_policy_repository.g.dart';

final tcPolicyRepositoryProvider = Provider<TcPolicyRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return TcPolicyRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class TcPolicyRepository {
  factory TcPolicyRepository(Dio dio, {String baseUrl}) = _TcPolicyRepository;

  @GET('/policies')
  Future<ResponseListModel<TcPolicyModel>> getPolicyList();

  @GET('/policies/{policyId}')
  Future<ResponseModel<TcPolicyDetailModel>> getDetail({
    @Path('policyId') required int policyId,
  });
}
