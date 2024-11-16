import 'package:dio/dio.dart';
import 'package:miti/etc/model/tc_policy_model.dart';
import 'package:retrofit/http.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/model/default_model.dart';
import '../../court/model/court_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';

part 'tc_policy_repository.g.dart';

final tcPolicyRepositoryProvider = Provider<TcPolicyRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TcPolicyRepository(dio);
});

@RestApi(baseUrl: devServerURL)
abstract class TcPolicyRepository {
  factory TcPolicyRepository(Dio dio) = _TcPolicyRepository;

  @GET('/policies')
  Future<ResponseListModel<TcPolicyModel>> getPolicyList();

  @GET('/policies/{policyId}')
  Future<ResponseModel<TcPolicyDetailModel>> getDetail({
    @Path('policyId') required int policyId,
  });
}
