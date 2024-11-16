import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const niceDomain = 'https://pg-web.nicepay.co.kr';
const reqSubPath = "/v3/gwPayment.jsp";

class NicePaymentScreen extends StatefulWidget {
  static String get routeName => 'nicePayment';
  final int gameId;

  const NicePaymentScreen({super.key, required this.gameId});

  @override
  State<NicePaymentScreen> createState() => _NicePaymentScreenState();
}

class _NicePaymentScreenState extends State<NicePaymentScreen> {
  final platform = const MethodChannel('fcm_default_channel');
  // late final WebViewController controller;
  // Map<String, Object> inputData = {
  //   "GoodsName": "참가비 \"KHU MITI 픽...\"",
  //   "Amt": 10000,
  //   "MID": "MITI12345m",
  //   "EdiDate": "20241113143050",
  //   "Moid": "2F6BbmVzxUcFFpZUTH7Epq",
  //   "SignData":
  //       "1d4f8243eb5aeecfc8db2f92f0ef2ef294a646d8e7406e0e812a28073df708a2",
  //   "PayMethod": "card",
  //   "ReturnURL": "http://127.0.0.1:8000",
  //   "BuyerName": "김미티",
  //   "BuyerTel": "01054329875",
  //   "ReqReserved": "",
  //   "CharSet": "utf-8"
  // };
  // late String _jsCode;
  //
  // // JavaScript 파일을 로드하여 변수에 저장
  // Future<void> _loadJavaScriptFile() async {
  //   _jsCode = await rootBundle.loadString('assets/goPay.js');
  //   log('jsCode = $_jsCode');
  // }
  //
  // @override
  // void initState() {
  //   String param = jsonEncode(inputData);
  //   super.initState();
  //   controller = WebViewController()
  //     ..setBackgroundColor(Colors.white)
  //     ..setNavigationDelegate(
  //       NavigationDelegate(
  //           onNavigationRequest: (NavigationRequest request) async {
  //             log("onNavigationRequest URL detected: ${request.url}");
  //             if (!request.url.startsWith('http') &&
  //                 !request.url.startsWith('https')) {
  //               log('intent 진입');
  //               if (Platform.isAndroid) {
  //                 log('intent android 진입');
  //                 getAppUrl(request.url.toString());
  //
  //                 return NavigationDecision.prevent;
  //               } else if (Platform.isIOS) {
  //                 log('intent ios 진입 = ${request.url}');
  //                 if (await canLaunchUrl(Uri.parse(request.url))) {
  //                   log('navigate url : ${request.url}');
  //                   await launchUrl(
  //                     Uri.parse(request.url),
  //                   );
  //                   return NavigationDecision.prevent;
  //                 }
  //               }
  //             }
  //
  //             // returnUrl 감지
  //             if (request.url.contains("http://localhost:4567/serverAuth")) {
  //               log("Return URL detected: ${request.url}");
  //
  //               // Flutter에서 처리 (예: 요청 중단)
  //               // _handleReturnUrl(request.url);
  //               return NavigationDecision.prevent;
  //             }
  //
  //             return NavigationDecision.navigate;
  //           },
  //           onProgress: (int progress) {
  //             log('onProgress $progress');
  //           },
  //           onPageStarted: (String url) {
  //             log('onPageStarted $url');
  //             // controller.
  //           },
  //           onPageFinished: (String url) async {
  //             log('onPageFinished $url');
  //             // await callJs();
  //             // await controller.runJavaScript("serverAuth();"); // serverAuth 호출
  //             /// error url
  //             //https://web.nicepay.co.kr/v3/smart/common/error.jsp?errCd=4004&token=NICETOKNF7526F9D710C97EAD08B06568CDCA355&errMsg=/v3/smart/common/error.jsp
  //           },
  //           onWebResourceError: (WebResourceError error) {
  //             log('onWebResourceError ${error.errorType} ${error.errorCode} ${error.description}');
  //           },
  //           onUrlChange: (UrlChange change) {}),
  //     )
  //     ..addJavaScriptChannel(
  //       'FlutterLog',
  //       onMessageReceived: (message) {
  //         // JavaScript에서 전달한 로그 출력
  //         log('JavaScript log: ${message.message}');
  //       },
  //     )
  //     ..setJavaScriptMode(JavaScriptMode.unrestricted);
  //   // ..loadRequest(
  //   //     // Uri.parse('https://web.nicepay.co.kr/demo/v3/mobileReq.jsp'),
  //   //     // Uri.parse(niceDomain + reqSubPath),
  //   //     Uri.parse('https://naver.com'),
  //   //     method: LoadRequestMethod.get);
  //
  //   // controller.runJavaScript(javaScript);
  //   WidgetsBinding.instance.addPostFrameCallback((s) {
  //     callJs();
  //   });
  // }
  //
  // Future<void> callJs() async {
  //   await _loadJavaScriptFile();
  //   await controller.runJavaScript(_jsCode); // goPay.js 실행
  //
  //   // 전달할 데이터를 JSON으로 변환
  //   final Map<String, dynamic> paymentData = {
  //     "GoodsName": "참가비 \\\"KHU MITI 픽...\\\"",
  //     "Amt": 1000,
  //     "MID": "nicepay00m",
  //     "EdiDate": "20241115140954",
  //     "Moid": "9AnhF6QBUkpMBxMvx6ZYG8",
  //     "SignData": "084f2ab609154115b94818ce56f3a0dccf112602522fd3d8447a3b9d7957f9d1",
  //     "PayMethod": "CARD",
  //     "ReturnURL": "https://api.makeittakeit.kr/payments/nice/callback",
  //     "BuyerName": "김미티",
  //     "BuyerTel": "01054329875",
  //     "ReqReserved": "",
  //     "CharSet": "utf-8"
  //   };
  //
  //   final jsonString = jsonEncode(paymentData); // Map을 JSON 문자열로 변환
  //
  //   // JavaScript로 데이터 전달 및 함수 호출
  //   await controller.runJavaScript("""
  //   callNicePayWithData(${jsonEncode(jsonString)});
  // """);
  //
  //   // goPay.js의 NicePay script 로드 후 serverAuth 호출
  //   // await controller.runJavaScript("loadNicePay();");
  //   // await controller.runJavaScript("serverAuth();");
  // }

  Future getAppUrl(String url) async {
    await platform.invokeMethod('getAppUrl', <String, Object>{'url': url}).then(
        (value) async {
      log('paring url : $value');

      if (value.toString().startsWith('ispmobile://')) {
        await platform.invokeMethod(
            'startAct', <String, Object>{'url': url}).then((value) {
          log('parsing url : $value');

          return;
        });
      }
      if (value.toString().startsWith('intent://')) {
        await platform.invokeMethod(
            'startAct', <String, Object>{'url': url}).then((value) {
          log('parsing url : $value');

          return;
        });
      }

      if (await canLaunchUrl(Uri.parse(value))) {
        log('http value ${value}');
        await launchUrl(
          Uri.parse(value),
        );

        return;
      } else {
        // showNotiDialog(context, '해당 앱 설치 후 이용바랍니다.');

        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        // log('didPop = $didPop, popScope result = ${result}');
        // if (await controller.canGoBack()) {
        //   // WebView 내에서 이전 페이지로 이동
        //   controller.goBack();
        //   // return false; // 앱 종료를 막음
        // } else {
        //   // 더 이상 이전 페이지가 없으면 앱을 종료
        //   // return true;
        // }
      },
      child: Scaffold(
        // body: SafeArea(
        //   child: WebViewWidget(
        //     controller: controller,
        //   ),
        // ),
      ),
    );
  }
}
