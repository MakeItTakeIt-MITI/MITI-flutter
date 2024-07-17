import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/common/provider/widget/form_provider.dart';

import '../../../auth/error/auth_error.dart';
import '../../../auth/model/code_model.dart';
import '../../../auth/provider/widget/find_info_provider.dart';
import '../../../auth/provider/widget/phone_auth_provider.dart';
import '../../../auth/view/find_info/find_info_screen.dart';
import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../model/default_model.dart';
import '../../model/entity_enum.dart';
import '../../provider/form_util_provider.dart';
import '../custom_text_form_field.dart';

class PhoneForm extends ConsumerStatefulWidget {
  final PhoneAuthType type;

  const PhoneForm({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends ConsumerState<PhoneForm> {
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  bool firstSend = true;
  bool canRequest = false;
  Timer? timer;
  int remainTime = 180;
  int currentTime = 0;
  bool showTime = false;
  bool enabled = false;
  String phoneBtnDesc = '인증 요청';
  String codeBtnDesc = '인증하기';
  Color phoneBtnColor = MITIColor.gray500;
  Color phoneBtnTextColor = MITIColor.gray50;
  Color codeBtnColor = MITIColor.gray500;
  Color codeBtnTextColor = MITIColor.gray50;
  Color? borderColor;

  @override
  void dispose() {
    timerReset();
    super.dispose();
  }

  void timerReset() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
  }

  String format() {
    final time = remainTime - currentTime;
    final min = (time ~/ 60) == 0 ? '00' : '0${time ~/ 60}';
    final sec = (time % 60) < 10
        ? '0${(time % 60).toString()}'
        : (time % 60).toString();
    return '$min : $sec';
  }

  bool validPhone(String phone) {
    return RegExp(r"^\d{3}-\d{4}-\d{4}$").hasMatch(phone);
  }

  void requestValidCode(String phone, PhoneAuthType type) async {
    timerReset();
    final result = await ref.read(sendCodeProvider(authType: type).future);
    setState(() {
      enabled = true;
      codeBtnDesc = "인증하기";
      phoneBtnDesc = '요청 완료';
      phoneBtnColor = MITIColor.gray500;
      phoneBtnTextColor = MITIColor.primary;
      codeBtnColor = MITIColor.gray500;
      codeBtnTextColor = MITIColor.gray50;
      borderColor = null;
      canRequest = false;
      ref.read(codeDescProvider(widget.type).notifier).update((state) => null);
      ref.read(formInfoProvider(InputFormType.phone).notifier).reset();
    });

    /// 처음 인증 요청
    if (firstSend) {
      firstSend = false;
    } else {}
    if (result is ErrorModel) {
      if (mounted) {
        FocusScope.of(context).requestFocus(FocusNode());

        if (type == PhoneAuthType.find_email) {
          AuthError.fromModel(model: result)
              .responseError(context, AuthApiType.requestSMSFormFindEmail, ref);
        } else {
          AuthError.fromModel(model: result).responseError(
              context, AuthApiType.requestSMSForResetPassword, ref);
        }
      }
    } else {
      showTime = true;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          currentTime = timer.tick;
          if (timer.tick == 180) {
            timer.cancel();
            showTime = false;
            borderColor = MITIColor.error;
            setReRequest(phone);

            ref.read(formInfoProvider(InputFormType.phone).notifier).update(
                  borderColor: MITIColor.error,
                  interactionDesc: InteractionDesc(
                    isSuccess: false,
                    desc: "인증번호 입력 시간이 초과되었습니다.",
                  ),
                );
          }
        });
      });
      if (mounted) {
        FocusScope.of(context).requestFocus(focusNodes[1]);
      }
    }
  }

  void setReRequest(String phone) {
    if (validPhone(phone)) {
      canRequest = true;
      phoneBtnDesc = '인증 재요청';
      phoneBtnColor = MITIColor.primary;
      phoneBtnTextColor = MITIColor.gray800;
    }
  }

  void sendSMS(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final result =
        await ref.read(verifyPhoneProvider(type: widget.type).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        AuthError.fromModel(model: result).responseError(
            context, AuthApiType.send_code, ref,
            object: widget.type);
      } else {
        ref.read(formInfoProvider(InputFormType.phone).notifier).reset();
        codeBtnDesc = "인증완료";

        codeBtnColor = MITIColor.gray500;
        codeBtnTextColor = MITIColor.primary;
        timerReset();
        if (widget.type == PhoneAuthType.signup) {
          final phoneNumber = ref.read(phoneNumberProvider(widget.type));
          ref
              .read(signUpFormProvider.notifier)
              .updateForm(phoneNumber: phoneNumber);
          if (ref.read(signUpFormProvider.notifier).validPersonalInfo()) {
            ref
                .read(progressProvider.notifier)
                .updateValidNext(validNext: true);
          }
        } else if (widget.type == PhoneAuthType.find_email) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(phoneNumberProvider(widget.type));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                focusNode: focusNodes[0],
                hintText: '휴대폰 번호 입력',
                onChanged: (val) {
                  ref
                      .read(phoneNumberProvider(widget.type).notifier)
                      .update((state) => val);
                  if (validPhone(val)) {
                    phoneBtnTextColor = MITIColor.gray800;
                    phoneBtnColor = MITIColor.primary;
                  } else {
                    phoneBtnColor = MITIColor.gray500;
                    phoneBtnTextColor = MITIColor.gray50;
                  }
                  phoneBtnDesc = '인증 요청';
                  canRequest = false;
                  firstSend = true;
                },
                onNext: () {
                  if (validPhone(phone)) {
                    setState(() {
                      requestValidCode(phone, widget.type);
                    });
                  }
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[PhoneNumberFormatter()],
              ),
            ),
            SizedBox(width: 13.w),
            SizedBox(
              height: 48.h,
              width: 98.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (firstSend || canRequest) && validPhone(phone)
                      ? () {
                          if (validPhone(phone)) {
                            setState(() {
                              requestValidCode(phone, widget.type);
                            });
                          }
                        }
                      : null,
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      backgroundColor: phoneBtnColor),
                  child: Text(
                    phoneBtnDesc,
                    style: MITITextStyle.md.copyWith(
                      color: phoneBtnTextColor,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 12.h),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final phoneAuth = ref.watch(phoneAuthProvider(type: widget.type));
            // final valid = ref.watch(validCodeProvider(widget.type));
            final phoneInfo = ref.watch(formInfoProvider(InputFormType.phone));

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextFormField(
                    enabled: enabled,
                    focusNode: focusNodes[1],
                    hintText: '인증번호 6자리 입력',
                    interactionDesc: phoneInfo.interactionDesc,
                    onChanged: (val) {
                      ref
                          .read(phoneAuthProvider(type: widget.type).notifier)
                          .update(code: val);
                      if (val.length == 6) {
                        codeBtnTextColor = MITIColor.gray800;
                        codeBtnColor = MITIColor.primary;
                      } else {
                        codeBtnTextColor = MITIColor.gray50;
                        codeBtnColor = MITIColor.gray500;
                        codeBtnDesc = "인증하기";
                      }
                    },
                    onNext: () {
                      if (phoneAuth.code.length == 6) {
                        sendSMS(context);
                      }
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    suffixIcon: showTime
                        ? Text(
                            format(),
                            style: MITITextStyle.md.copyWith(
                              color: MITIColor.primary,
                            ),
                          )
                        : null,
                    borderColor: phoneInfo.borderColor,
                  ),
                ),
                SizedBox(width: 13.w),
                SizedBox(
                  height: 48.h,
                  width: 98.w,
                  child: TextButton(
                    onPressed: () async {
                      if (phoneAuth.code.length == 6) {
                        sendSMS(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      backgroundColor: codeBtnColor,
                    ),
                    child: Text(
                      codeBtnDesc,
                      style: MITITextStyle.md.copyWith(
                        color: codeBtnTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
