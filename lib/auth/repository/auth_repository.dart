import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/auth/param/find_email_param.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../model/auth_model.dart';
import '../model/code_model.dart';
import '../model/find_email_model.dart';
import '../model/signup_model.dart';
import '../param/auth_param.dart';
import '../param/login_param.dart';
import '../param/signup_param.dart';

part 'auth_repository.g.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final repository = AuthRepository(dio);
  return repository;
});

@RestApi(baseUrl: serverURL)
abstract class AuthRepository {
  factory AuthRepository(Dio dio) = _AuthRepository;

  @POST('/auth/signup')
  Future<ResponseModel<SignUpModel>> signUp(
      {@Body() required SignUpParam param});

  @POST('/auth/signup-check')
  Future<ResponseModel<SignUpCheckModel>> signUpCheck(
      {@Body() required BaseParam param});

  @POST('/auth/login')
  Future<ResponseModel<LoginModel>> login({@Body() required LoginParam param});

  @POST('/auth/{user_info_token}/authenticate')
  Future<ResponseModel<ResponseCodeModel>> sendCode(
      {@Path() required String user_info_token,
      @Body() required CodeParam param});


  @POST('/auth/send-sms')
  Future<ResponseModel<RequestCodeModel>> requestCode(
      {@Body() required RequestCodeParam param});

  @Headers({'refresh': 'true'})
  @POST('/auth/refresh-token')
  Future<ResponseModel<TokenModel>> reissueToken();

  @Headers({'Authorization': 'true', 'refresh': 'true'})
  @POST('/auth/logout')
  Future<CompletedModel> logout();

  @POST('/auth/find-email')
  Future<ResponseModel<FindEmailModel>> findEmail(
      {@Body() required FindEmailParam param});

  @POST('/auth/password-reset-email')
  Future<ResponseModel<RequestNewPasswordModel>> requestNewPassword(
      {@Body() required RequestNewPasswordParam param});

  @POST('/auth/reset-password/{token}')
  Future<ResponseModel<RequestNewPasswordModel>> resetPassword(
      {@Path() required String token,
      @Body() required ResetPasswordParam param});

  @POST('/auth/oauth/{provider}/login')
  Future<ResponseModel<LoginModel>> oauthLogin(
      {@Path() required String provider,
        @Body() required OauthLoginParam param});
}
