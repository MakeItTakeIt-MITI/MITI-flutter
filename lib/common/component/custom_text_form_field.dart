import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../auth/view/signup/signup_screen.dart';
import '../../util/provider/date_provider.dart';
import '../../util/util.dart';
import '../provider/widget/datetime_provider.dart';
import 'custom_calendar.dart';
import 'date_picker.dart';

class InteractionDesc {
  final bool isSuccess;
  final String desc;

  InteractionDesc({
    required this.isSuccess,
    required this.desc,
  });
}

class CustomTextFormField extends StatelessWidget {
  final String? initialValue;
  final String label;
  final String hintText;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextEditingController? textEditingController;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onNext;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final InteractionDesc? interactionDesc;
  final bool showAutoComplete;
  final TextAlign textAlign;
  final bool enabled;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.textInputAction,
    required this.label,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.textEditingController,
    this.focusNode,
    this.onChanged,
    this.onNext,
    this.keyboardType,
    this.inputFormatters,
    this.interactionDesc,
    this.showAutoComplete = false,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.sp),
          ),
        if (label.isNotEmpty) SizedBox(height: 8.h),
        TextFormField(
          initialValue: initialValue,
          focusNode: focusNode,
          controller: textEditingController,
          textInputAction: textInputAction,
          obscuringCharacter: '●',
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textAlign: textAlign,
          enabled: enabled,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            constraints: BoxConstraints.loose(Size(double.infinity, 58.h)),
            border: OutlineInputBorder(
              borderRadius: showAutoComplete
                  ? BorderRadius.vertical(top: Radius.circular(8.r))
                  : BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
            fillColor: const Color(0xFFF7F7F7),
            filled: true,
            suffixIcon: suffixIcon,
            suffixIconConstraints:
                BoxConstraints.loose(Size(double.infinity, 36.h)),
            // suffixText: '명',
            // suffixStyle: TextStyle(
            //   color: Color(0xFF444444),
            //   fontSize: 14,
            //   fontFamily: 'Pretendard',
            //   fontWeight: FontWeight.w700,
            //   letterSpacing: -0.25,
            // )
          ),
          validator: validator,
          onChanged: onChanged,
          onEditingComplete: onNext,
        ),
        if (showAutoComplete)
          AutoCompleteComponent(
            controller: textEditingController!,
          ),
        if (interactionDesc != null) SizedBox(height: 8.h),
        if (interactionDesc != null)
          Row(
            children: [
              SizedBox(
                height: 14.r,
                width: 14.r,
                child: SvgPicture.asset(interactionDesc!.isSuccess
                    ? 'assets/images/icon/system_success.svg'
                    : 'assets/images/icon/system_alert.svg'),
              ),
              SizedBox(
                width: 4.w,
              ),
              Text(
                interactionDesc!.desc,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: interactionDesc!.isSuccess
                      ? const Color(0xFF00BA34)
                      : const Color(0xFFE92C2C),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class DateInputForm extends ConsumerStatefulWidget {
  final String? initialValue;
  final String label;
  final String hintText;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextEditingController? textEditingController;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onNext;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final InteractionDesc? interactionDesc;
  final bool showAutoComplete;
  final TextAlign textAlign;
  final bool enabled;
  final DateTimeType dateType;
  final DateTimeType? timeType;

  const DateInputForm({
    super.key,
    required this.hintText,
    this.textInputAction,
    required this.label,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.textEditingController,
    this.focusNode,
    this.onChanged,
    this.onNext,
    this.keyboardType,
    this.inputFormatters,
    this.interactionDesc,
    this.showAutoComplete = false,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.initialValue,
    this.dateType = DateTimeType.start,
    this.timeType,
  });

  @override
  ConsumerState<DateInputForm> createState() => _DateInputFormState();
}

class _DateInputFormState extends ConsumerState<DateInputForm> {
  late final TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    // final now = DateTime.now();
    //
    // final dateFormat = widget.timeType != null
    //     ? DateFormat('yyyy.MM.dd HH:mm')
    //     : DateFormat('yyyy / MM / dd');
    dateController = TextEditingController();//..text = dateFormat.format(now);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref.read(dateProvider(widget.dateType).notifier).update((state) => now);
    // });
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dateProvider(widget.dateType), (previous, next) {
      if (next != null) {
        final compareDate = widget.dateType == DateTimeType.start
            ? ref.read(dateProvider(DateTimeType.end))
            : ref.read(dateProvider(DateTimeType.start));
        final format = DateFormat('yyyy.MM.dd');

        if (format.format(compareDate!) == format.format(next)) {
          final formatDate = format.format(next);
          dateController.text = formatDate;
        } else {
          final formatDate = format.format(next);
          final date = dateController.text.split(' ')[0];
          final time = dateController.text.split(' ')[1];
          dateController.text = '$formatDate $time';
        }
      }
    });
    if (widget.timeType != null) {
      ref.listen(timeProvider(widget.dateType), (previous, next) {
        final formatTime = DateTimeUtil.getTime(dateTime: next);
        final date = dateController.text.split(' ')[0];
        final time = dateController.text.split(' ')[1];
        dateController.text = '$date $formatTime';
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label.isNotEmpty)
          Text(
            widget.label,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.sp),
          ),
        if (widget.label.isNotEmpty) SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.initialValue,
                focusNode: widget.focusNode,
                controller: dateController,
                textInputAction: widget.textInputAction,
                obscuringCharacter: '●',
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textAlign: widget.textAlign,
                enabled: widget.enabled,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                    constraints:
                        BoxConstraints.loose(Size(double.infinity, 58.h)),
                    border: OutlineInputBorder(
                      borderRadius: widget.showAutoComplete
                          ? BorderRadius.vertical(top: Radius.circular(8.r))
                          : BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    fillColor: const Color(0xFFF7F7F7),
                    filled: true,
                    suffixIcon: widget.suffixIcon,
                    suffixIconConstraints:
                        BoxConstraints.loose(Size(double.infinity, 36.h))),
                validator: widget.validator,
                onChanged: widget.onChanged,
                onEditingComplete: widget.onNext,
              ),
            ),
            SizedBox(width: 19.w),
            IconButton(
                constraints: BoxConstraints.tight(Size(58.r, 58.r)),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomCalendar(
                                type: widget.dateType,
                              ),
                              if (widget.timeType != null)
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFE8E8E8),
                                ),
                              if (widget.timeType != null)
                                TimePicker(
                                  type: widget.timeType!,
                                ),
                            ],
                          ),
                        );
                      });
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r))),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFDFEFFE))),
                padding: EdgeInsets.all(16.r),
                icon: const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF4065F6),
                )),
          ],
        ),
        if (widget.showAutoComplete)
          AutoCompleteComponent(
            controller: widget.textEditingController!,
          ),
        if (widget.interactionDesc != null) SizedBox(height: 8.h),
        if (widget.interactionDesc != null)
          Row(
            children: [
              SizedBox(
                height: 14.r,
                width: 14.r,
                child: SvgPicture.asset(widget.interactionDesc!.isSuccess
                    ? 'assets/images/icon/system_success.svg'
                    : 'assets/images/icon/system_alert.svg'),
              ),
              SizedBox(
                width: 4.w,
              ),
              Text(
                widget.interactionDesc!.desc,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: widget.interactionDesc!.isSuccess
                      ? const Color(0xFF00BA34)
                      : const Color(0xFFE92C2C),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class AutoCompleteComponent extends ConsumerStatefulWidget {
  final TextEditingController controller;

  const AutoCompleteComponent({
    super.key,
    required this.controller,
  });

  @override
  ConsumerState<AutoCompleteComponent> createState() =>
      _AutoCompleteComponentState();
}

class _AutoCompleteComponentState extends ConsumerState<AutoCompleteComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> emailSuffixes = [
      'naver.com',
      'gmail.com',
      'hanmail.net',
      'daum.net',
      'nate.com'
    ];
    final showAutoComplete =
        ref.watch(signUpFormProvider.select((form) => form.showAutoComplete));
    final email = ref.watch(signUpFormProvider).email;
    final cnt = '@'.allMatches(email).length;
    if (email.contains('@') && cnt == 1 && showAutoComplete) {
      final prefixEmail = email.substring(0, email.indexOf('@') + 1);
      final suffixEmail = email.substring(
        email.indexOf('@') + 1,
      );
      if (suffixEmail.isNotEmpty) {
        emailSuffixes = emailSuffixes
            .where((suffix) {
              return suffix.startsWith(suffixEmail);
            })
            .map((e) => e)
            .toList();
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r))),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: const Color(0xFFE8E8E8), width: 1.h),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      ref
                          .read(signUpFormProvider.notifier)
                          .updateForm(showAutoComplete: false);
                      widget.controller.text =
                          prefixEmail + emailSuffixes[index];
                      ref.read(signUpFormProvider.notifier).updateForm(
                          email: prefixEmail + emailSuffixes[index]);
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Text(
                      prefixEmail + emailSuffixes[index],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000000),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 14.h);
                },
                itemCount: emailSuffixes.length,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 입력된 텍스트를 정제하여 숫자만 남깁니다.
    final cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // 숫자가 11자리 이상이면 11자리까지만 사용합니다.
    if (cleanText.length > 11) {
      return oldValue;
    }

    // 정제된 텍스트를 가공하여 "-"를 삽입합니다.
    final StringBuffer formattedText = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      if (i == 3 || i == 7) {
        formattedText.write('-');
      }
      formattedText.write(cleanText[i]);
    }

    // 새로운 TextEditingValue를 반환합니다.
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 입력된 텍스트에서 숫자만 추출합니다.
    final cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // 추출한 숫자를 YYYY/MM/DD 형식으로 변환합니다.
    final StringBuffer formattedText = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      if (i == 4 || i == 6) {
        formattedText.write('/');
      }
      formattedText.write(cleanText[i]);
    }

    // 새로운 TextEditingValue를 반환합니다.
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

// class DateInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     final StringBuffer newText = StringBuffer();
//     final RegExp dateRegex =
//     RegExp(r'^(\d{0,4})(\/)?(\d{0,2})?(\/)?(\d{0,2})?$');
//
//     // 입력된 텍스트에서 숫자만 추출합니다.
//     final cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
//
//     // 숫자를 YYYY/MM/DD 형식으로 변환합니다.
//     for (int i = 0; i < cleanText.length; i++) {
//       if (i == 4 || i == 6) {
//         newText.write('/');
//       }
//       newText.write(cleanText[i]);
//     }
//
//     // 새로운 TextEditingValue를 반환합니다.
//     return TextEditingValue(
//       text: newText.toString(),
//       selection: TextSelection.collapsed(offset: newText.length),
//     );
//   }
// }
//
