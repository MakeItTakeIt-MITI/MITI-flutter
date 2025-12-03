import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/model/v2/base_deleted_user_response.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/error/auth_error.dart';
import '../../auth/provider/login_provider.dart';
import '../../common/model/default_model.dart';
import '../../common/provider/secure_storage_provider.dart';
import '../../court/view/court_map_screen.dart';
import '../../game/model/v2/auth/login_response.dart';
import '../provider/user_provider.dart';

class RestoreUserScreen extends StatelessWidget {
  static String get routeName => 'restoreUser';
  final BaseDeletedUserResponse deleteUser;
  final bool fromLogin;

  const RestoreUserScreen(
      {super.key, required this.deleteUser, required this.fromLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        hasBorder: false,
      ),
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return BottomButton(
              hasBorder: false,
              button: TextButton(
                  onPressed: () => {
                        _restoreUserInfo(
                            deleteUser, ref, context, context.mounted)
                      },
                  child: const Text("로그인하기")));
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 36.h),
            Text(
              fromLogin ? "MITI를 사용하신 적이 있으신가요?" : '혹시 MITI를 탈퇴하셨나요?',
              style: V2MITITextStyle.largeBoldTight
                  .copyWith(color: V2MITIColor.white),
            ),
            SizedBox(height: 24.h),
            Text(
              fromLogin
                  ? '${deleteUser.name}님 이름으로 가입하신 기존 계정이 있습니다.\n해당 계정 정보로 MITI를 다시 이용해보시겠어요?'
                  : '해당 정보의 계정은 탈퇴처리 되어있습니다.\n계정을 복구하고 MITI 를 다시 이용하시겠어요?',
              style: V2MITITextStyle.smallRegularNormal
                  .copyWith(color: V2MITIColor.gray1),
            ),
            SizedBox(height: 36.h),
            Column(
              spacing: 12.h,
              children: [
                _UserInfo(
                  title: '이름',
                  content: deleteUser.name,
                ),
                _UserInfo(
                  title: '생년월일',
                  content: '',
                ),
                _UserInfo(
                  title: '휴대폰번호',
                  content: '',
                ),
                _UserInfo(
                  title: '로그인방식',
                  content: deleteUser.signupMethod.name[0].toUpperCase() +
                      deleteUser.signupMethod.name.substring(1),
                ),
              ],
            ),
            const Spacer(),
            Row(
              spacing: 8.w,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '새로운 계정으로 시작하고 싶으신가요?',
                  style: V2MITITextStyle.tinyMediumTight.copyWith(
                    color: V2MITIColor.gray5,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final uri =
                        Uri.parse('https://www.makeittakeit.kr/inquiries');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    "고객센터",
                    style: V2MITITextStyle.tinyMediumTight.copyWith(
                      color: V2MITIColor.gray5,
                      decoration: TextDecoration.underline,
                      decorationColor: V2MITIColor.gray5,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreUserInfo(BaseDeletedUserResponse deleteUser,
      WidgetRef ref, BuildContext context, bool mounted) async {
    ///  탈퇴 사용자 복구
    final result = await ref.read(restoreUserInfoProvider(
            userId: deleteUser.id,
            userRestoreToken: deleteUser.userRestoreToken)
        .future);

    if (mounted) {
      if (result is ErrorModel) {
        AuthError.fromModel(model: result)
            .responseError(context, AuthApiType.restoreUserInfo, ref);
      } else {
        final value = result as ResponseModel<LoginResponse>;
        // 로그인 처리
        final model = value.data!;
        final storage = ref.read(secureStorageProvider);

        await saveUserInfo(storage, model, widgetRef: ref);
        context.goNamed(CourtMapScreen.routeName);
      }
    }
  }
}

class _UserInfo extends StatelessWidget {
  final String title;
  final String content;

  const _UserInfo({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: V2MITITextStyle.regularRegularTight
              .copyWith(color: V2MITIColor.gray5),
        ),
        Text(
          content,
          style: V2MITITextStyle.regularMediumTight
              .copyWith(color: V2MITIColor.white),
        )
      ],
    );
  }
}
