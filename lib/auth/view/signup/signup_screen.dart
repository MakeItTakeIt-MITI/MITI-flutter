import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/param/signup_param.dart';
import 'package:miti/auth/provider/login_provider.dart';
import 'package:miti/auth/provider/signup_provider.dart';
import 'package:miti/auth/provider/widget/phone_auth_provider.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/auth/view/phone_auth/phone_auth_send_screen.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/text_theme.dart';

import '../../../common/component/custom_text_form_field.dart';
import '../../../common/model/default_model.dart';
import '../../../common/provider/widget/datetime_provider.dart';
import '../../../util/util.dart';
import '../../error/auth_error.dart';
import '../../model/signup_model.dart';

class SignUpScreen extends ConsumerWidget {
  static String get routeName => 'signUp';

  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(phoneAuthProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: const DefaultAppBar(title: '회원가입'),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 24.h),
            const DescComponent(),
            SizedBox(
                height:
                    ref.watch(progressProvider).progress != 5 ? 24.h : 12.h),
            if (ref.watch(progressProvider).progress == 1) const NicknameForm(),
            if (ref.watch(progressProvider).progress == 2) const EmailForm(),
            if (ref.watch(progressProvider).progress == 3) const PasswordForm(),
            if (ref.watch(progressProvider).progress == 4)
              const PersonalInfoForm(),
            if (ref.watch(progressProvider).progress == 5) const CheckBoxForm(),
            const Spacer(),
            const _NextButton(),
          ],
        ),
      ),
    );
  }
}

class CheckBoxForm extends ConsumerStatefulWidget {
  const CheckBoxForm({super.key});

  @override
  ConsumerState<CheckBoxForm> createState() => _CheckBoxFormState();
}

class _CheckBoxFormState extends ConsumerState<CheckBoxForm> {
  late final ScrollController controller;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
  }

  bool check = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkBoxes =
        ref.watch(signUpFormProvider.select((form) => form.checkBoxes));
    final showDetail =
        ref.watch(signUpFormProvider.select((form) => form.showDetail));
    final showDetailIdx = showDetail.indexOf(true);

    final allCheck = checkBoxes.where((e) => e).length == 5;
    final subCheckBoxTextStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25.sp,
      color: const Color(0xFF585757),
    );
    final show = showDetail.where((e) => e).isNotEmpty;
    return Stack(
      children: [
        if (!show)
          Column(
            children: [
              CustomCheckBox(
                title: '약관 전체 동의하기',
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.25.sp,
                  color: const Color(0xFF1C1C1C),
                ),
                check: allCheck,
                onTap: () {
                  List<bool> checkBoxes;
                  if (allCheck) {
                    checkBoxes = [false, false, false, false, false];
                  } else {
                    checkBoxes = [true, true, true, true, true];
                  }
                  ref
                      .read(signUpFormProvider.notifier)
                      .updateForm(checkBoxes: checkBoxes);
                  validCheckBox();
                },
              ),
              Divider(
                thickness: 1.h,
                color: const Color(0xFFE8E8E8),
                height: 6.h,
              ),
              CustomCheckBox(
                title: '[필수] 만 14세 이상입니다.',
                textStyle: subCheckBoxTextStyle,
                check: checkBoxes[0],
                onTap: () {
                  agreeCondition(checkBoxes, 0);
                },
              ),
              CustomCheckBox(
                title: '[필수] MITI 회원 이용 약관',
                textStyle: subCheckBoxTextStyle,
                hasDetail: true,
                check: checkBoxes[1],
                onTap: () {
                  agreeCondition(checkBoxes, 1);
                },
                showDetail: () {
                  showDetails(0);
                },
              ),
              CustomCheckBox(
                title: '[필수] 개인정보 수집 / 이용 동의',
                textStyle: subCheckBoxTextStyle,
                hasDetail: true,
                check: checkBoxes[2],
                onTap: () {
                  agreeCondition(checkBoxes, 2);
                },
                showDetail: () {
                  showDetails(1);
                },
              ),
              CustomCheckBox(
                title: '[필수] MITI 서비스 이용약관',
                textStyle: subCheckBoxTextStyle,
                hasDetail: true,
                check: checkBoxes[3],
                onTap: () {
                  agreeCondition(checkBoxes, 3);
                },
                showDetail: () {
                  showDetails(2);
                },
              ),
              CustomCheckBox(
                title: '[선택] 마케팅 목적 개인정보 수집 및\n허용 동의',
                textStyle: subCheckBoxTextStyle,
                hasDetail: true,
                check: checkBoxes[4],
                onTap: () {
                  agreeCondition(checkBoxes, 4);
                },
                showDetail: () {
                  showDetails(3);
                },
              ),
            ],
          ),
        if (show)
          Scrollbar(
            controller: controller,
            child: SizedBox(
              height: 540.h,
              child: SingleChildScrollView(
                controller: controller,
                child: Text(
                  ref.watch(signUpFormProvider).detailDesc[showDetailIdx],
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF1C1C1C),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  void agreeCondition(List<bool> checkBoxes, index) {
    setState(() {
      checkBoxes[index] = !checkBoxes[index];
      ref.read(signUpFormProvider.notifier).updateForm(checkBoxes: checkBoxes);
    });
    validCheckBox();
  }

  void showDetails(int idx) {
    setState(() {
      ref.read(signUpFormProvider.notifier).showDetail(idx: idx);
      ref.read(progressProvider.notifier).updateValidNext(validNext: true);
    });
  }

  void validCheckBox() {
    if (ref.read(signUpFormProvider.notifier).validCheckBox()) {
      ref.read(progressProvider.notifier).updateValidNext(validNext: true);
    } else {
      ref.read(progressProvider.notifier).updateValidNext(validNext: false);
    }
  }
}

class CustomCheckBox extends StatefulWidget {
  final bool check;
  final String title;
  final TextStyle textStyle;
  final bool hasDetail;
  final VoidCallback onTap;
  final VoidCallback? showDetail;

  const CustomCheckBox(
      {super.key,
      required this.title,
      required this.textStyle,
      this.hasDetail = false,
      required this.check,
      required this.onTap,
      this.showDetail});

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: SizedBox(
        height: 48.h,
        child: Row(
          children: [
            SizedBox(
              height: 24.r,
              width: 24.r,
              child: Icon(
                Icons.check_box,
                color: Color(widget.check ? 0xFF4065F6 : 0xFFE8E8E8),
              ),
            ),
            SizedBox(width: 8.w),
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
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF585757),
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
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
    return Column(
      children: [
        Container(
          height: 66.h,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: const Color(0xFFF7F7F7)),
          alignment: Alignment.center,
          child: Text(
            '비밀번호는 특수문자(!@#\$%^&), 숫자, 영어 대소문자를\n반드시 포함해야 합니다.',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF040000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 55.h),
        CustomTextFormField(
          hintText: '비밀번호를 입력해주세요.',
          label: '',
          textEditingController: passwordController,
          focusNode: focusNodes[0],
          textInputAction: TextInputAction.next,
          onNext: () => FocusScope.of(context).requestFocus(focusNodes[1]),
          interactionDesc: interactionDescPassword,
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(password: val);
            samePasswordCheck(context);
            final validPassword = ref
                .read(signUpFormProvider.notifier)
                .validPassword(isPassword: true);

            interactionDescPassword = InteractionDesc(
              isSuccess: validPassword,
              desc: validPassword ? "안전한 비밀번호에요!" : "올바른 비밀번호 양식이 아니에요.",
            );
          },
          suffixIcon: focusNodes[0].hasFocus
              ? IconButton(
                  onPressed: () {
                    passwordController.clear();
                    ref
                        .read(signUpFormProvider.notifier)
                        .updateForm(password: '');
                  },
                  icon: SvgPicture.asset(
                    'assets/images/btn/close_btn.svg',
                  ),
                )
              : null,
        ),
        SizedBox(height: 28.h),
        CustomTextFormField(
          textEditingController: checkPasswordController,
          textInputAction: TextInputAction.send,
          interactionDesc: interactionDescCheckPassword,
          onChanged: (val) {
            ref
                .read(signUpFormProvider.notifier)
                .updateForm(checkPassword: val);
            samePasswordCheck(context);
          },
          onNext: () => FocusScope.of(context).requestFocus(FocusNode()),
          hintText: '비밀번호를 한번 더 입력해주세요.',
          label: '',
          focusNode: focusNodes[1],
          suffixIcon: focusNodes[1].hasFocus
              ? IconButton(
                  onPressed: () {
                    checkPasswordController.clear();
                    ref
                        .read(signUpFormProvider.notifier)
                        .updateForm(checkPassword: '');
                  },
                  icon: SvgPicture.asset(
                    'assets/images/btn/close_btn.svg',
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

    interactionDescCheckPassword = InteractionDesc(
      isSuccess: valid,
      desc: valid ? "안전한 비밀번호에요!" : "비밀번호가 일치하지 않아요.",
    );
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

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(signUpFormProvider.select((form) => form.email));
    return CustomTextFormField(
      hintText: '이메일을 입력해주세요.',
      label: '',
      onNext: () async {
        if (ref.read(signUpFormProvider.notifier).validEmail()) {
          await onSubmit(context);
        }
      },
      onChanged: (val) {
        ref
            .read(signUpFormProvider.notifier)
            .updateForm(email: val, showAutoComplete: true);
      },
      interactionDesc: interactionDesc,
      textEditingController: controller,
      showAutoComplete: true,
      suffixIcon: Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: SizedBox(
          width: 81.w,
          height: 36.h,
          child: TextButton(
            onPressed: () async {
              if (ref.read(signUpFormProvider.notifier).validEmail()) {
                onSubmit(context);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor:
                  ref.watch(signUpFormProvider.notifier).validEmail()
                      ? const Color(0xFF4065F6)
                      : const Color(0xFFE8E8E8),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
            child: Text(
              '중복확인',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
                color: ref.watch(signUpFormProvider.notifier).validEmail()
                    ? Colors.white
                    : const Color(0xFF969696),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final email = ref.read(signUpFormProvider).email;
    final param = EmailCheckParam(email: email);
    final result = await ref.read(signUpCheckProvider(param: param).future);
    if (result is ResponseModel<SignUpCheckModel>) {
      log('code ${result.status_code}');
      if (!result.data!.email!.is_duplicated) {
        ref.read(progressProvider.notifier).updateValidNext(validNext: true);
      }
      setState(() {
        final duplicate = result.data!.email!.is_duplicated;
        interactionDesc = InteractionDesc(
            isSuccess: !duplicate,
            desc: duplicate ? '해당 이메일은 이미 회원으로 등록된 이메일입니다.' : '사용 가능한 이메일이에요!');
      });
    }
  }
}

class DescComponent extends ConsumerWidget {
  const DescComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title = '';
    String desc = '';
    if (ref.watch(progressProvider).progress == 1) {
      // title = 'MITI 회원 이용약관';
      // desc = '약관에 동의하시면 회원가입이 완료됩니다.';
      title = '닉네임을 입력해주세요.';
      desc = '입력하신 닉네임은 MITI 프로필에서 표시되는 이름이에요.\n개인정보 보호를 위해 되도록 실명은 삼가해주세요.';
    } else if (ref.watch(progressProvider).progress == 2) {
      title = '이메일을 입력해주세요.';
      desc = '입력하신 이메일이 MITI의 아이디로 사용됩니다.';
    } else if (ref.watch(progressProvider).progress == 3) {
      title = '비밀번호를 입력해주세요.';
    } else if (ref.watch(progressProvider).progress == 4) {
      title = '본인확인을 위한\n정보를 입력해주세요.';
      desc = '입력하신 정보는 안전하게 보관되며 공개되지 않아요.';
    } else {
      title = 'MITI 회원 이용약관';
      desc = '약관에 동의하시면 회원가입이 완료됩니다.';
    }

    final showDetail =
        ref.watch(signUpFormProvider.select((value) => value.showDetail));
    final show = showDetail.where((e) => e).isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            color: Colors.black,
          ),
        ),
        if (desc.isNotEmpty && show) SizedBox(height: 8.h),
        if (desc.isNotEmpty && show)
          Text(
            desc,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: const Color(0xFF1C1C1C)),
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
  InteractionDesc? interactionDesc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(signUpFormProvider.select((form) => form.nickname));
    return Column(
      children: [
        CustomTextFormField(
          hintText: '닉네임을 입력해주세요',
          label: '',
          interactionDesc: interactionDesc,
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(nickname: val);
          },
          onNext: () async {
            if (ref.read(signUpFormProvider.notifier).validNickname()) {
              await onSubmit(context);
            }
          },
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: SizedBox(
              width: 81.w,
              height: 36.h,
              child: TextButton(
                onPressed: () async {
                  if (ref.read(signUpFormProvider.notifier).validNickname()) {
                    await onSubmit(context);
                  }
                },
                style: TextButton.styleFrom(
                    backgroundColor:
                        ref.watch(signUpFormProvider.notifier).validNickname()
                            ? const Color(0xFF4065F6)
                            : const Color(0xFFE8E8E8),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center),
                child: Text(
                  '중복확인',
                  style: MITITextStyle.btnRStyle.copyWith(
                    color:
                        ref.watch(signUpFormProvider.notifier).validNickname()
                            ? Colors.white
                            : const Color(0xFF969696),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> onSubmit(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final nickname = ref.read(signUpFormProvider).nickname;
    final param = NicknameCheckParam(nickname: nickname);
    final result = await ref.read(signUpCheckProvider(param: param).future);
    if (result is ResponseModel<SignUpCheckModel>) {
      if (!result.data!.nickname!.is_duplicated) {
        ref.read(progressProvider.notifier).updateValidNext(validNext: true);
      }
      setState(() {
        final duplicate = result.data!.nickname!.is_duplicated;
        interactionDesc = InteractionDesc(
            isSuccess: !duplicate,
            desc: duplicate ? '다른 회원님이 사용하고 계시는 닉네임이에요.' : '멋진 닉네임이에요!');
      });
    }
  }
}

class PersonalInfoForm extends ConsumerStatefulWidget {
  const PersonalInfoForm({super.key});

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

  void checkValid() {
    log('ref.read(signUpFormProvider.notifier).validName() ${ref.read(signUpFormProvider.notifier).validName()}');
    log('ref.read(signUpFormProvider.notifier).validBirth() ${ref.read(signUpFormProvider.notifier).validBirth()}');
    log('ref.read(signUpFormProvider.notifier).validPhoneNumber() ${ref.read(signUpFormProvider.notifier).validPhoneNumber()}');
    if (ref.read(signUpFormProvider.notifier).validName() &&
        ref.read(signUpFormProvider.notifier).validBirth() &&
        ref.read(signUpFormProvider.notifier).validPhoneNumber()) {
      ref.read(progressProvider.notifier).updateValidNext(validNext: true);
    } else {
      ref.read(progressProvider.notifier).updateValidNext(validNext: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(signUpFormProvider);
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
        CustomTextFormField(
          label: '이름',
          hintText: '이름을 입력해주세요.',
          textInputAction: TextInputAction.next,
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(name: val);
            checkValid();
          },
          onNext: () {
            FocusScope.of(context).requestFocus(focusNodes[1]);
          },
        ),
        SizedBox(height: 24.h),
        DateInputForm(
          focusNode: focusNodes[0],
          label: '생년월일',
          enabled: false,
          hintText: 'YYYY / MM / DD',
          textEditingController: dateController,
          // textInputAction: TextInputAction.next,
          // keyboardType: TextInputType.number,
          onNext: () {
            FocusScope.of(context).requestFocus(focusNodes[1]);
          },
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(birthDate: val);
            if (ref.read(signUpFormProvider.notifier).validBirth()) {
              FocusScope.of(context).requestFocus(focusNodes[1]);
            }
            checkValid();
          },
        ),
        SizedBox(height: 24.h),
        CustomTextFormField(
          focusNode: focusNodes[1],
          label: '휴대폰 번호',
          hintText: '휴대폰 번호를 입력해주세요.',
          onChanged: (val) {
            ref.read(signUpFormProvider.notifier).updateForm(phoneNumber: val);
            if (ref.read(signUpFormProvider.notifier).validPhoneNumber()) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
            checkValid();
          },
          onNext: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[PhoneNumberFormatter()],
        ),
      ],
    );
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
  const _NextButton({super.key});

  @override
  ConsumerState<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends ConsumerState<_NextButton> {
  @override
  Widget build(BuildContext context) {
    ref.watch(phoneAuthProvider);
    ref.watch(signUpFormProvider.select((value) => value.showDetail));

    final progressModel = ref.watch(progressProvider);
    final progress = progressModel.progress;
    final validNext = progressModel.validNext;
    double progressWidth = (MediaQuery.of(context).size.width - 32.w) / 6;
    // log('valueNext = $validNext');
    final showDetail =
        ref.watch(signUpFormProvider.select((value) => value.showDetail));
    final show = showDetail.where((e) => e).isNotEmpty;
    String buttonText = '';
    if (progress == 5) {
      buttonText = '동의하고 가입하기';
      if (show) {
        buttonText = '이용약관에 동의합니다.';
      }
    } else {
      buttonText = '다음으로';
    }

    return Column(
      children: [
        if (!show)
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              color: const Color(0xFFE8E8E8),
            ),
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              width: progressWidth * progress,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.r),
                color: const Color(0xFF4065F6),
              ),
              duration: const Duration(milliseconds: 500),
            ),
          ),
        if (!show) SizedBox(height: 16.h),
        SizedBox(
          height: 48.h,
          child: TextButton(
              onPressed: () async {
                if (validNext) {
                  if (!show && progress == 5) {
                    final model = ref.read(signUpFormProvider);
                    final param = SignUpParam.fromForm(model: model);
                    final result =
                        await ref.read(signUpProvider(param: param).future);
                    if (result is ErrorModel) {
                      log('error');
                      if (context.mounted) {
                        AuthError.fromModel(model: result)
                            .responseError(context, AuthApiType.signup, ref);
                      }
                    } else {
                      ref.read(requestSMSProvider(type: PhoneAuthType.signup)
                          .future);
                      log('회원가입!');
                      if (context.mounted) {
                        context.goNamed(PhoneAuthSendScreen.routeName);
                      }
                    }
                  } else if (show) {
                    ref.read(progressProvider.notifier).hideDetail();
                  } else {
                    ref.read(progressProvider.notifier).nextProgress();
                  }
                }
              },
              style: TextButton.styleFrom(
                  backgroundColor: validNext
                      ? const Color(0xFF4065F6)
                      : const Color(0xFFE8E8E8)),
              child: Text(
                buttonText,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: validNext ? Colors.white : const Color(0xFF969696)),
              )),
        ),
        SizedBox(height: 48.h),
      ],
    );
  }
}
