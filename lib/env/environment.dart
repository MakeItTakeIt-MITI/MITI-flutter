import 'package:envied/envied.dart';

part 'environment.g.dart';

@Envied(path: '.env')
abstract class Environment {
  Environment._();

  @EnviedField(varName: 'KAKAO_NATIVE_APP_KEY', obfuscate: true)
  static final String kakaoNativeAppKey = _Environment.kakaoNativeAppKey;
  @EnviedField(varName: 'KAKAO_JAVA_SCRIPT_APP_KEY', obfuscate: true)
  static final String kakaoJavaScriptAppKey =
      _Environment.kakaoJavaScriptAppKey;
  @EnviedField(varName: 'NAVER_MAP_CLIENT_ID', obfuscate: true)
  static final String naverMapClientId = _Environment.naverMapClientId;
  @EnviedField(varName: 'KAKAO_PAY_CLIENT_ID', obfuscate: true)
  static final String kakaoPayClientId = _Environment.kakaoPayClientId;
  @EnviedField(varName: 'KAKAO_PAY_CLIENT_SECRET', obfuscate: true)
  static final String kakaoPayClientSecret = _Environment.kakaoPayClientSecret;
  @EnviedField(varName: 'KAKAO_PAY_SECRET_KEY', obfuscate: true)
  static final String kakaoPaySecretKey = _Environment.kakaoPaySecretKey;
  @EnviedField(varName: 'KAKAO_PAY_SECRET_KEY_DEV', obfuscate: true)
  static final String kakaoPaySecretKeyDev = _Environment.kakaoPaySecretKeyDev;
}
