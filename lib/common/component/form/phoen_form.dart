import 'dart:async';
import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
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
import '../../../dio/response_code.dart';
import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';
import '../../model/default_model.dart';
import '../../model/entity_enum.dart';
import '../../provider/form_util_provider.dart';
import '../custom_text_form_field.dart';

class PhoneForm extends ConsumerStatefulWidget {
  final PhoneAuthenticationPurposeType type;
  final bool hasLabel;

  const PhoneForm({
    super.key,
    required this.type,
    this.hasLabel = false,
  });

  @override
  ConsumerState<PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends ConsumerState<PhoneForm> {
  late Throttle<int> _requestThrottler;
  late Throttle<int> _authThrottler;
  int requestCnt = 0;
  int authCnt = 0;
  late final List<FocusNode> focusNodes = [FocusNode(), FocusNode()];
  bool firstSend = true;
  bool canRequest = false;
  Timer? timer;
  int remainTime = 180;
  int currentTime = 0;
  bool showTime = false;
  bool enabled = false;
  bool onSend = false;
  String phoneBtnDesc = '인증 요청';
  String codeBtnDesc = '인증하기';
  Color phoneBtnColor = MITIColor.gray500;
  Color phoneBtnTextColor = MITIColor.gray50;
  Color codeBtnColor = MITIColor.gray500;
  Color codeBtnTextColor = MITIColor.gray50;
  Color? borderColor;

  @override
  void initState() {
    super.initState();
    _requestThrottler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _authThrottler = Throttle(
      const Duration(seconds: 1),
      initialValue: 0,
      checkEquality: true,
    );
    _requestThrottler.values.listen((int s) async {
      final phone = ref.read(phoneNumberProvider(widget.type));
      await requestValidCode(phone, widget.type);
      requestCnt++;
    });
    _authThrottler.values.listen((int s) async {
      await sendSMS(context);
      authCnt++;
    });
  }

  @override
  void dispose() {
    _requestThrottler.cancel();
    _authThrottler.cancel();
    timerReset();
    super.dispose();
  }

  void timerReset() {
    log("타이머 리셋");
    if (timer != null && timer!.isActive) {
      showTime = false;
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

  Future<void> requestValidCode(String phone, PhoneAuthenticationPurposeType type) async {
    FocusScope.of(context).requestFocus(FocusNode());
    timerReset();
    final result = await ref.read(sendCodeProvider(authType: type).future);
    setState(() {
      enabled = true;
      codeBtnDesc = "인증하기";
      phoneBtnDesc = '요청 완료';
      onSend = true;
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
        AuthError.fromModel(model: result)
            .responseError(context, AuthApiType.requestSMS, ref);
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

  Future<void> sendSMS(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    final result =
        await ref.read(verifyPhoneProvider(type: widget.type).future);
    if (context.mounted) {
      if (result is ErrorModel) {
        AuthError.fromModel(model: result).responseError(
            context, AuthApiType.send_code, ref,
            object: widget.type);
        if (PhoneAuthenticationPurposeType.signup != widget.type) {
          if ((result.status_code == BadRequest &&
                  (result.error_code == 440 || result.error_code == 441)) ||
              (result.status_code == NotFound && result.error_code == 440)) {
            onSend = false;
            ref.read(formInfoProvider(InputFormType.phone).notifier).reset();
            codeBtnDesc = "인증완료";
            codeBtnColor = MITIColor.gray500;
            codeBtnTextColor = MITIColor.primary;
            timerReset();
          }
        }
      } else {
        onSend = false;
        ref.read(formInfoProvider(InputFormType.phone).notifier).reset();
        codeBtnDesc = "인증완료";
        codeBtnColor = MITIColor.gray500;
        codeBtnTextColor = MITIColor.primary;
        timerReset();
        if (widget.type == PhoneAuthenticationPurposeType.signup) {
          final phoneNumber = ref.read(phoneNumberProvider(widget.type));
          ref
              .read(signUpFormProvider.notifier)
              .updateForm(phoneNumber: phoneNumber);
          if (ref
              .read(signUpFormProvider.notifier)
              .validPersonalInfo(SignupMethodType.email)) {
            ref
                .read(progressProvider.notifier)
                .updateValidNext(validNext: true);
          }
        } else if (widget.type == PhoneAuthenticationPurposeType.find_email) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(phoneNumberProvider(widget.type));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.hasLabel)
          Text(
            '휴대폰 번호',
            style: MITITextStyle.sm.copyWith(
              color: MITIColor.gray300,
            ),
          ),
        if (widget.hasLabel) SizedBox(height: 8.h),
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
                      _requestThrottler.setValue(requestCnt + 1);
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
                              _requestThrottler.setValue(requestCnt + 1);
                            });
                          }
                        }
                      : null,
                  style: TextButton.styleFrom(
                      backgroundColor: phoneBtnColor, padding: EdgeInsets.zero),
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
                        _authThrottler.setValue(authCnt + 1);
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
                    onPressed: onSend
                        ? () async {
                            if (phoneAuth.code.length == 6) {
                              _authThrottler.setValue(authCnt + 1);
                            }
                          }
                        : null,
                    style: TextButton.styleFrom(
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
