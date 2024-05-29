import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:miti/env/environment.dart';
import 'common/provider/provider_observer.dart';
import 'common/provider/router_provider.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // uriLinkStream.listen((Uri? uri) {
  //   log('uri.host : ${uri?.host}');
  //   if (uri?.host == '') {
  //     // context.pushNamed(name);
  //   }
  //   log("uri: $uri");
  // }, onError: (Object err) {
  //   log("err: $err");
  // });
  await initializeDateFormatting('ko');
  await NaverMapSdk.instance.initialize(clientId: Environment.naverMapClientId);
  KakaoSdk.init(
    nativeAppKey: Environment.kakaoNativeAppKey,
    javaScriptAppKey: Environment.kakaoJavaScriptAppKey,
  );

  runApp(
    ProviderScope(
      observers: [
        CustomProviderObserver(),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'MITI',
          builder: (context, child) {
            return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!);
          },
          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            }),
              // colorScheme: ColorScheme(background: Colors.white, brightness: null, primary: null, onPrimary: null, secondary: null, onSecondary: null, error: null, onError: null, onBackground: null, surface: null, onSurface: null,),
              fontFamily: 'Pretendard',
              inputDecorationTheme: InputDecorationTheme(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                // constraints: BoxConstraints.loose(Size(double.infinity, 58.h)),
                hintStyle: TextStyle(
                  color: const Color(0xFF969696),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.25.sp,
                  height: 24 / 16,
                ),
                fillColor: const Color(0xFFF7F7F7),
                filled: true,
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFFFFF),
                      letterSpacing: -0.25.sp,
                      // height: 22 / 14,
                    )),
                    foregroundColor:
                        MaterialStateProperty.all(const Color(0xFFFFFFFF)),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFF4065F6)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8.r,
                        ),
                      ),
                    ),

                    minimumSize:
                        MaterialStateProperty.all(Size(double.infinity, 48.h)),
                    maximumSize:
                        MaterialStateProperty.all(Size(double.infinity, 48.h))),
              )),
          routerConfig: router,
        );
      },
      // child: const HomeScreen(), // LoginScreen(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}