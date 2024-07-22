import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/provider/widget/sign_up_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../auth/view/signup/signup_screen.dart';
import '../../game/view/game_create_screen.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import '../provider/router_provider.dart';
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
  final String? label;
  final String hintText;
  final TextInputAction? textInputAction;
  final Widget? prefix;
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
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final TextStyle? labelTextStyle;
  final Color? borderColor;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.textInputAction,
    this.label,
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
    this.hintTextStyle,
    this.textStyle,
    this.labelTextStyle,
    this.borderColor,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Text(
            label!,
            style: labelTextStyle ??
                MITITextStyle.sm.copyWith(
                  color: MITIColor.gray300,
                ),
          ),
        if (label != null) SizedBox(height: 8.h),
        SizedBox(
          child: TextFormField(
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
            style: textStyle ??
                MITITextStyle.md.copyWith(
                  color: MITIColor.gray100,
                ),
            decoration: InputDecoration(
              // contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
              // isDense: false,
              // isCollapsed:true,

              constraints: BoxConstraints(maxHeight: 48.h, minHeight: 48.h),
              focusedBorder: OutlineInputBorder(
                borderRadius: showAutoComplete
                    ? BorderRadius.vertical(top: Radius.circular(8.r))
                    : BorderRadius.circular(8.r),
                borderSide: borderColor == null
                    ? BorderSide.none
                    : BorderSide(color: borderColor!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: showAutoComplete
                    ? BorderRadius.vertical(top: Radius.circular(8.r))
                    : BorderRadius.circular(8.r),
                borderSide: borderColor == null
                    ? BorderSide.none
                    : BorderSide(color: borderColor!),
              ),
              border: OutlineInputBorder(
                borderRadius: showAutoComplete
                    ? BorderRadius.vertical(top: Radius.circular(8.r))
                    : BorderRadius.circular(8.r),
                borderSide: borderColor == null
                    ? BorderSide.none
                    : BorderSide(color: borderColor!),
              ),
              hintText: hintText,
              hintStyle: hintTextStyle ??
                  MITITextStyle.md.copyWith(
                    color: MITIColor.gray500,
                  ),
              fillColor: MITIColor.gray700,
              filled: true,
              prefixIcon: prefix == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(left: prefix == null ? 0 : 20.w),
                      child: prefix,
                    ),
              prefixIconConstraints: BoxConstraints.loose(
                Size(double.infinity, 36.h),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: suffixIcon == null ? 0 : 20.w),
                child: suffixIcon,
              ),
              suffixIconConstraints: BoxConstraints.loose(
                Size(double.infinity, 36.h),
              ),
            ),
            validator: validator,
            onChanged: onChanged,
            onEditingComplete: onNext,
          ),
        ),
        // if (showAutoComplete)
        //   AutoCompleteComponent(
        //     controller: textEditingController!,
        //   ),
        if (interactionDesc != null) SizedBox(height: 16.h),
        if (interactionDesc != null)
          Text(
            interactionDesc!.desc,
            style: MITITextStyle.xxsm.copyWith(
              color: interactionDesc!.isSuccess
                  ? MITIColor.correct
                  : MITIColor.error,
            ),
          ),

        // Row(
        //   children: [
        //     SizedBox(
        //       height: 14.r,
        //       width: 14.r,
        //       child: SvgPicture.asset(interactionDesc!.isSuccess
        //           ? 'assets/images/icon/system_success.svg'
        //           : 'assets/images/icon/system_alert.svg'),
        //     ),
        //     SizedBox(
        //       width: 4.w,
        //     ),
        //
        //   ],
        // ),
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
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final TextStyle? labelTextStyle;
  final bool isRangeCalendar;

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
    this.hintTextStyle,
    this.textStyle,
    this.labelTextStyle,
    this.isRangeCalendar = false,
  });

  @override
  ConsumerState<DateInputForm> createState() => _DateInputFormState();
}

class _DateInputFormState extends ConsumerState<DateInputForm> {
  // late final TextEditingController dateController;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label.isNotEmpty)
          Text(
            widget.label,
            style: widget.labelTextStyle ??
                TextStyle(
                  color: const Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  letterSpacing: -0.25.sp,
                ),
          ),
        if (widget.label.isNotEmpty) SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.initialValue,
                focusNode: widget.focusNode,
                controller: widget.textEditingController,
                textInputAction: widget.textInputAction,
                obscuringCharacter: '●',
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textAlign: widget.textAlign,
                enabled: widget.enabled,
                style: widget.textStyle ??
                    TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.25.sp,
                      fontSize: 16.sp,
                    ),
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    constraints:
                        BoxConstraints.loose(Size(double.infinity, 58.h)),
                    border: OutlineInputBorder(
                      borderRadius: widget.showAutoComplete
                          ? BorderRadius.vertical(top: Radius.circular(8.r))
                          : BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    hintText: widget.hintText,
                    hintStyle: widget.hintTextStyle ??
                        TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          letterSpacing: -0.25.sp,
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
                constraints: BoxConstraints.tight(Size(50.r, 50.r)),
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());

                  final extra = Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      width: 480.w,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomCalendar(
                            rangeSelectionMode: widget.isRangeCalendar
                                ? RangeSelectionMode.toggledOn
                                : null,
                          ),
                          if (widget.isRangeCalendar)
                            const Divider(
                              height: 1,
                              color: Color(0xFFE8E8E8),
                            ),
                          if (widget.isRangeCalendar)
                            const TimePicker(
                              type: DateTimeType.start,
                            ),
                          if (widget.isRangeCalendar)
                            const TimePicker(
                              type: DateTimeType.end,
                            ),
                          Container(
                            height: 20.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(8.r)),
                              border: Border.all(color: Colors.white),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  context.pushNamed(DialogPage.routeName, extra: extra);
                  // showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return StatefulBuilder(
                  //         builder: (BuildContext context,
                  //             void Function(void Function()) setState) {
                  //           return Consumer(
                  //             builder: (BuildContext context, WidgetRef ref,
                  //                 Widget? child) {
                  //
                  //
                  //               return Dialog(
                  //                 backgroundColor: Colors.white,
                  //                 shape: RoundedRectangleBorder(
                  //                     borderRadius: BorderRadius.circular(8.r)),
                  //                 child: Column(
                  //                   mainAxisSize: MainAxisSize.min,
                  //                   children: [
                  //                     CustomCalendar(
                  //                       rangeSelectionMode:
                  //                           widget.isRangeCalendar
                  //                               ? RangeSelectionMode.toggledOn
                  //                               : null,
                  //                     ),
                  //                     if (widget.isRangeCalendar)
                  //                       const Divider(
                  //                         height: 1,
                  //                         color: Color(0xFFE8E8E8),
                  //                       ),
                  //                     if (widget.isRangeCalendar)
                  //                       const TimePicker(
                  //                         type: DateTimeType.start,
                  //                       ),
                  //                     if (widget.isRangeCalendar)
                  //                       const TimePicker(
                  //                         type: DateTimeType.end,
                  //                       ),
                  //                     Container(
                  //                       height: 20.h,
                  //                       decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.vertical(
                  //                             bottom: Radius.circular(8.r)),
                  //                         color: Colors.white,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               );
                  //             },
                  //           );
                  //         },
                  //       );
                  //     });
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r))),
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xFFDFEFFE))),
                // padding: EdgeInsets.all(16.r),
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: const Color(0xFF4065F6),
                  size: 16.r,
                )),
          ],
        ),
        // if (widget.showAutoComplete)
        //   AutoCompleteComponent(
        //     controller: widget.textEditingController!,
        //   ),
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
                  letterSpacing: -0.25.sp,
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

// class AutoCompleteComponent extends ConsumerStatefulWidget {
//   final TextEditingController controller;
//
//   const AutoCompleteComponent({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   ConsumerState<AutoCompleteComponent> createState() =>
//       _AutoCompleteComponentState();
// }
//
// class _AutoCompleteComponentState extends ConsumerState<AutoCompleteComponent> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> emailSuffixes = [
//       'naver.com',
//       'gmail.com',
//       'hanmail.net',
//       'daum.net',
//       'nate.com'
//     ];
//     final showAutoComplete =
//         ref.watch(signUpFormProvider.select((form) => form.showAutoComplete));
//     final email = ref.watch(signUpFormProvider).email;
//     final cnt = '@'.allMatches(email).length;
//     if (email.contains('@') && cnt == 1 && showAutoComplete) {
//       final prefixEmail = email.substring(0, email.indexOf('@') + 1);
//       final suffixEmail = email.substring(
//         email.indexOf('@') + 1,
//       );
//       if (suffixEmail.isNotEmpty) {
//         emailSuffixes = emailSuffixes
//             .where((suffix) {
//               return suffix.startsWith(suffixEmail);
//             })
//             .map((e) => e)
//             .toList();
//       }
//
//       return Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//             color: const Color(0xFFF7F7F7),
//             borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.r))),
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(color: const Color(0xFFE8E8E8), width: 1.h),
//             ),
//           ),
//           child: Column(
//             children: [
//               SizedBox(height: 10.h),
//               ListView.separated(
//                 shrinkWrap: true,
//                 itemBuilder: (BuildContext context, int index) {
//                   return InkWell(
//                     onTap: () {
//                       ref
//                           .read(signUpFormProvider.notifier)
//                           .updateForm(showAutoComplete: false);
//                       widget.controller.text =
//                           prefixEmail + emailSuffixes[index];
//                       ref.read(signUpFormProvider.notifier).updateForm(
//                           email: prefixEmail + emailSuffixes[index]);
//                       FocusScope.of(context).requestFocus(FocusNode());
//                     },
//                     child: Text(
//                       prefixEmail + emailSuffixes[index],
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         letterSpacing: -0.25.sp,
//                         fontWeight: FontWeight.w500,
//                         color: const Color(0xFF000000),
//                       ),
//                     ),
//                   );
//                 },
//                 separatorBuilder: (BuildContext context, int index) {
//                   return SizedBox(height: 14.h);
//                 },
//                 itemCount: emailSuffixes.length,
//               ),
//               SizedBox(height: 16.h),
//             ],
//           ),
//         ),
//       );
//     } else {
//       return Container();
//     }
//   }
// }

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

class NumberFormatter extends TextInputFormatter {
  NumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 아무 값이 없을 경우 (값을 지운경우) 지운 값을 그대로 설정
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // 새로 입력된 값을 포멧
    final int parsedValue = int.parse(
        newValue.text); // NumberFormat은 숫자 값만 받을 수 있기 때문에 문자를 숫자로 먼저 변환
    final formatter =
        NumberFormat.decimalPattern(); // 천단위로 콤마를 표시하고 숫자 앞에 화폐 기호 표시하는 패턴 설정
    String newText = formatter.format(parsedValue); // 입력된 값을 지정한 패턴으로 포멧

    return newValue.copyWith(
        text: newText,
        selection:
            TextSelection.collapsed(offset: newText.length)); // 커서를 마지막으로 이동
  }
}

class MoneyFormatter extends TextInputFormatter {
  MoneyFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 아무 값이 없을 경우 (값을 지운경우) 지운 값을 그대로 설정
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // 새로 입력된 값을 포멧
    final int parsedValue = int.parse(
        newValue.text); // NumberFormat은 숫자 값만 받을 수 있기 때문에 문자를 숫자로 먼저 변환
    final formatter =
        NumberFormat.decimalPattern(); // 천단위로 콤마를 표시하고 숫자 앞에 화폐 기호 표시하는 패턴 설정
    String newText = '₩ ${formatter.format(parsedValue)}'; // 입력된 값을 지정한 패턴으로 포멧

    return newValue.copyWith(
        text: newText,
        selection:
            TextSelection.collapsed(offset: newText.length)); // 커서를 마지막으로 이동
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
