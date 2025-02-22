import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/kakaopay/model/pay_model.dart';

import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/payment/payment_completed_response.dart';
import '../../user/model/user_model.dart';
import '../model/boot_pay_approve_model.dart';
import '../model/boot_pay_request_model.dart';
import '../param/boot_pay_approve_param.dart';

part 'pay_repository.g.dart';

final payRepositoryProvider = Provider<PayRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return PayRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class PayRepository {
  factory PayRepository(Dio dio, {String baseUrl}) = _PayRepository;

  @Headers({'token': 'true'})
  @POST('/payments/kakao/approve/{requestId}')
  Future<ResponseModel<PayApprovalModel>> approvalPay(
      {@Query('pg_token') required String pgToken,
      @Path() required int requestId});


  /// 경기 참여 요청 API - 유료 경기, 무료 경기
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/participations')
  Future<ResponseModel<PayBaseModel>> requestBootPay(
      {@Path() required int gameId});

  @Headers({'token': 'true'})
  @POST('/payments/bootpay/approve')
  Future<ResponseModel<PaymentCompletedResponse>> approveBootPay(
      @Body() BootPayApproveParam param);
}
