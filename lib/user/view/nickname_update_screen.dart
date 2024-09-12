import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/account/error/account_error.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/util/util.dart';

class NicknameUpdateScreen extends StatelessWidget {
  static String get routeName => 'nicknameUpdate';

  const NicknameUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: MITIColor.gray750,
        appBar: const DefaultAppBar(
          backgroundColor: MITIColor.gray750,
          hasBorder: false,
          title: '프로필 수정',
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Column(
            children: [
              SizedBox(height: 88.h),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  return CustomTextFormField(
                    hintText: '닉네임을 입력해 주세요.',
                    label: '닉네임',
                    onChanged: (v) {
                      ref
                          .read(userNicknameFormProvider.notifier)
                          .update(nickname: v);
                    },
                  );
                },
              ),
              const Spacer(),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final nickname = ref.watch(userNicknameFormProvider).nickname;
                  final valid = ValidRegExp.userNickname(nickname);
                  return TextButton(
                      onPressed: valid
                          ? () async {
                              final result =
                                  await ref.read(updateNicknameProvider.future);
                              if (result is ErrorModel) {
                              } else {
                                context.pop();
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  FlashUtil.showFlash(context, '프로필이 수정되었습니다.');
                                });
                              }
                            }
                          : () {},
                      style: TextButton.styleFrom(
                        backgroundColor:
                            valid ? MITIColor.primary : MITIColor.gray500,
                      ),
                      child: Text(
                        '저장하기',
                        style: MITITextStyle.mdBold.copyWith(
                          color: valid ? MITIColor.gray800 : MITIColor.gray50,
                        ),
                      ));
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
