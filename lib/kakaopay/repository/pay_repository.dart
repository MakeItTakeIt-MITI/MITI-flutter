import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/kakaopay/model/pay_model.dart';

import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../user/model/user_model.dart';

part 'pay_repository.g.dart';

final payRepositoryProvider = Provider<PayRepository>((ref){
  final dio = ref.watch(dioProvider);
  return PayRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class PayRepository {
  factory PayRepository(Dio dio) = _PayRepository;

  @Headers({'token': 'true'})
  @POST('/payments/kakao/ready/games/{gameId}')
  Future<ResponseModel<PayReadyModel>> readyPay({@Path() required int gameId});

  @Headers({'token': 'true'})
  @POST('/payments/kakao/approve/{requestId}')
  Future<ResponseModel<PayApprovalModel>> approvalPay(
      {@Query('pg_token') required String pgToken, @Path() required int requestId});
}
