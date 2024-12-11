import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../court/view/court_map_screen.dart';
import '../../../theme/text_theme.dart';
import '../../component/default_appbar.dart';
import '../../component/default_layout.dart';
import '../../model/entity_enum.dart';

class ErrorScreen extends StatelessWidget {

  static String get routeName => 'error';

  const ErrorScreen({super.key,});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const DefaultAppBar(hasBorder: false),
      bottomNavigationBar: BottomButton(
          button: SizedBox(
            height: 48.h,
            child: TextButton(
                onPressed: () {
                  context.goNamed(CourtMapScreen.routeName);
                },
                child: const Text(
                  '홈으로 가기',
                )),
          )),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Text(
              '서비스 오류',
              style: MITITextStyle.xxl140.copyWith(color: MITIColor.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Text(
              '요청하신 페이지 데이터를 올바르게 가져올 수 없습니다.\n같은 오류가 반복된다면 고객센터로 문의해주세요.',
              style: MITITextStyle.sm150.copyWith(color: MITIColor.gray300),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.w),
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(
                      'https://www.makeittakeit.kr/support/inquiries/new');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Text(
                  '같은 문제가 반복되시나요?',
                  style: MITITextStyle.smBold.copyWith(
                    color: MITIColor.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




