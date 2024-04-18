import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:typed_data';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:miti/auth/view/login_screen.dart';
import 'package:miti/common/provider/scroll_provider.dart';
import 'package:miti/court/component/court_component.dart';
import 'package:miti/env/environment.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'court/view/court_map_screen.dart';
import 'game/view/game_screen.dart';

class ShellRoutePageState with ChangeNotifier {
  ScrollController topController = ScrollController();
  ScrollController bottomController = ScrollController();

  void onScroll(double offset) {
    double topMax = topController.position.maxScrollExtent;
    double topOffset = min(topMax, offset);
    topController.jumpTo(topOffset);

    double bottomOffset = max(0, offset - topMax);
    bottomController.jumpTo(bottomOffset);
  }
}

class InfoBody extends StatelessWidget {
  static String get routeName => 'info';

  const InfoBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          context.pushNamed(LoginScreen.routeName);
        },
        child: Text('로그인'),
      ),
    );
  }
}

class MenuBody extends StatefulWidget {
  static String get routeName => 'menu';

  const MenuBody({
    super.key,
  });

  @override
  State<MenuBody> createState() => _MenuBodyState();
}

class _MenuBodyState extends State<MenuBody> {
  late final InAppWebViewController _webViewController;
  late final WebViewController controller;
  static final platform = MethodChannel('fcm_default_channel');
  final header = {
    'Authorization': 'SECRET_KEY ${Environment.kakaoPaySecretKeyDev}',
    'Content-Type': 'application/json',
  };
  final body = Uint8List.fromList(utf8.encode(jsonEncode({
    "cid": "TC0ONETIME",
    "partner_order_id": "partner_order_id",
    "partner_user_id": "partner_user_id",
    "item_name": "초코파이",
    "quantity": "1",
    "total_amount": "2200",
    "vat_amount": "200",
    "tax_free_amount": "0",
    "approval_url": "http://127.0.0.1/approval",
    "fail_url": "http://127.0.0.1/fail",
    "cancel_url": "http://127.0.0.1/cancel"
  })));

  @override
  void initState() {
    super.initState();
    Uint8List postData = Uint8List.fromList(utf8.encode(jsonEncode({
      "cid": "TC0ONETIME",
      "partner_order_id": "partner_order_id",
      "partner_user_id": "partner_user_id",
      "item_name": "초코파이",
      "quantity": "1",
      "total_amount": "2200",
      "vat_amount": "200",
      "tax_free_amount": "0",
      "approval_url": "https://developers.kakao.com/success",
      "fail_url": "https://developers.kakao.com/fail",
      "cancel_url": "https://developers.kakao.com/cancel"
    })));
    log('Uint8List $Uint8List');
    controller = WebViewController()
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            log('navigate url : ${request.url}');
            if (Platform.isAndroid) {
              final otherAppUri = Uri.parse(
                  await MethodChannel('fcm_default_channel')
                      .invokeMethod('convertUri', {"uri": request.url}));
              await launchUrl(
                otherAppUri,
              );
              return NavigationDecision.prevent;
            }

            // final intent = AndroidIntent(
            //   action: 'action_view',
            //   data:
            //   'https://online-pay.kakao.com/mockup/v1/a705f03dbcd0983568f4c90cada970451bf599da6d0f35734e88bbd7da209ade/mInfo',
            //   arguments: {'txn_id': 'T61a6dcc65886da9c51e'},
            // );
            // await intent.launch();
            // return NavigationDecision.prevent;

            // 2 채널이용
            // if (!request.url.startsWith('http') &&
            //     !request.url.startsWith('https')) {
            //   log('intent 진입');
            //   if (Platform.isAndroid) {
            //     log('intent android 진입');
            //     final intent = AndroidIntent(
            //       action: 'action_view',
            //       data:
            //           'https://online-pay.kakao.com/mockup/v1/a705f03dbcd0983568f4c90cada970451bf599da6d0f35734e88bbd7da209ade/mInfo',
            //       arguments: {'txn_id': 'T61a6dcc65886da9c51e'},
            //     );
            //     await intent.launch();
            //     // getAppUrl(request.url.toString());
            //
            //     return NavigationDecision.prevent;
            //   } else if (Platform.isIOS) {
            //     log('intent ios 진입');
            //     if (await canLaunchUrl(Uri.parse(request.url))) {
            //       log('navigate url : ${request.url}');
            //
            //       await launchUrl(
            //         Uri.parse(request.url),
            //       );
            //
            //       return NavigationDecision.prevent;
            //     }
            //   }
            // }

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
        Uri.parse(
            'https://online-pay.kakao.com/mockup/v1/9f4007c85a0908bbf7935cf44db72c450c8f4727758086318f81690e98364965/mInfo'),
        method: LoadRequestMethod.get,
        // headers: {
        //   'Authorization': 'SECRET_KEY $SECRET_KEY_DEV',
        //   'Content-Type': 'application/json',
        // },
        // body: postData,
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

    return Container(
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(
              'https://online-pay.kakao.com/mockup/v1/c5f8201c25922b7eb117e5e2b769f7e594b7ccac8aabb6eed8fb38fd9e25377a/mInfo'),
          method: 'GET',
          // headers: header,
          // body: body,
        ),
        androidShouldInterceptRequest: (controller, request) async {
          log('request $request');
          await controller.stopLoading();
          return null;
        },
        initialOptions: InAppWebViewGroupOptions(
            android: AndroidInAppWebViewOptions(
                mixedContentMode:
                    AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW)),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          // 웹페이지 로드가 끝났을 때 응답을 가져와 로그로 출력
          final response = await controller.getHtml();
          log('url.data = ${url?.data}');
          print("Response: $response");
        },
      ),
    );
  }
}

class DefaultShellScreen extends ConsumerStatefulWidget {
  final Widget body;

  const DefaultShellScreen({super.key, required this.body});

  @override
  ConsumerState<DefaultShellScreen> createState() => _DefaultShellScreenState();
}

class _DefaultShellScreenState extends ConsumerState<DefaultShellScreen> {
  @override
  void initState() {
    super.initState();
  }

  int getIndex(BuildContext context) {
    if (GoRouterState.of(context).matchedLocation == '/home') {
      return 0;
    } else if (GoRouterState.of(context).matchedLocation == '/game') {
      return 1;
    } else if (GoRouterState.of(context).matchedLocation == '/info') {
      return 2;
    } else {
      return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(pageScrollControllerProvider);
    final index = getIndex(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: widget.body,
        bottomNavigationBar: CustomBottomNavigationBar(
          index: index,
          onTap: (int page) {
            if (page == 0) {
              if (GoRouterState.of(context).matchedLocation == '/home') {
                // controller[0].animateTo(0,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              } else {
                context.goNamed(CourtMapScreen.routeName);
              }
            } else if (page == 1) {
              if (GoRouterState.of(context).matchedLocation == '/game') {
                // controller[1].animateTo(0,
                //     duration: const Duration(milliseconds: 500),
                //     curve: Curves.easeInOut);
              } else {
                context.goNamed(GameScreen.routeName);
              }
            } else if (page == 2) {
              if (GoRouterState.of(context).matchedLocation == '/info') {
                controller[2].animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              } else {
                context.goNamed(InfoBody.routeName);
              }
            } else {
              if (GoRouterState.of(context).matchedLocation == '/menu') {
                controller[3].animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              } else {
                context.goNamed(MenuBody.routeName);
              }
            }
          },
        ));
  }
}

typedef BottomTap = void Function(int page);

class CustomBottomNavigationBar extends StatelessWidget {
  final int index;
  final BottomTap onTap;

  const CustomBottomNavigationBar(
      {super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.1),
              offset: Offset(0, 1.h),
              blurRadius: 3.r,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.08),
              offset: Offset(0, -1.h),
              blurRadius: 1.r,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.06),
              offset: Offset(0, -1.h),
              blurRadius: 2.r,
            ),
          ]),
      constraints: BoxConstraints.tight(Size(double.infinity, 80.h)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(0);
              },
              label: '홈',
              selected: index == 0,
              iconName: 'home',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(1);
              },
              label: '경기',
              selected: index == 1,
              iconName: 'play',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(2);
              },
              label: '내정보',
              selected: index == 2,
              iconName: 'info',
            ),
          ),
          Expanded(
            child: CustomBottomItem(
              onTap: () {
                onTap(3);
              },
              label: '전체',
              selected: index == 3,
              iconName: 'menu',
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomItem extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool selected;
  final String iconName;

  const CustomBottomItem(
      {super.key,
      required this.onTap,
      required this.label,
      required this.selected,
      required this.iconName});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 13.sp,
      letterSpacing: -0.25.sp,
      fontWeight: FontWeight.w600,
    );
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/icon/$iconName.svg',
            height: 24.r,
            width: 24.r,
            colorFilter: ColorFilter.mode(
                selected ? const Color(0xFF4065F6) : const Color(0xFF969696),
                BlendMode.srcIn),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: textStyle.copyWith(
              color:
                  selected ? const Color(0xFF4065F6) : const Color(0xFF969696),
            ),
          )
        ],
      ),
    );
  }
}
