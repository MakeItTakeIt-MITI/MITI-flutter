import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/kakaopay/model/pay_model.dart';

import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../user/model/user_model.dart';
import '../model/boot_pay_approve_model.dart';
import '../model/boot_pay_request_model.dart';
import '../param/boot_pay_approve_param.dart';

part 'pay_repository.g.dart';

final payRepositoryProvider = Provider<PayRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PayRepository(dio);
});

@RestApi(baseUrl: devServerURL)
abstract class PayRepository {
  factory PayRepository(Dio dio) = _PayRepository;

  @Headers({'token': 'true'})
  @POST('/games/{gameId}/participations')
  Future<ResponseModel<PayBaseModel>> readyPay(
      {@Path() required int gameId,
      @Query('payment_method') required PaymentMethodType type});

  @Headers({'token': 'true'})
  @POST('/payments/kakao/approve/{requestId}')
  Future<ResponseModel<PayApprovalModel>> approvalPay(
      {@Query('pg_token') required String pgToken,
      @Path() required int requestId});

  @Headers({'token': 'true'})
  @POST('/games/{gameId}/participations')
  Future<ResponseModel<BootPayRequestModel>> requestBootPay(
      {@Query('payment_method') required PaymentMethodType paymentMethod,
      @Path() required int gameId});

  @Headers({'token': 'true'})
  @POST('/payments/approve')
  Future<ResponseModel<BootPayApproveModel>> approveBootPay(
      @Body() BootPayApproveParam param);
}
