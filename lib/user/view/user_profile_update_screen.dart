import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/account/component/bank_card.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/provider/logout_provider.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_delete_screen.dart';
import 'package:miti/user/view/user_profile_form_screen.dart';

import '../../auth/error/auth_error.dart';
import '../../common/component/custom_dialog.dart';
import '../../util/util.dart';
import '../component/skeleton/user_info_skeleton.dart';
import '../model/user_model.dart';

class UserProfileUpdateScreen extends ConsumerWidget {
  static String get routeName => 'profileUpdate';

  const UserProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const DefaultAppBar(
        title: '내 정보 수정',
        backgroundColor: MITIColor.gray800,
        hasBorder: false,
      ),
      backgroundColor: MITIColor.gray750,
      body: Column(
        children: <Widget>[
          const _UserInfoComponent(),
          const _PasswordResetting(),
          SizedBox(height: 8.h),
          const _AuthComponent(),
        ],
      ),
    );
  }
}

class _UserInfoComponent extends ConsumerWidget {
  const _UserInfoComponent({super.key});

  Row getInfo({required String title, required String desc}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MITITextStyle.mdLight.copyWith(
            color: MITIColor.gray300,
          ),
        ),
        Text(
          desc,
          style: MITITextStyle.md.copyWith(
            color: MITIColor.gray100,
          ),
        ),
      ],
    );
  }

  String formatPhoneNumber(String phoneNumber) {
    // 1. 숫자만 남김 (혹시라도 다른 문자가 포함되어 있는 경우)
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    // 2. 전화번호가 11자리인 경우만 형식을 적용 (한국 휴대전화 형식)
    if (cleaned.length == 11) {
      // 첫 번째 3자리, 중간 4자리, 마지막 4자리로 분할
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    }
    // 3. 형식에 맞지 않으면 원래 값을 반환
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return const UserInfoSkeleton();
    }

    final model = (result as ResponseModel<UserModel>).data!;
    String? birthday;
    String? phone;
    if (model.birthday != null) {
      final birth = DateTime.parse(model.birthday!);
      final df = DateFormat('yy.MM.dd');
      birthday = df.format(birth);
    }
    if (model.phone != null) {
      phone = formatPhoneNumber(model.phone!);
    }
    String loginType = model.signup_method == AuthType.email
        ? 'Email'
        : model.signup_method == AuthType.apple
            ? 'Apple ID'
            : 'Kakao ID';

    return Container(
      color: MITIColor.gray800,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          getInfo(title: '이름', desc: model.nickname),
          if (birthday != null) SizedBox(height: 12.h),
          if (birthday != null) getInfo(title: '생년월일', desc: birthday),
          if (phone != null) SizedBox(height: 12.h),
          if (phone != null) getInfo(title: '휴대폰 번호', desc: phone),
          SizedBox(height: 12.h),
          getInfo(title: '로그인 방식', desc: loginType)
        ],
      ),
    );
  }
}

class _PasswordResetting extends ConsumerWidget {
  const _PasswordResetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(userInfoProvider);
    final model = (result as ResponseModel<UserModel>).data!;

    if (model.signup_method != AuthType.email) {
      return Container();
    }
    return Column(
      children: [
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => context.pushNamed(UserProfileFormScreen.routeName),
          child: Container(
            color: MITIColor.gray800,
            padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '비밀번호 재설정',
                    style: MITITextStyle.mdLight.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                ),
                SvgPicture.asset(AssetUtil.getAssetPath(
                    type: AssetType.icon, name: 'chevron_right'))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthComponent extends ConsumerStatefulWidget {
  const _AuthComponent({super.key});

  @override
  ConsumerState<_AuthComponent> createState() => _AuthComponentState();
}

class _AuthComponentState extends ConsumerState<_AuthComponent> {
  late Throttle<int> _throttler;
  int throttleCnt = 0;

  @override
  void initState() {
    super.initState();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) {
      _logout(ref, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MITIColor.gray800,
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return BottomDialog(
                      hasPop: true,
                      title: '로그아웃',
                      content:
                          ' 로그아웃 시, 모집하거나 참여한 경기에\n해당하는 알람을 받을 수 없습니다.\n그래도 로그아웃 하시겠습니까?',
                      btn: TextButton(
                        onPressed: () async {
                          _throttler.setValue(throttleCnt+1);
                        },
                        child: const Text("로그아웃 하기"),
                      ),
                    );
                  });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '로그아웃',
                    style: MITITextStyle.mdLight.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                ),
                SvgPicture.asset(AssetUtil.getAssetPath(
                    type: AssetType.icon, name: 'chevron_right'))
              ],
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => context.pushNamed(UserDeleteScreen.routeName),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '회원탈퇴',
                    style: MITITextStyle.mdLight.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                ),
                SvgPicture.asset(AssetUtil.getAssetPath(
                    type: AssetType.icon, name: 'chevron_right'))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(logoutProvider.future);
    if (context.mounted) {
      if (result is ErrorModel) {
        AuthError.fromModel(model: result)
            .responseError(context, AuthApiType.login, ref);
      } else {
        AppBadgePlus.updateBadge(0);
        context.pop();
      }
    }
  }
}
