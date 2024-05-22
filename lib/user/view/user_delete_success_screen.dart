import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/user/view/user_delete_screen.dart';

import '../../common/component/default_appbar.dart';
import '../../theme/text_theme.dart';

class UserDeleteSuccessScreen extends StatelessWidget {
  static String get routeName => 'deleteUser';

  const UserDeleteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          const DefaultAppBar(
            isSliver: true,
            title: '회원탈퇴',
          )
        ];
      },
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '회원 탈퇴 완료',
                  style: MITITextStyle.pageMainTextStyle,
                ),
                SizedBox(height: 20.h),
                Text(
                  '회원님의 탈퇴 요청이 성공적으로 처리되었습니다. 이용해주셔서 감사합니다.\n\n회원님의 정보는 탈퇴일로부터 30일 후 안전하게 삭제됩니다.\n그동안 추가적인 문의사항이 있으시면 고객 지원팀에 연락해주시기 바랍니다.\n\n감사합니다.',
                  style: MITITextStyle.pageSubTextStyle.copyWith(
                    color: const Color(0xff1c1c1c),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.goNamed(CourtMapScreen.routeName),
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
