import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/game/view/game_detail_screen.dart';
import 'package:miti/kakaopay/provider/pay_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/model/default_model.dart';
import 'approval_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  static String get routeName => 'payment';
  final int gameId;
  final String redirectUrl;

  const PaymentScreen(
      {super.key, required this.redirectUrl, required this.gameId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late final WebViewController controller;
  final platform = const MethodChannel('fcm_default_channel');

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            log('navigate url : ${request.url}');
            if (request.url.startsWith(
                'https://www.makeittakeit.kr/payments/kakao/approve')) {
              /// 결제 성공
              final url = request.url;
              final pgToken = Uri.parse(url).queryParameters['pg_token']!;
              final requestId =
                  Uri.parse(url).queryParameters['payment_request_id']!;
              log('pgToken $pgToken');
              log('requestId $requestId');

              final result = ref.read(approvalPayProvider(
                      requestId: int.parse(requestId), pgToken: pgToken)
                  .future);
              if (result is ErrorModel) {
              } else {
                context.goNamed(KakaoPayApprovalScreen.routeName);
              }

              return NavigationDecision.prevent;
            } else if (request.url.startsWith(
                'https://www.makeittakeit.kr/payments/kakao/cancel')) {
              /// 결제 취소
              Map<String, String> pathParameters = {
                'gameId': widget.gameId.toString()
              };
              context.goNamed(GameDetailScreen.routeName,
                  pathParameters: pathParameters);
              return NavigationDecision.prevent;
            } else if (request.url.startsWith(
                'https://www.makeittakeit.kr/payments/kakao/fail')) {
              /// 결제 실패
              Map<String, String> pathParameters = {
                'gameId': widget.gameId.toString()
              };
              context.goNamed(GameDetailScreen.routeName,
                  pathParameters: pathParameters);
              showDialog(
                  context: context,
                  builder: (_) {
                    return const CustomDialog(
                      title: '카카오 결제 실패',
                      content: '결제가 정상적으로 완료되지 않았습니다.\n다시 결제를 진행해주세요.',
                    );
                  });
              return NavigationDecision.prevent;
            }

            if (!request.url.startsWith('http') &&
                !request.url.startsWith('https')) {
              log('intent 진입');
              if (Platform.isAndroid) {
                log('intent android 진입');
                getAppUrl(request.url.toString());

                return NavigationDecision.prevent;
              } else if (Platform.isIOS) {
                log('intent ios 진입');
                if (await canLaunchUrl(Uri.parse(request.url))) {
                  log('navigate url : ${request.url}');
                  await launchUrl(
                    Uri.parse(request.url),
                  );
                  return NavigationDecision.prevent;
                }
              }
            }

            return NavigationDecision.navigate;
          },
          onProgress: (int progress) {
            log('onProgress $progress');
          },
          onPageStarted: (String url) {
            log('onPageStarted $url');
          },
          onPageFinished: (String url) {
            log('onPageFinished $url');
          },
          onWebResourceError: (WebResourceError error) {
            log('onWebResourceError ${error.errorType} ${error.errorCode} ${error.description}');
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.redirectUrl),
        method: LoadRequestMethod.get,
      );
  }

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
    return Container(
      child: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
