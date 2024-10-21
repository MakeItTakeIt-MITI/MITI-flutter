import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';

import '../../../theme/text_theme.dart';
import '../../component/default_appbar.dart';
import '../../model/entity_enum.dart';

class ErrorScreen extends StatelessWidget {
  final ErrorScreenType errorType;

  static String get routeName => 'error';

  const ErrorScreen({super.key, required this.errorType});

  @override
  Widget build(BuildContext context) {
    String content;
    switch (errorType) {
      case ErrorScreenType.notFound:
        content = '해당 페이지를 찾을 수 없습니다.';
      case ErrorScreenType.unAuthorization:
        content = '해당 페이지의 권한이 없습니다.';
      case ErrorScreenType.server:
        content = '서버가 불안정해 잠시후 다시 이용해주세요.';
    }
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '오류',
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      content,
                      style: MITITextStyle.sm.copyWith(color: MITIColor.gray50),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
