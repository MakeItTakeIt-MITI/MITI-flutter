import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/text_theme.dart';
import '../../component/default_appbar.dart';

class ErrorScreen extends StatelessWidget {
  static String get routeName => 'error';

  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
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
                    '해당 페이지를 찾을 수 없습니다.',
                    style: MITITextStyle.pageMainTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
