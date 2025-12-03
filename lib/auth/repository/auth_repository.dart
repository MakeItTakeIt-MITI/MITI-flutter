import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/auth/param/phone_verify_param.dart';
import 'package:miti/auth/param/update_token_param.dart';
import 'package:miti/game/model/v2/auth/login_response.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/auth/base_token_response.dart';
import '../../game/model/v2/auth/password_update_request_response.dart';
import '../../game/model/v2/auth/phone_authentication_request_response.dart';
import '../../user/model/user_model.dart';
import '../model/find_info_model.dart';
import '../model/signup_model.dart';
import '../param/auth_param.dart';
import '../param/signup_param.dart';

part 'auth_repository.g.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  final repository = AuthRepository(dio, baseUrl: baseUrl);
  return repository;
});

@RestApi()
abstract class AuthRepository {
  factory AuthRepository(Dio dio, {String baseUrl}) = _AuthRepository;

  @POST('/auth/signup-check')
  Future<ResponseModel<SignUpCheckModel>> signUpCheck(
      {@Body() required BaseParam param});

  @Headers({'token': 'true', 'refresh': 'true'})
  @POST('/auth/logout')
  Future<CompletedModel> logout();

  @Headers({'refresh': 'true'})
  @POST('/auth/refresh-token')
  Future<ResponseModel<BaseTokenResponse>> getReIssueToken();

  /////////////////////////////////////////
  /// 인증 코드 전송 요청 API
  @POST('/auth/send-code')
  Future<ResponseModel<PhoneAuthenticationRequestResponse>> sendCode(
      {@Body() required SendCodeParam param});

  /// 회원가입, 이메일 찾기, 비밀번호 찾기 번호 인증
  @POST('/auth/verify-code')
  Future<ResponseModel<SignUpVerifyModel>> verifySignPhone(
      {@Body() required PhoneVerifyParam param});

  @POST('/auth/verify-code')
  Future<ResponseModel<EmailVerifyModel>> verifyEmailPhone(
      {@Body() required PhoneVerifyParam param});

  @POST('/auth/verify-code')
  Future<ResponseModel<PasswordVerifyModel>> verifyPasswordPhone(
      {@Body() required PhoneVerifyParam param});

  @POST('/auth/login/{provider}')
  Future<ResponseModel<LoginResponse>> login({
    @Path() required SignupMethodType provider,
    @Body() required LoginBaseParam param,
    @Header("fcm-token") required String fcmToken,
  });

  @POST('/auth/signup/{provider}')
  Future<ResponseModel<LoginResponse>> signUp({
    @Path() required SignupMethodType provider,
    @Body() required SignUpBaseParam param,
  });

  @POST('/auth/email-duplication-check')
  Future<ResponseModel<SignUpCheckModel>> duplicateCheckEmail(
      {@Body() required EmailCheckParam param});

  @Headers({'token': 'true'})
  @POST('/auth/password-authentication')
  Future<ResponseModel<PasswordUpdateRequestResponse>> getUpdateToken(
      {@Body() required UpdateTokenParam param});

  @Headers({'token': 'true'})
  @DELETE('/auth/withdraw')
  Future<ResponseModel<UserModel>> deleteUser();
}
