import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/widget/find_info_provider.dart';
import 'package:miti/auth/view/find_info/find_email_screen.dart';
import 'package:miti/auth/view/find_info/find_password_screen.dart';
import 'package:miti/common/provider/widget/form_provider.dart';

import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../common/component/default_appbar.dart';
import '../../../common/component/form/phoen_form.dart';
import '../../../common/model/entity_enum.dart';

import '../../model/find_info_model.dart';
import '../../provider/login_provider.dart' hide PhoneAuthType;

class FindInfoScreen extends ConsumerStatefulWidget {
  static String get routeName => 'findInfo';

  const FindInfoScreen({
    super.key,
  });

  @override
  ConsumerState<FindInfoScreen> createState() => _FindEmailScreenState();
}

class _FindEmailScreenState extends ConsumerState<FindInfoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      vsync: this,
    )..addListener(() {
        removeFocus();
      });
  }

  void removeFocus() {
    ref.read(formInfoProvider(InputFormType.phone).notifier).reset();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void dispose() {
    tabController.removeListener(() {
      removeFocus();
    });
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(
        title: '회원 정보 찾기',
        bottom: TabBar(
          indicatorWeight: 1.w,
          unselectedLabelColor: MITIColor.gray500,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: MITITextStyle.xxsm,
          controller: tabController,
          dividerColor: MITIColor.gray500,
          onTap: (idx) {
            tabController.animateTo(idx);
          },
          tabs: const [
            Tab(child: Text('이메일 찾기')),
            Tab(child: Text('비밀번호 찾기')),
          ],
        ),
      ),
      body: TabBarView(controller: tabController, children: const [
        FindInfoBody(
          type: PhoneAuthType.find_email,
        ),
        FindInfoBody(
          type: PhoneAuthType.password_update,
        ),
      ]),
    );
  }
}

final validCodeProvider =
    StateProvider.family.autoDispose<bool, PhoneAuthType>((ref, type) => false);

class FindInfoBody extends ConsumerStatefulWidget {
  final PhoneAuthType type;

  const FindInfoBody({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<FindInfoBody> createState() => _FindInfoBodyState();
}

class _FindInfoBodyState extends ConsumerState<FindInfoBody> {
  bool isFirstRequest = true;
  String findEmail = '';
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  bool validFindInfo = false;
  late Timer timer;
  int remainTime = 180;
  int currentTime = 0;
  bool showTime = false;

  @override
  void initState() {
    super.initState();
  }

  // String format() {
  //   final time = remainTime - currentTime;
  //   final min = (time ~/ 60) == 0 ? '00' : '0${time ~/ 60}';
  //   final sec = (time % 60) < 10
  //       ? '0${(time % 60).toString()}'
  //       : (time % 60).toString();
  //   return '$min : $sec';
  // }

  // bool validPhone(String phone) {
  //   return RegExp(r"^\d{3}-\d{4}-\d{4}$").hasMatch(phone);
  // }

  @override
  Widget build(BuildContext context) {
    // final interactionDescPhone = widget.type == PhoneAuthType.find_email
    //     ? ref.watch(interactionDescProvider(InteractionType.email))
    //     : ref.watch(interactionDescProvider(InteractionType.password));
    // final phone = ref.watch(phoneNumberProvider(widget.type));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 80.h),
          Text(
            widget.type == PhoneAuthType.find_email ? '이메일 찾기' : '비밀번호 재설정',
            style: MITITextStyle.xxl140.copyWith(color: MITIColor.white),
          ),
          SizedBox(height: 12.h),
          Text(
            '회원가입 시 입력한 휴대폰 번호를 입력해주세요.',
            style: MITITextStyle.sm.copyWith(color: MITIColor.gray300),
          ),
          SizedBox(height: 30.h),
          PhoneForm(
            type: widget.type,
          ),
          const Spacer(),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              VerifyBaseModel? model;

              if (widget.type == PhoneAuthType.find_email) {
                model = ref.watch(findEmailProvider);
              } else {
                model = ref.watch(findPasswordProvider);
              }


              return TextButton(
                onPressed: model != null
                    ? () {


                        if (widget.type == PhoneAuthType.find_email) {
                          model as EmailVerifyModel;
                          if (model.authType != null) {
                            context.pushNamed(
                              OtherAccountScreen.routeName,
                              extra: model.authType,
                            );
                            return;
                          }

                          if (model.purpose == null) {
                            context.goNamed(NotFoundAccountScreen.routeName);
                            return;
                          }
                          Map<String, String> queryParameters = {
                            'email': model.email!,
                          };

                          context.pushNamed(
                            FindEmailScreen.routeName,
                            queryParameters: queryParameters,
                            extra: model.authType,
                          );
                        } else {
                          model as PasswordVerifyModel;
                          if (model.authType != null) {
                            context.pushNamed(
                              OtherAccountScreen.routeName,
                              extra: model.authType,
                            );
                            return;
                          }
                          if (model.purpose == null) {
                            context.goNamed(NotFoundAccountScreen.routeName);
                            return;
                          }

                          Map<String, String> queryParameters = {
                            "password_update_token":
                                model.password_update_token ?? '',
                            "userId": model.id.toString(),
                          };
                          context.pushNamed(ResetPasswordScreen.routeName,
                              queryParameters: queryParameters);
                        }
                      }
                    : () {},
                style: TextButton.styleFrom(
                    backgroundColor:
                        model != null ? MITIColor.primary : MITIColor.gray500),
                child: Text(
                  '확인',
                  style: MITITextStyle.mdBold.copyWith(
                    color: model != null ? MITIColor.gray800 : MITIColor.gray50,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 41.h),
        ],
      ),
    );
  }
}
