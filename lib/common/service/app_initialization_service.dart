// services/app_initialization_service.dart
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:miti/env/environment.dart';
import 'package:miti/util/util.dart';

import '../../firebase_options_dev.dart' as dev;
import '../../firebase_options_prod.dart' as prod;
import '../../post/repository/search_history_repository.dart';

class AppInitializationService {
  /// 환경 초기화
  static Future<void> initialize(String env) async {
    await _setupEnvironment(BuildEnvironment.production, env);
    await _setupFlutter();
    await _setupExternalServices(env);
  }

  static Future<void> _setupEnvironment(
      BuildEnvironment env, String envFile) async {
    EnvUtil.instance.initialize(environment: env);

    print("Loading environment: $envFile");
    log("Loading environment: $envFile");
    await dotenv.load(fileName: envFile);

    HttpOverrides.global = MyHttpOverrides();
  }

  static Future<void> _setupFlutter() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await initializeDateFormatting('ko');
  }

  static Future<void> _setupExternalServices(String env) async {
    // Naver Map 초기화
    await NaverMapSdk.instance.initialize(
      clientId: Environment.naverMapClientId,
    );

    // Kakao SDK 초기화
    KakaoSdk.init(
      nativeAppKey: Environment.kakaoNativeAppKey,
      javaScriptAppKey: Environment.kakaoJavaScriptAppKey,
    );

    // Hive 초기화
    await Hive.initFlutter();
    await Hive.openBox<bool>('permission');
    await Hive.openBox<String>('recentUpdateVersion');

    // Search History 초기화
    await SearchHistoryRepository().initialize();

    final isDev = env == ".env.dev";
    try {
      // Firebase 초기화
      await Firebase.initializeApp(
        options: isDev
            ? dev.DefaultFirebaseOptions.currentPlatform
            : prod.DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        // 이미 초기화된 앱 사용
        print('Firebase already initialized');
      } else {
        rethrow;
      }
    }

  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
