import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/payment/param/pay_request_param.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/provider/dio_provider.dart';
import '../model/payment_completion_response.dart';
import '../model/payment_ready_response.dart';
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

  /// 결제 준비 API
  @Headers({'token': 'true'})
  @POST('/payments/ready')
  Future<ResponseModel<PaymentReadyResponse>> requestBootPay(
      {@Body() required PayRequestParam param});

  @Headers({'token': 'true'})
  @POST('/payments/approve')
  Future<ResponseModel<PaymentCompletionResponse>> approveBootPay(
      @Body() BootPayApproveParam param);
}
