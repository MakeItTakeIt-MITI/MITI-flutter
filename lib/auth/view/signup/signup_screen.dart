import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:miti/auth/param/signup_param.dart';
import 'package:miti/auth/provider/signup_provider.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/common/component/custom_bottom_sheet.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/common/provider/widget/form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../common/component/custom_text_form_field.dart';
import '../../../common/component/form/phoen_form.dart';
import '../../../common/model/default_model.dart';
import '../../../common/model/entity_enum.dart';
import '../../../common/provider/form_util_provider.dart';
import '../../../common/provider/router_provider.dart';
import '../../../common/provider/widget/datetime_provider.dart';
import '../../../common/view/operation_term_screen.dart';
import '../../../game/view/game_refund_screen.dart';
import '../../../report/model/agreement_policy_model.dart';
import '../../../report/provider/report_provider.dart';
import '../../../user/model/v2/base_player_profile_response.dart';
import '../../../user/provider/user_form_provider.dart';
import '../../../user/view/user_player_profile_screen.dart';
import '../../../util/util.dart';
import '../../error/auth_error.dart';
import '../../model/signup_model.dart';
import '../../provider/auth_provider.dart';

class SignUpScreen extends ConsumerWidget {
  final SignupMethodType type;

  static String get routeName => 'signUp';

  const SignUpScreen({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressProvider);
    ref.watch(signUpPopProvider);
    ref.watch(signUpFormProvider);
    final appbar = Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return const DefaultAppBar(
          title: '회원가입',
          hasBorder: false,
        );
      },
    );
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return PopScope(
      onPopInvoked: (didPop) {
        log("didPop = $didPop");
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          bottomNavigationBar: _NextButton(type: type),
          // resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
              preferredSize: Size(double.infinity, 44.h), child: appbar),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  progressComponent(),
                  DescComponent(type: type),
                  signUpComponent(ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget progressComponent() {
    return Column(
      children: [
        _ProgressComponent(
          type: type,
        ),
        SizedBox(height: 42.h),
      ],
    );
  } //김정현

  Widget signUpComponent(WidgetRef ref) {
    if (ref.watch(progressProvider).progress == 1) {
      return const NicknameForm();
    } else if (ref.watch(progressProvider).progress == 2) {
      if (type == SignupMethodType.email) {
        return const EmailForm();
      }
      return PersonalInfoForm(type: type);
    } else if (ref.watch(progressProvider).progress == 3) {
      if (type == SignupMethodType.email) {
        return const PasswordForm();
      }
      return const PlayerProfileForm();
    } else if (ref.watch(progressProvider).progress == 4) {
      if (type == SignupMethodType.email) {
        return PersonalInfoForm(type: type);
      }
      return Column(
        children: [SizedBox(height: 20.h), const CheckBoxForm()],
      );
    } else if (ref.watch(progressProvider).progress == 5) {
      return const PlayerProfileForm();
    } else {
      return Column(
        children: [SizedBox(height: 20.h), const CheckBoxForm()],
      );
    }
  }
}

class PlayerProfileForm extends ConsumerWidget {
  const PlayerProfileForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(userPlayerProfileFormProvider, (prev, after) {
      final validNext = after.isAllNull() ? false : after.validForm();

      ref.read(progressProvider.notifier).updateValidNext(validNext: validNext);
      ref.read(signUpFormProvider.notifier).updateForm(playerProfile: after);
    });
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: const PlayerProfileFormComponent(),
    );
  }
}

class _ProgressComponent extends ConsumerWidget {
  final SignupMethodType type;

  const _ProgressComponent({super.key, required this.type});

  Widget progress(int progress, int currentIdx) {
    if (progress < currentIdx) {
      return SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.icon, name: 'circle_check'),
        width: 24.r,
        height: 24.r,
      );
    }

    return Container(
      height: 24.r,
      width: 24.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            progress == currentIdx ? V2MITIColor.primary2 : V2MITIColor.gray9,
      ),
      child: Center(
        child: Text(
          progress.toString(),
          style: progress == currentIdx
              ? V2MITITextStyle.smallBold.copyWith(color: V2MITIColor.gray12)
              : V2MITITextStyle.smallRegular.copyWith(color: V2MITIColor.gray4),
        ),
      ),
    );
  }

  Widget divideChip(int progress, int currentIdx) {
    return Row(
      children: [
        SizedBox(width: 6.w),
        dot(progress, currentIdx),
        SizedBox(width: 4.w),
        dot(progress, currentIdx),
        SizedBox(width: 4.w),
        dot(progress, currentIdx),
        SizedBox(width: 6.w),
      ],
    );
  }

  Widget dot(int progress, int currentIdx) {
    return Container(
      width: 2.r,
      height: 2.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: progress < currentIdx ? V2MITIColor.primary2 : V2MITIColor.gray8,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = SignupMethodType.email == type ? 6 : 4;
    final currentIdx = ref.watch(progressProvider).progress;
    return Row(
      children: [
        ...List.generate(length, (index) {
          return Row(
            children: [
              progress(index + 1, currentIdx),
              if (length != index + 1) divideChip(index + 1, currentIdx),
            ],
          );
        }),
      ],
    );
  }
}

class CheckBoxFormV2 extends ConsumerStatefulWidget {
  final List<CustomCheckBox> checkBoxes;
  final VoidCallback allTap;

  const CheckBoxFormV2({
    super.key,
    required this.checkBoxes,
    required this.allTap,
  });

  @override
  ConsumerState<CheckBoxFormV2> createState() => _CheckBoxFormV2State();
}

class _CheckBoxFormV2State extends ConsumerState<CheckBoxFormV2> {
  @override
  Widget build(BuildContext context) {
    final checked = ref.watch(checkProvider(2));
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.h,
      children: [
        Flexible(
          child: CustomCheckBox(
            title: '약관 전체 동의하기',
            textStyle: V2MITITextStyle.regularMediumNormal
                .copyWith(color: V2MITIColor.white),
            check: checked,
            isCheckBox: true,
            onTap: widget.allTap,
          ),
        ),
        Divider(
          thickness: 1.h,
          color: V2MITIColor.gray10,
          height: 16.h,
        ),
        ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, idx) {
              return widget.checkBoxes[idx];
            },
            separatorBuilder: (_, idx) => SizedBox(height: 10.h),
            itemCount: widget.checkBoxes.length)
      ],
    );
  }
}

class CheckBoxForm extends ConsumerStatefulWidget {
  const CheckBoxForm({super.key});

  @override
  ConsumerState<CheckBoxForm> createState() => _CheckBoxFormState();
}

class _CheckBoxFormState extends ConsumerState<CheckBoxForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onCheck(WidgetRef ref, int idx, List<AgreementPolicyModel> model) {
    final allChecked =
        !ref.read(signUpFormProvider.notifier).onCheck(idx).contains(false);
    ref.read(checkProvider(2).notifier).update((state) => allChecked);

    final checkBoxes = ref.read(signUpFormProvider).checkBoxes;
    bool validNext = true;
    for (int i = 0; i < model.length; i++) {
      if (model[i].is_required && !checkBoxes[i]) {
        validNext = false;
        break;
      }
    }

    ref.read(progressProvider.notifier).updateValidNext(validNext: validNext);
  }

  @override
  Widget build(BuildContext context) {
    final isCheckBoxes =
        ref.watch(signUpFormProvider.select((form) => form.checkBoxes));
    final checkResult =
        ref.watch(agreementPolicyProvider(type: AgreementRequestType.signup));
    if (checkResult is LoadingModel) {
      return Container();
    } else if (checkResult is ErrorModel) {
      return Container();
    }
    final model =
        (checkResult as ResponseListModel<AgreementPolicyModel>).data!;
    final checkBoxes = model.mapIndexed((idx, e) {
      return CustomCheckBox(
          title: '${e.is_required ? '[필수] ' : '[선택] '} ${e.policy.name}',
          textStyle: V2MITITextStyle.smallMediumTight.copyWith(color: V2MITIColor.gray1),
          check: isCheckBoxes[idx],
          hasDetail: e.is_required,
          showDetail: () {
            showDialog(
                barrierColor: V2MITIColor.gray12,
                context: context,
                builder: (context) {
                  return OperationTermScreen(
                    title: model[idx].policy.name,
                    desc: model[idx].policy.content,
                    onPressed: () {
                      if (!isCheckBoxes[idx]) {
                        onCheck(ref, idx, model);
                      }
                      context.pop();
                    },
                  );
                });
          },
          onTap: () {
            onCheck(ref, idx, model);
          });
    }).toList();
    return CheckBoxFormV2(
      checkBoxes: [...checkBoxes],
      allTap: () {
        ref.read(checkProvider(2).notifier).update((state) => !state);
        isCheckBoxes.fillRange(
            0, isCheckBoxes.length, ref.read(checkProvider(2)));
        ref
            .read(signUpFormProvider.notifier)
            .updateForm(checkBoxes: isCheckBoxes.toList());
        ref
            .read(progressProvider.notifier)
            .updateValidNext(validNext: ref.read(checkProvider(2)));
      },
    );
  }
}

class CustomCheckBox extends StatefulWidget {
  final bool check;
  final String title;
  final TextStyle textStyle;
  final bool hasDetail;
  final VoidCallback onTap;
  final VoidCallback? showDetail;
  final bool isCheckBox;

  const CustomCheckBox(
      {super.key,
      required this.title,
      required this.textStyle,
      this.hasDetail = false,
      required this.check,
      required this.onTap,
      this.showDetail,
      this.isCheckBox = false});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    final active = widget.isCheckBox ? "active_checkBox" : "active_check";
    final disable = widget.isCheckBox ? "disabled_checkBox" : "disabled_check";

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        child: Row(
          children: [
            SizedBox(
              height: 24.r,
              width: 24.r,
              child: SvgPicture.asset(
                AssetUtil.getAssetPath(
                  type: AssetType.icon,
                  name: widget.check ? active : disable,
                ),
                width: 24.r,
                height: 24.r,
              ),
            ),
            SizedBox(width: widget.isCheckBox ? 16.w : 8.w),
            Text(
              widget.title,
              style: widget.textStyle,
            ),
            const Spacer(),
            if (widget.hasDetail)
              InkWell(
                onTap: widget.showDetail,
                child: Text(
                  '확인',
                  style: V2MITITextStyle.smallMediumTight.copyWith(
                    color: V2MITIColor.gray6,
                    decoration: TextDecoration.underline,
                    decorationColor: V2MITIColor.gray6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PasswordForm extends ConsumerStatefulWidget {
  const PasswordForm({super.key});

  @override
  ConsumerState<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends ConsumerState<PasswordForm> {
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  late final TextEditingController passwordController;
  late final TextEditingController checkPasswordController;
  InteractionDesc? interactionDescPassword;
  InteractionDesc? interactionDescCheckPassword;

  @override
  void initState() {
    super.initState();
    checkPasswordController = TextEditingController();
    passwordController = TextEditingController();
    for (var focusNode in focusNodes) {
      focusNode.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    checkPasswordController.dispose();
    passwordController.dispose();
    for (var focusNode in focusNodes) {
      focusNode.removeListener(() {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final password =
        ref.watch(signUpFormProvider.select((form) => form.password));
    final checkPassword =
        ref.watch(signUpFormProvider.select((form) => form.checkPassword));

    final pwInfo = ref.watch(formInfoProvider(InputFormType.signUpPassword));
    final pwCheckInfo =
        ref.watch(formInfoProvider(InputFormType.passwordCheck));
    final pwVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.password));
    final pwCheckVisible =
        ref.watch(passwordVisibleProvider(PasswordFormType.passwordCheck));
    return Column(
      children: [
        Container(
          height: 74.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: V2MITIColor.gray11),
          child: Text(
            '비밀번호는 특수문자(!@#\$%^&), 숫자, 영어 대소문자를 반드시 포함해야 합니다.',
            style: V2MITITextStyle.smallRegularNormal.copyWith(
              color: V2MITIColor.gray2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 53.h),
        CustomTextFormField(
          required: true,
          label: '비밀번호',
          hintText: '비밀번호를 입력해주세요.',
          textEditingController: passwordController,
          focusNode: focusNodes[0],
          textInputAction: TextInputAction.next,
          borderColor: pwInfo.borderColor,
          interactionDesc: pwInfo.interactionDesc,
          onNext: () => FocusScope.of(context).requestFocus(focusNodes[1]),
          obscureText: !pwVisible,
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(password: val);
            // samePasswordCheck(context);
            final validPassword = ref
                .read(signUpFormProvider.notifier)
                .validPassword(isPassword: true);

            ref
                .read(formInfoProvider(InputFormType.signUpPassword).notifier)
                .update(
                    borderColor:
                        validPassword ? V2MITIColor.primary5 : V2MITIColor.red5,
                    interactionDesc: InteractionDesc(
                      isSuccess: validPassword,
                      desc:
                          validPassword ? "안전한 비밀번호에요!" : "올바른 비밀번호 양식이 아니에요.",
                    ));
            final hasCheckPassword =
                ref.read(signUpFormProvider).checkPassword!.isNotEmpty;
            if (hasCheckPassword) {
              samePasswordCheck(context);
            }
          },
          suffixIcon: focusNodes[0].hasFocus
              ? GestureDetector(
                  onTap: () {
                    ref
                        .read(passwordVisibleProvider(PasswordFormType.password)
                            .notifier)
                        .update((state) => !state);
                  },
                  child: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                        type: AssetType.icon,
                        name: pwVisible ? 'visible' : 'invisible'),
                    width: 24.r,
                    height: 24.r,
                  ),
                )
              : null,
        ),
        SizedBox(height: 36.h),
        CustomTextFormField(
          required: true,
          label: '비밀번호 확인',
          textEditingController: checkPasswordController,
          textInputAction: TextInputAction.send,
          borderColor: pwCheckInfo.borderColor,
          interactionDesc: pwCheckInfo.interactionDesc,
          obscureText: !pwCheckVisible,
          onChanged: (val) {
            ref
                .read(signUpFormProvider.notifier)
                .updateForm(checkPassword: val);
            samePasswordCheck(context);
          },
          onNext: () => FocusScope.of(context).requestFocus(FocusNode()),
          hintText: '비밀번호를 다시 한 번 입력해 주세요.',
          focusNode: focusNodes[1],
          suffixIcon: focusNodes[1].hasFocus
              ? GestureDetector(
                  onTap: () {
                    ref
                        .read(passwordVisibleProvider(
                                PasswordFormType.passwordCheck)
                            .notifier)
                        .update((state) => !state);
                  },
                  child: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                        type: AssetType.icon,
                        name: pwCheckVisible ? 'visible' : 'invisible'),
                    width: 24.r,
                    height: 24.r,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  void samePasswordCheck(BuildContext context) {
    final valid = ref.read(signUpFormProvider.notifier).isSamePassword();
    ref.read(progressProvider.notifier).updateValidNext(validNext: valid);
    ref.read(formInfoProvider(InputFormType.passwordCheck).notifier).update(
        borderColor: valid ? V2MITIColor.primary5 : V2MITIColor.red5,
        interactionDesc: InteractionDesc(
          isSuccess: valid,
          desc: valid ? "비밀번호가 일치해요!" : "비밀번호가 일치하지 않아요.",
        ));

    // interactionDescCheckPassword = InteractionDesc(
    //   isSuccess: valid,
    //   desc: valid ? "안전한 비밀번호에요!" : "비밀번호가 일치하지 않아요.",
    // );
    if (valid) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }
}

class EmailForm extends ConsumerStatefulWidget {
  const EmailForm({super.key});

  @override
  ConsumerState<EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends ConsumerState<EmailForm> {
  late final TextEditingController controller;
  InteractionDesc? interactionDesc;
  late Throttle<int> _throttler;
  int throttleCnt = 0;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _throttler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _throttler.values.listen((int s) {
      onSubmit(context);
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
    });
  }

  @override
  void dispose() {
    _throttler.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(signUpFormProvider.select((form) => form.email));
    final formInfo = ref.watch(formInfoProvider(InputFormType.signUpEmail));

    return Column(
      children: [
        SizedBox(height: 16.h),
        Column(
          spacing: 4.h,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '이메일',
                  style: V2MITITextStyle.smallRegularNormal.copyWith(
                    color: V2MITIColor.white,
                  ),
                ),
                Container(
                  height: 4.r,
                  width: 4.r,
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: V2MITIColor.primary5,
                    ),
                    width: 2.r,
                    height: 2.r,
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextFormField(
                    hintText: '이메일을 입력해주세요.',
                    borderColor: formInfo.borderColor,
                    interactionDesc: formInfo.interactionDesc,
                    onNext: () async {
                      if (ref.read(signUpFormProvider.notifier).validEmail()) {
                        _throttler.setValue(throttleCnt + 1);
                      }
                    },
                    onChanged: (val) {
                      ref
                          .read(formInfoProvider(InputFormType.signUpEmail)
                              .notifier)
                          .reset();
                      ref
                          .read(progressProvider.notifier)
                          .updateValidNext(validNext: false);
                      ref
                          .read(signUpFormProvider.notifier)
                          .updateForm(email: val, showAutoComplete: true);
                    },
                    textEditingController: controller,
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 98.w,
                  height: 44.h,
                  child: TextButton(
                    onPressed: () async {
                      if (ref.read(signUpFormProvider.notifier).validEmail()) {
                        _throttler.setValue(throttleCnt + 1);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          ref.watch(signUpFormProvider.notifier).validEmail()
                              ? V2MITIColor.primary5
                              : V2MITIColor.gray7,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    child: Text(
                      '중복확인',
                      style: V2MITITextStyle.regularBold.copyWith(
                        color:
                            ref.watch(signUpFormProvider.notifier).validEmail()
                                ? V2MITIColor.black
                                : V2MITIColor.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final email = ref.read(signUpFormProvider).email;
    final param = EmailCheckParam(email: email!);
    final result = await ref.read(emailCheckProvider(param: param).future);
    if (result is ResponseModel<SignUpCheckModel>) {
      log('code ${result.status_code}');
      if (!result.data!.email.is_duplicated) {
        ref.read(progressProvider.notifier).updateValidNext(validNext: true);
      }
      setState(() {
        final duplicate = result.data!.email.is_duplicated;
        ref
            .read(progressProvider.notifier)
            .updateValidNext(validNext: !duplicate);
        ref.read(formInfoProvider(InputFormType.signUpEmail).notifier).update(
            borderColor: duplicate ? V2MITIColor.red5 : V2MITIColor.primary5,
            interactionDesc: InteractionDesc(
                isSuccess: !duplicate,
                desc: duplicate ? '이미 회원으로 등록된 이메일이에요.' : '사용 가능한 이메일이에요!'));
      });
    }
  }
}

class DescComponent extends ConsumerWidget {
  final SignupMethodType type;

  const DescComponent({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title = '';
    String desc = '';
    if (ref.watch(progressProvider).progress == 1) {
      title = '닉네임을 입력해주세요.';
      desc = '닉네임은 MITI 프로필로\n다른 유저들에게 보여지는 이름이에요.';
    } else if (ref.watch(progressProvider).progress == 2) {
      if (type == SignupMethodType.email) {
        title = '이메일을 입력해주세요.';
        desc = '이메일은 사용자의 아이디로 사용됩니다.\n입력하신 이메일로 MITI의 공지사항이 전달돼요.';
      } else {
        title = '본인확인을 위한\n정보를 입력해주세요.';
        desc = '입력하신 정보는 안전하게 보관되면 공개되지 않아요.';
      }
    } else if (ref.watch(progressProvider).progress == 3) {
      if (type == SignupMethodType.email) {
        title = '비밀번호를 입력해주세요.';
      } else {
        title = '선수 프로필을 입력해주세요.';
        desc = '입력하신 정보는 같은 경기 참가자들에게 공개됩니다.';
      }
    } else if (ref.watch(progressProvider).progress == 4) {
      if (type == SignupMethodType.email) {
        title = '본인확인을 위한\n정보를 입력해주세요.';
        desc = '입력하신 정보는 안전하게 보관되며 공개되지 않아요.';
      } else {
        title = 'MITI 회원 이용약관';
        desc = '서비스 이용에 필요한 약관 및 동의입니다.';
      }
    } else if (ref.watch(progressProvider).progress == 5) {
      title = '선수 프로필을 입력해주세요.';
      desc = '입력하신 정보는 같은 경기 참가자들에게 공개됩니다.';
    } else {
      title = 'MITI 회원 이용약관';
      desc = '서비스 이용에 필요한 약관 및 동의입니다.';
    }

    return Column(
      spacing: 12.h,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: V2MITITextStyle.title3.copyWith(
            color: V2MITIColor.white,
          ),
        ),
        Text(
          desc,
          style: V2MITITextStyle.smallRegularNormal.copyWith(
            color: V2MITIColor.gray2,
          ),
        ),
      ],
    );
  }
}

class NicknameForm extends ConsumerStatefulWidget {
  const NicknameForm({super.key});

  @override
  ConsumerState<NicknameForm> createState() => _NicknameFormState();
}

class _NicknameFormState extends ConsumerState<NicknameForm> {
  // InteractionDesc? interactionDesc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(signUpFormProvider.select((form) => form.nickname));
    return Column(
      children: [
        SizedBox(height: 16.h),
        CustomTextFormField(
          hintText: '닉네임을 입력해주세요.',
          required: true,
          label: '닉네임',
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(nickname: val);
            ref
                .read(progressProvider.notifier)
                .updateValidNext(validNext: ValidRegExp.userNickname(val));
          },
          borderColor: V2MITIColor.gray6,
          onNext: () async {
            if (ref.read(signUpFormProvider.notifier).validNickname()) {
              await onSubmit(context);
            }
          },
        ),
      ],
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}

class PersonalInfoForm extends ConsumerStatefulWidget {
  final SignupMethodType type;

  const PersonalInfoForm({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends ConsumerState<PersonalInfoForm> {
  bool isFirstRequest = true;
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  late final TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  void checkValid(SignupMethodType type) {
    final formNotifier = ref.read(signUpFormProvider.notifier);
    final progressNotifier = ref.read(progressProvider.notifier);

    bool isValid = _validateBySignupMethod(type, formNotifier);
    progressNotifier.updateValidNext(validNext: isValid);

    _printValidationDebugInfo(formNotifier);
  }

  bool _validateBySignupMethod(SignupMethodType type, dynamic formNotifier) {
    final baseValidation =
        formNotifier.validName() && formNotifier.validBirth();

    if (type == SignupMethodType.kakao) {
      return baseValidation;
    }

    return baseValidation && formNotifier.validPhoneNumber();
  }

  void _printValidationDebugInfo(dynamic formNotifier) {
    debugPrint('validName: ${formNotifier.validName()}');
    debugPrint('validBirth: ${formNotifier.validBirth()}');
    debugPrint('validPhoneNumber: ${formNotifier.validPhoneNumber()}');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dateProvider(DateTimeType.start), (previous, next) {
      if (next != null) {
        final formatDate = DateTimeUtil.getDate(dateTime: next);
        ref.read(signUpFormProvider.notifier).updateForm(birthDate: formatDate);
        dateController.text = formatDate;
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 16.h),
        CustomTextFormField(
          label: '이름',
          required: true,
          borderColor: V2MITIColor.gray6,
          hintText: '이름을 입력해주세요',
          textInputAction: TextInputAction.next,
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(name: val);
            checkValid(widget.type);
          },
          onNext: () {
            FocusScope.of(context).requestFocus(focusNodes[1]);
          },
        ),
        SizedBox(height: 36.h),
        _BirthForm(
          type: widget.type,
        ),
        SizedBox(height: 36.h),
        if (widget.type != SignupMethodType.kakao)
          const PhoneForm(
            type: PhoneAuthenticationPurposeType.signup,
            hasLabel: true,
          ),
      ],
    );
  }
}

class _BirthForm extends ConsumerStatefulWidget {
  final SignupMethodType type;

  const _BirthForm({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<_BirthForm> createState() => _BirthFormState();
}

class _BirthFormState extends ConsumerState<_BirthForm> {
  String? year;
  String? month;
  String? day;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '생년월일',
              style: V2MITITextStyle.smallRegularNormal.copyWith(
                color: V2MITIColor.white,
              ),
            ),
            Container(
              height: 4.r,
              width: 4.r,
              alignment: Alignment.center,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: V2MITIColor.primary5,
                ),
                width: 2.r,
                height: 2.r,
              ),
            )
          ],
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: () {
            final maximumDate =
                DateTime.now().subtract(const Duration(days: 1));
            FocusScope.of(context).requestFocus(FocusNode());
            CustomBottomSheet.showWidgetContent(
                context: context,
                content: SizedBox(
                  height: 200.h,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    minimumYear: 1900,
                    initialDateTime: maximumDate,
                    maximumDate: maximumDate,
                    dateOrder: DatePickerDateOrder.ymd,
                    onDateTimeChanged: (DateTime value) {
                      setState(() {
                        birthdayFormat(value);
                        ref
                            .read(signUpFormProvider.notifier)
                            .updateForm(birthDate: "$year / $month / $day");
                        if (ref
                            .read(signUpFormProvider.notifier)
                            .validPersonalInfo(widget.type)) {
                          ref
                              .read(progressProvider.notifier)
                              .updateValidNext(validNext: true);
                        }
                      });
                    },
                  ),
                ),
                onPressed: () {
                  ref
                      .read(signUpFormProvider.notifier)
                      .updateForm(birthDate: "$year / $month / $day");
                  context.pop();
                },
                buttonText: '선택');
          },
          child: Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: V2MITIColor.gray6)),
            child: Row(
              children: [
                Expanded(
                    child: Text(
                  year ?? 'YYYY',
                  textAlign: TextAlign.center,
                  style: V2MITITextStyle.regularMediumNormal.copyWith(
                    color: year == null ? V2MITIColor.gray6 : V2MITIColor.white,
                  ),
                )),
                Text(
                  '/',
                  style: V2MITITextStyle.regularMediumNormal.copyWith(
                    color: V2MITIColor.gray6,
                  ),
                ),
                Expanded(
                    child: Text(
                  month ?? 'MM',
                  textAlign: TextAlign.center,
                  style: V2MITITextStyle.regularMediumNormal.copyWith(
                    color:
                        month == null ? V2MITIColor.gray6 : V2MITIColor.white,
                  ),
                )),
                Text(
                  '/',
                  style: V2MITITextStyle.regularMediumNormal.copyWith(
                    color: V2MITIColor.gray6,
                  ),
                ),
                Expanded(
                    child: Text(
                  day ?? 'DD',
                  textAlign: TextAlign.center,
                  style: V2MITITextStyle.regularMediumNormal.copyWith(
                    color: day == null ? V2MITIColor.gray6 : V2MITIColor.white,
                  ),
                )),
              ],
            ),
          ),
        )
      ],
    );
  }

  void birthdayFormat(DateTime value) {
    year = value.year.toString();
    month = value.month < 10
        ? '0${value.month.toString()}'
        : value.month.toString();
    day = value.day < 10 ? '0${value.day.toString()}' : value.day.toString();
  }
}

class _TextFormFormatter extends TextInputFormatter {
  final String sample;
  final String separator;

  _TextFormFormatter({
    required this.sample,
    required this.separator,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > sample.length) return oldValue;
        if (newValue.text.length < sample.length &&
            sample[newValue.text.length - 1] == separator) {
          return TextEditingValue(
              text:
                  '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
              selection:
                  TextSelection.collapsed(offset: newValue.selection.end + 1));
        }
      }
    }
    return newValue;
  }
}

class _NextButton extends ConsumerStatefulWidget {
  final SignupMethodType type;

  const _NextButton({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends ConsumerState<_NextButton> {
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
      _signUp(context);
      Future.delayed(const Duration(seconds: 1), () {
        throttleCnt++;
      });
    });
  }

  @override
  void dispose() {
    _throttler.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressModel = ref.watch(progressProvider);
    final progress = progressModel.progress;
    final validNext = progressModel.validNext;

    String buttonText = '';
    if (progress == 6 ||
        (progress == 4 && SignupMethodType.email != widget.type)) {
      buttonText = '가입하기';
    } else {
      buttonText = '다음';
    }

    bool isVisible = false;
    if (progress == 3 && SignupMethodType.email != widget.type ||
        progress == 5 && SignupMethodType.email == widget.type) {
      isVisible = true;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: isVisible,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(signUpFormProvider.notifier)
                    .updateForm(playerProfile: BasePlayerProfileResponse());
                ref.read(progressProvider.notifier).nextProgress();
              },
              child: Text(
                '다음에 작성하기',
                style: MITITextStyle.sm.copyWith(
                    color: MITIColor.gray100,
                    decoration: TextDecoration.underline,
                    decorationColor: MITIColor.gray100),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 41.h),
          child: SizedBox(
            height: 44.h,
            child: TextButton(
                onPressed: () async {
                  if (validNext) {
                    if ((progress == 6 ||
                        (progress == 4 &&
                            SignupMethodType.email != widget.type))) {
                      _throttler.setValue(throttleCnt + 1);
                    } else {
                      ref.read(progressProvider.notifier).nextProgress();
                    }
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor:
                        validNext ? V2MITIColor.primary5 : V2MITIColor.gray7),
                child: Text(
                  buttonText,
                  style: V2MITITextStyle.regularBold.copyWith(
                    color: validNext ? V2MITIColor.black : V2MITIColor.white,
                  ),
                )),
          ),
        ),
      ],
    );
  }

  Future<void> _signUp(BuildContext context) async {
    ref.read(progressProvider.notifier).updateValidNext(validNext: false);
    if (SignupMethodType.email != widget.type) {
      final storage = ref.read(secureStorageProvider);
      final userInfoToken = await storage.read(key: "userInfoToken");
      ref
          .read(signUpFormProvider.notifier)
          .updateForm(userinfo_token: userInfoToken);
      await storage.delete(key: "userInfoToken");
    }

    final model = ref.read(signUpFormProvider);
    late SignUpBaseParam param;
    switch (widget.type) {
      case SignupMethodType.email:
        param = SignUpEmailParam.fromForm(model: model);
        break;
      case SignupMethodType.apple:
        param = SignUpAppleParam.fromForm(model: model);
        break;
      case SignupMethodType.kakao:
        param = SignUpKakaoParam.fromForm(model: model);
        break;
      default:
        break;
    }
    final result =
        await ref.read(signUpProvider(type: widget.type, param: param).future);

    if (result is ErrorModel) {
      ref.read(progressProvider.notifier).updateValidNext(validNext: true);
      if (context.mounted) {
        AuthError.fromModel(model: result)
            .responseError(context, AuthApiType.signup, ref);
      }
    } else {
      log('회원가입!');
      if (context.mounted) {
        context.goNamed(SignUpCompleteScreen.routeName);
      }
    }
  }
}

class SignUpCompleteScreen extends StatelessWidget {
  static String get routeName => 'signUpComplete';

  SignUpCompleteScreen({super.key});

  final List<List<String>> appDesc = [
    [
      "경기 생성하고 게스트 모집하기",
      "직접 경기를 생성해서 플레이어를 모집해보세요.\n경기 관리 및 게스트 관리는 MITI 가 할테니 경기만 즐기세요.",
    ],
    [
      "주변 경기 검색하고 경기에 참가하기",
      "지금 주변에서 모집중인 경기를 검색하고, 간편하게 경기에 참여해보세요. 경기 검색부터 결제, 참여까지 클릭으로 간편하게!"
    ],
    [
      "매치 완료 후, 리뷰 남기기",
      "경기 후에는 함께한 플레이어에게 리뷰를 남겨 피드백을 주고 받으세요. 리뷰를 통해 실력을 키울 수 있습니다!"
    ]
  ];

  Widget appDescComponent(int idx) {
    return Column(
      children: [
        Row(
          children: [
            getProgress(idx + 1),
            SizedBox(width: 16.w),
            Text(
              appDesc[idx][0],
              style: MITITextStyle.md.copyWith(
                color: MITIColor.gray100,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.w),
        Text(
          appDesc[idx][1],
          style: MITITextStyle.xxsmLight150.copyWith(
            color: MITIColor.gray300,
          ),
        ),
      ],
    );
  }

  Widget getProgress(int idx) {
    return Container(
      height: 24.r,
      width: 24.r,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: V2MITIColor.primary5,
      ),
      child: Center(
        child: Text(
          idx.toString(),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF262626),
            letterSpacing: -14.sp * 0.02,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 21.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 170.h,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Lottie.asset(
                          'assets/lottie/success.json',
                          width: 200,
                          height: 200,
                          fit: BoxFit.fill,
                          repeat: true,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            SizedBox(height: 52.h),
                            Text(
                              '회원가입 완료!',
                              style: MITITextStyle.xxl140.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              '우리 동네 농구 경기에 참여해보세요',
                              style: MITITextStyle.sm150.copyWith(
                                color: MITIColor.gray300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 52.h),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  "MITI에 가입하신 걸 환영합니다!",
                  style: MITITextStyle.md.copyWith(
                    color: MITIColor.gray100,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "MITI의 다양한 기능을 통해 농구 경기에 참여해보세요.",
                  style: MITITextStyle.sm150.copyWith(
                    color: MITIColor.gray300,
                  ),
                ),
                SizedBox(height: 25.h),
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: MITIColor.gray700,
                  ),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (_, idx) {
                        return appDescComponent(idx);
                      },
                      separatorBuilder: (_, idx) => SizedBox(height: 32.h),
                      itemCount: 3),
                ),
                const Spacer(),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    return TextButton(
                        onPressed: () async {
                          await ref
                              .read(authProvider.notifier)
                              .autoLogin(context: context);
                        },
                        child: const Text("홈으로 가기"));
                  },
                ),
                SizedBox(height: 41.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
