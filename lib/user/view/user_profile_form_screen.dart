import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/auth/provider/update_token_provider.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/defalut_flashbar.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/error/user_error.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/util/util.dart';

import '../../auth/error/auth_error.dart';
import '../../common/component/default_appbar.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/provider/form_util_provider.dart';
import '../../common/provider/widget/form_provider.dart';
import '../../game/model/v2/auth/password_update_request_response.dart';
import '../param/user_profile_param.dart';

class UserProfileFormScreen extends ConsumerStatefulWidget {
  static String get routeName => 'userProfile';

  const UserProfileFormScreen({
    super.key,
  });

  @override
  ConsumerState<UserProfileFormScreen> createState() =>
      _UserProfileFormScreenState();
}

class _UserProfileFormScreenState extends ConsumerState<UserProfileFormScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = ref
        .watch(userPasswordFormProvider.select((u) => u.password_update_token));
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: NestedScrollView(
          physics: const NeverScrollableScrollPhysics(),
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              const DefaultAppBar(
                title: '비밀번호 재설정',
                isSliver: true,
                hasBorder: false,
              )
            ];
          },
          body: valid != null && valid.isNotEmpty
              ? const _NewPasswordForm()
              : const _PasswordForm(),
        ),
      ),
    );
  }
}

class _PasswordForm extends ConsumerStatefulWidget {
  const _PasswordForm({super.key});

  @override
  ConsumerState<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends ConsumerState<_PasswordForm> {
  String password = '';
  late Throttle<int> _throttler;
  int throttleCnt = 0;
  final formKeys = [GlobalKey()];
  bool isLoading = false;

  late final List<FocusNode> focusNodes = [
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) {
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
      getUpdateToken();
    });
    for (int i = 0; i < 1; i++) {
      focusNodes[i].addListener(() {
        // focusScrollable(i);
      });
    }
  }

  @override
  void dispose() {
    _throttler.cancel();
    for (int i = 0; i < 1; i++) {
      focusNodes[i].removeListener(() {
        // focusScrollable(i);
      });
    }
    super.dispose();
  }

  void focusScrollable(int i) {
    Scrollable.ensureVisible(
      formKeys[i].currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final valid = ref.watch(userPasswordFormProvider.notifier).validForm();
    final valid = ValidRegExp.userPassword(password);
    final passwordVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.password));
    final interaction = ref.watch(formInfoProvider(InputFormType.updateToken));
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 21.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '현재 비밀번호를 입력해주세요.',
                style: MITITextStyle.xl.copyWith(color: Colors.white),
              ),
              SizedBox(height: 24.h),
              CustomTextFormField(
                key: formKeys[0],
                hintText: '비밀번호를 입력해주세요.',
                obscureText: !passwordVisible,
                textInputAction: TextInputAction.done,
                interactionDesc: interaction.interactionDesc,
                borderColor: interaction.borderColor,
                focusNode: focusNodes[0],
                onNext: () async {
                  _throttler.setValue(throttleCnt + 1);
                },
                onTap: () {
                  FocusScope.of(context).requestFocus(focusNodes[0]);
                },
                suffixIcon: focusNodes[0].hasFocus
                    ? GestureDetector(
                        onTap: () {
                          ref
                              .read(passwordVisibleProvider(
                                      PasswordFormType.password)
                                  .notifier)
                              .update((state) => !state);
                        },
                        child: Icon(
                          passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: MITIColor.gray500,
                        ),
                      )
                    : null,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
          child: TextButton(
              onPressed: valid && !isLoading
                  ? () async {
                      _throttler.setValue(throttleCnt + 1);
                    }
                  : () {},
              style: TextButton.styleFrom(
                backgroundColor:
                    valid && !isLoading ? MITIColor.primary : MITIColor.gray500,
              ),
              child: Text(
                '입력 완료',
                style: MITITextStyle.mdBold.copyWith(
                  color: valid && !isLoading
                      ? MITIColor.gray800
                      : MITIColor.gray50,
                ),
              )),
        ),
      ],
    );
  }

  Future<void> getUpdateToken() async {
    setState(() {
      isLoading = true;
    });
    final result =
        await ref.read(updateTokenProvider(password: password).future);
    if (result is ErrorModel) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        AuthError.fromModel(model: result)
            .responseError(context, AuthApiType.tokenForPassword, ref);
      }
    } else {
      final model = (result as ResponseModel<PasswordUpdateRequestResponse>).data!;
      ref
          .read(userPasswordFormProvider.notifier)
          .update(password_update_token: model.passwordUpdateToken);
    }
  }
}

class _NewPasswordForm extends ConsumerStatefulWidget {
  const _NewPasswordForm({super.key});

  @override
  ConsumerState<_NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends ConsumerState<_NewPasswordForm> {
  final formKeys = [GlobalKey(), GlobalKey()];
  late Throttle<int> _throttler;
  int throttleCnt = 0;
  bool isLoading = false;

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
  ];

  @override
  void initState() {
    super.initState();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) async {
      setState(() {
        isLoading = true;
      });
       Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
      await updatePassword(context);
      setState(() {
        isLoading = false;
      });
    });
    for (int i = 0; i < 2; i++) {
      focusNodes[i].addListener(() {
        // focusScrollable(i);
      });
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < 2; i++) {
      focusNodes[i].removeListener(() {
        focusScrollable(i);
      });
    }
    super.dispose();
  }

  void focusScrollable(int i) {
    Scrollable.ensureVisible(
      formKeys[i].currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final result = ref.watch(userInfoProvider);
    if (result is LoadingModel) {
      return CircularProgressIndicator();
    } else if (result is ErrorModel) {
      WidgetsBinding.instance.addPostFrameCallback((s) =>
          UserError.fromModel(model: result)
              .responseError(context, UserApiType.get, ref));
      return Text('에러');
    }
    final passwordForm = ref.watch(userPasswordFormProvider);
    final pwInteraction = ref.watch(formInfoProvider(InputFormType.password));
    final checkPwInteraction =
        ref.watch(formInfoProvider(InputFormType.passwordCheck));

    // final newPasswordInteraction =
    //     ref.watch(interactionDescProvider(InteractionType.newPassword));
    // final newPasswordCheckInteraction =
    //     ref.watch(interactionDescProvider(InteractionType.newPasswordCheck));
    final newPasswordVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.newPassword));
    final newPasswordCheckVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.newPasswordCheck));

    final valid = ref.watch(userPasswordFormProvider.notifier).getValid();
    return Padding(
      padding: EdgeInsets.only(
          left: 21.w, right: 21.w, top: 20.h, bottom: 20.h + bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '변경할 비밀번호를 입력해 주세요.',
            style: MITITextStyle.xl.copyWith(color: Colors.white),
          ),
          SizedBox(height: 20.h),
          Container(
            height: 74.h,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: MITIColor.gray700),
            child: Text(
              '비밀번호는 특수문자(!@#\$%^&), 숫자, 영어 대소문자를 반드시 포함해야 합니다.',
              style: MITITextStyle.sm150.copyWith(
                color: MITIColor.gray100,
              ),
            ),
          ),
          SizedBox(height: 40.h),
          CustomTextFormField(
            key: formKeys[0],
            hintText: '비밀번호를 입력해 주세요.',
            obscureText: !newPasswordVisible,
            textInputAction: TextInputAction.next,
            interactionDesc: pwInteraction.interactionDesc,
            borderColor: pwInteraction.borderColor,
            focusNode: focusNodes[0],
            onNext: () {
              setState(() {
                FocusScope.of(context).requestFocus(focusNodes[1]);
              });
            },
            suffixIcon: focusNodes[0].hasFocus
                ? GestureDetector(
                    onTap: () {
                      ref
                          .read(passwordVisibleProvider(
                                  PasswordFormType.newPassword)
                              .notifier)
                          .update((state) => !state);
                    },
                    child: Icon(
                      newPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: MITIColor.gray500,
                    ),
                  )
                : null,
            onTap: () {
              setState(() {
                FocusScope.of(context).requestFocus(focusNodes[0]);
              });
            },
            onChanged: (val) {
              ref
                  .read(userPasswordFormProvider.notifier)
                  .update(new_password: val);
              if (ValidRegExp.userPassword(val)) {
                ref
                    .read(formInfoProvider(InputFormType.password).notifier)
                    .update(
                        borderColor: MITIColor.correct,
                        interactionDesc: InteractionDesc(
                            isSuccess: true, desc: '안전한 비밀번호에요!'));
              } else {
                ref
                    .read(formInfoProvider(InputFormType.password).notifier)
                    .update(
                        borderColor: V2MITIColor.red5,
                        interactionDesc: InteractionDesc(
                            isSuccess: false, desc: '올바른 비밀번호 양식이 아니에요.'));
              }
            },
          ),
          SizedBox(height: 12.h),
          CustomTextFormField(
            key: formKeys[1],
            hintText: '비밀번호를 다시 한 번 입력해 주세요.',
            obscureText: !newPasswordCheckVisible,
            textInputAction: TextInputAction.send,
            focusNode: focusNodes[1],
            interactionDesc: checkPwInteraction.interactionDesc,
            borderColor: checkPwInteraction.borderColor,
            suffixIcon: focusNodes[1].hasFocus
                ? GestureDetector(
                    onTap: () {
                      ref
                          .read(passwordVisibleProvider(
                                  PasswordFormType.newPasswordCheck)
                              .notifier)
                          .update((state) => !state);
                    },
                    child: Icon(
                      newPasswordCheckVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: MITIColor.gray500,
                    ),
                  )
                : null,
            onTap: () {
              setState(() {
                FocusScope.of(context).requestFocus(focusNodes[1]);
              });
            },
            onNext: valid && !isLoading
                ? () async {
                    _throttler.setValue(throttleCnt + 1);
                  }
                : () {},
            onChanged: (val) {
              ref
                  .read(userPasswordFormProvider.notifier)
                  .update(new_password_check: val);
              if (ValidRegExp.userPassword(val)) {
                if (passwordForm.new_password_check == val) {
                  ref
                      .read(formInfoProvider(InputFormType.passwordCheck)
                          .notifier)
                      .update(
                          borderColor: MITIColor.correct,
                          interactionDesc: InteractionDesc(
                              isSuccess: true, desc: '비밀번호가 일치해요!'));
                } else {
                  ref
                      .read(formInfoProvider(InputFormType.passwordCheck)
                          .notifier)
                      .update(
                          borderColor: V2MITIColor.red5,
                          interactionDesc: InteractionDesc(
                              isSuccess: false, desc: '비밀번호가 일치하지 않습니다.'));
                }
              } else {
                ref
                    .read(
                        formInfoProvider(InputFormType.passwordCheck).notifier)
                    .update(
                        borderColor: V2MITIColor.red5,
                        interactionDesc: InteractionDesc(
                            isSuccess: false, desc: '올바른 비밀번호 양식이 아니에요.'));
              }
            },
          ),
          const Spacer(),
          TextButton(
              onPressed: valid && !isLoading
                  ? () async {
                      _throttler.setValue(throttleCnt + 1);
                    }
                  : () {},
              style: TextButton.styleFrom(
                backgroundColor:
                    valid && !isLoading ? MITIColor.primary : MITIColor.gray500,
              ),
              child: Text(
                '비밀번호 재설정',
                style: MITITextStyle.mdBold.copyWith(
                  color: valid && !isLoading
                      ? MITIColor.gray800
                      : MITIColor.gray50,
                ),
              )),
        ],
      ),
    );
  }

  Future<void> updatePassword(BuildContext context) async {
    final userId = ref.read(authProvider)!.id!;
    final form = ref.read(userPasswordFormProvider);

    final param = UserPasswordParam(
        new_password_check: form.new_password_check,
        new_password: form.new_password,
        password_update_token: form.password_update_token);
    final result = await ref.read(updatePasswordProvider(userId, param).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        UserError.fromModel(model: result)
            .responseError(context, UserApiType.updatePassword, ref);
      } else {
        // 현재 화면의 `context`가 아닌 이전 화면의 `context`를 사용하여 Flash를 표시
        // pop하기 전에 현재 화면의 `context`를 이전 화면의 `context`로 저장
        // final previousContext = Navigator.of(context).context;

        /*
        copilot 답변
        	1.	**현재 화면의 context**는 네비게이터가 관리하고 있으며, 이 네비게이터는 여러 화면을 스택 구조로 관리합니다.
	        2.	Navigator.of(context)는 네비게이터 객체를 가져오고, 이 네비게이터는 이전 화면의 context도 가지고 있습니다.
	        3.	Navigator.of(context).context로 얻은 context는 pop한 후 **이전 화면의 유효한 context**로 작동하게 됩니다.
         */
        /*
         내 생각
         navigator가 화면의 context를 스택 구조로 가지고 있고 context는 해당 화면들의 context를 참조하고 있다.
         그렇기 때문에 context를 pop하면 스택의 pop처럼 이전 화면의 context를 가리키게된다.
         previous를 만들 필요 없이 context만으로 pop을 하고 delay를 주면 해당 context가 이전 페이지의
         context로 참조되기 때문에 flash를 지울 때 delay가 핵심이다.
         */
        context.pop();
        // pop 후에 이전 화면의 `context`에서 Flash 표시
        Future.delayed(const Duration(milliseconds: 100), () {
          FlashUtil.showFlash(context, '비밀번호가 재설정 되었습니다.');
        });
      }
    }
  }
}
