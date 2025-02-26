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
  @EnviedField(varName: 'BOOT_PAY_JAVA_SCRIPT_KEY', obfuscate: true)
  static final String bootPayJavaScriptKey = _Environment.bootPayJavaScriptKey;
  @EnviedField(varName: 'BOOT_PAY_ANDROID_KEY', obfuscate: true)
  static final String bootPayAndroidKey = _Environment.bootPayAndroidKey;
  @EnviedField(varName: 'BOOT_PAY_IOS_KEY', obfuscate: true)
  static final String bootPayIosKey = _Environment.bootPayIosKey;

  @EnviedField(varName: 'BOOT_PAY_DEV_JAVA_SCRIPT_KEY', obfuscate: true)
  static final String bootPayDevJavaScriptKey = _Environment.bootPayDevJavaScriptKey;
  @EnviedField(varName: 'BOOT_PAY_DEV_ANDROID_KEY', obfuscate: true)
  static final String bootPayDevAndroidKey = _Environment.bootPayDevAndroidKey;
  @EnviedField(varName: 'BOOT_PAY_DEV_IOS_KEY', obfuscate: true)
  static final String bootPayDevIosKey = _Environment.bootPayDevIosKey;
}
