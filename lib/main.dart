import 'dart:developer';

import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'common/provider/provider_observer.dart';
import 'common/provider/router_provider.dart';

void main() async {
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
  await NaverMapSdk.instance.initialize(clientId: 'cwog9btafs');
  KakaoSdk.init(
    nativeAppKey: '6c982be35c0f15be99a90f823b7da8f5',
    javaScriptAppKey: '	70c742501212b21cb4303ea86cccd074',
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
              // colorScheme: ColorScheme(background: Colors.white, brightness: null, primary: null, onPrimary: null, secondary: null, onSecondary: null, error: null, onError: null, onBackground: null, surface: null, onSurface: null,),
              fontFamily: 'Pretendard',
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                    textStyle: MaterialStateProperty.all(TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFFFFF),
                      letterSpacing: -0.25.sp,
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
