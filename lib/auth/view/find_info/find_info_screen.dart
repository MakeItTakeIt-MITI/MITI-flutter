import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/widget/find_info_provider.dart';
import 'package:miti/auth/view/find_info/find_email_screen.dart';
import 'package:miti/auth/view/find_info/find_password_screen.dart';
import 'package:miti/auth/view/signup/signup_screen.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';

import '../../../common/component/custom_text_form_field.dart';
import '../../../common/component/default_appbar.dart';
import '../../../common/model/default_model.dart';
import '../../../common/provider/form_util_provider.dart';
import '../../../dio/response_code.dart';
import '../../error/auth_error.dart';
import '../../model/code_model.dart';
import '../../model/find_info_model.dart';
import '../../provider/login_provider.dart';
import '../../provider/widget/phone_auth_provider.dart';

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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: DefaultAppBar(
        title: '회원 정보 찾기',
        bottom: TabBar(
          indicatorColor: const Color(0xFF4065F6),
          unselectedLabelColor: const Color(0xFF969696),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25.sp,
            color: const Color(0xFF4065F6),
          ),
          controller: tabController,
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
          type: FindInfoType.email,
        ),
        FindInfoBody(
          type: FindInfoType.password,
        ),
      ]),
    );
  }
}

final validCodeProvider =
    StateProvider.family.autoDispose<bool, FindInfoType>((ref, type) => false);

class FindInfoBody extends ConsumerStatefulWidget {
  final FindInfoType type;

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
  bool? isOauth;
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  bool validFindInfo = false;

  bool validPhone(String phone) {
    return RegExp(r"^\d{3}-\d{4}-\d{4}$").hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final interactionDescPhone = widget.type == FindInfoType.email
        ? ref.watch(interactionDescProvider(InteractionType.email))
        : ref.watch(interactionDescProvider(InteractionType.password));
    final phone = ref.watch(phoneNumberProvider(widget.type));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 71.h),
          Text(
            widget.type == FindInfoType.email ? '아이디 찾기' : '비밀번호 재설정',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.25.sp,
              color: const Color(0xFF000000),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '회원가입시 입력한 휴대폰 번호를 입력해주세요.',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.25.sp,
              color: const Color(0xFF1C1C1C),
            ),
          ),
          SizedBox(height: 10.h),
          CustomTextFormField(
            focusNode: focusNodes[0],
            label: '',
            hintText: '휴대폰 번호를 입력해주세요.',
            interactionDesc: interactionDescPhone,
            onChanged: (val) {
              ref
                  .read(phoneNumberProvider(widget.type).notifier)
                  .update((state) => val);
              if (!canRequest(val)) {
                isFirstRequest = true;
                ref
                    .read(validCodeProvider(widget.type).notifier)
                    .update((state) => false);
              }
            },
            onNext: () {
              if (canRequest(phone)) {
                requestValidCode(phone, widget.type);
              }
            },
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: SizedBox(
                height: 36.h,
                width: 90.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (canRequest(phone)) {
                        requestValidCode(phone, widget.type);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      backgroundColor: canRequest(phone)
                          ? const Color(0xFF4065F6)
                          : const Color(0xFFE8E8E8),
                    ),
                    child: Text(
                      isFirstRequest ? '인증번호 전송' : '재요청하기',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                          letterSpacing: -0.25.sp,
                          color: canRequest(phone)
                              ? Colors.white
                              : const Color(0xFF969696)),
                    ),
                  ),
                ),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[PhoneNumberFormatter()],
          ),
          SizedBox(height: 10.h),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final phoneAuth = ref.watch(phoneAuthProvider);
              final valid = ref.watch(validCodeProvider(widget.type));
              final interactionDescCode =
                  ref.watch(codeDescProvider(widget.type));
              return CustomTextFormField(
                enabled: validPhone(phone) ? true : false,
                focusNode: focusNodes[1],
                label: '',
                hintText: '인증번호를 입력해주세요.',
                interactionDesc: interactionDescCode,
                onChanged: (val) {
                  ref.read(phoneAuthProvider.notifier).update(code: val);
                  if (val.length == 6) {
                    sendSMS(context);
                  }
                },
                onNext: () {
                  if (phoneAuth.code.length == 6) {
                    sendSMS(context);
                  }
                },
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: SizedBox(
                    height: 36.h,
                    width: 90.w,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (phoneAuth.code.length == 6) {
                            sendSMS(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          backgroundColor: valid
                              ? const Color(0xFF4065F6)
                              : const Color(0xFFE8E8E8),
                        ),
                        child: Text(
                          '인증번호 확인',
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12.sp,
                              letterSpacing: -0.25.sp,
                              color: valid
                                  ? Colors.white
                                  : const Color(0xFF969696)),
                        ),
                      ),
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              );
            },
          ),
          const Spacer(),
          TextButton(
              onPressed: validFindInfo
                  ? () {
                      if (widget.type == FindInfoType.email) {
                        Map<String, String> queryParameters = {
                          'email': findEmail,
                          'isOauth': isOauth.toString()
                        };
                        context.pushNamed(FindEmailScreen.routeName,
                            queryParameters: queryParameters);
                      } else {
                        if (isOauth == null) {
                          showDialog(
                              context: context,
                              builder: (_) {
                                return const CustomDialog(
                                  title: '카카오 로그인 사용자',
                                  content:
                                      '카카오 계정을 사용하여 가입하셨습니다.\n카카오 로그인을 통해 로그인해주세요.',
                                );
                              });
                        } else {
                          context.pushNamed(ResetPasswordScreen.routeName);
                        }
                      }
                    }
                  : () {},
              style: TextButton.styleFrom(
                  backgroundColor: validFindInfo
                      ? const Color(0xFF4065F6)
                      : const Color(0xFFE8E8E8)),
              child: Text(
                widget.type == FindInfoType.email ? '이메일 찾기' : '비밀번호 재설정',
                style: TextStyle(
                  color: validFindInfo ? Colors.white : const Color(0xFF969696),
                  letterSpacing: -0.25.sp,
                ),
              )),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }

  void requestValidCode(String phone, FindInfoType type) async {
    final result = await ref.read(findInfoProvider(type: type).future);
    isFirstRequest = false;
    if (result is ErrorModel) {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());

        if (type == FindInfoType.email) {
          AuthError.fromModel(model: result)
              .responseError(context, AuthApiType.requestSMSFormFindEmail, ref);
        } else {
          AuthError.fromModel(model: result).responseError(
              context, AuthApiType.requestSMSForResetPassword, ref);
        }
      }

      // setState(() {
      //   String desc = '';
      //   switch (result.status_code) {
      //     case NotFound:
      //       context.pushNamed(NotFoundUserInfoScreen.routeName);
      //       desc = '해당 정보와 일치하는 사용자가 존재하지 않습니다.';
      //       break;
      //   }
      //   interactionDescPhone = InteractionDesc(isSuccess: false, desc: desc);
      // });
    } else {
      if (mounted) {
        ref
            .read(validCodeProvider(widget.type).notifier)
            .update((state) => true);
        FocusScope.of(context).requestFocus(focusNodes[1]);
        ref
            .read(codeDescProvider(widget.type).notifier)
            .update((state) => InteractionDesc(
                  isSuccess: true,
                  desc: "인증번호가 발송되었어요!",
                ));
      }
    }
  }

  bool canRequest(String phone) {
    return validPhone(phone);
  }

  void sendSMS(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final result = await ref.read(sendSMSProvider.future);
    if (context.mounted) {
      if (result is ErrorModel) {
        AuthError.fromModel(model: result).responseError(
            context, AuthApiType.send_code, ref,
            object: widget.type);
      } else {
        setState(() {
          ref
              .read(formDescProvider(InputFormType.passwordCode).notifier)
              .update((state) =>
                  InteractionDesc(isSuccess: true, desc: '인증번호가 일치해요.'));
          validFindInfo = true;
          result as ResponseModel<ResponseCodeModel>;
          findEmail = result.data!.email;
          isOauth = result.data!.is_oauth;
        });
      }
    }
  }
}

class NotFoundUserInfoScreen extends StatelessWidget {
  static String get routeName => 'notFoundUser';

  const NotFoundUserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const DefaultAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 226.h),
            Text(
              '유저 정보 없음',
              style: TextStyle(
                fontSize: 25.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.25.sp,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '일치하는 사용자 정보가 존재하지 않습니다.\n회원가입시 입력한 전화번호를 확인해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.25.sp,
                color: const Color(0xFF333333),
              ),
            ),
            const Spacer(),
            TextButton(
                onPressed: () => context.goNamed(SignUpScreen.routeName),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )),
            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }
}
