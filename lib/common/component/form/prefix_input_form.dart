import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';

class PrefixInputForm extends StatelessWidget {
  final String? initialValue;
  final String hintText;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final TextEditingController? textEditingController;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onNext;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final bool enabled;
  final TextStyle? hintTextStyle;
  final TextStyle? textStyle;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final double height; // 높이 고정용으로 사용되므로 유지

  const PrefixInputForm({
    super.key,
    required this.hintText,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.textEditingController,
    this.focusNode,
    this.onChanged,
    this.onNext,
    this.inputFormatters,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.enabled = true,
    this.initialValue,
    this.hintTextStyle,
    this.textStyle,
    this.borderColor = V2MITIColor.gray6,
    this.prefix,
    this.onTap,
    this.borderRadius,
    this.height = 48,
  });

  // 헬퍼 메서드: OutlineInputBorder 생성 로직 단순화
  OutlineInputBorder _buildBorder(BorderRadius radius, Color? color) {
    final borderSide =
        color == null ? BorderSide.none : BorderSide(color: color);
    return OutlineInputBorder(
      borderRadius: radius,
      borderSide: borderSide,
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(4.r);
    final defaultTextStyle =
        V2MITITextStyle.regularMediumNormal.copyWith(color: V2MITIColor.white);
    final defaultHintStyle =
        V2MITITextStyle.regularMediumNormal.copyWith(color: V2MITIColor.gray6);
    return TextFormField(
      onTap: onTap,
      initialValue: initialValue,
      focusNode: focusNode,
      controller: textEditingController,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      // 1. 텍스트 입력 수평/수직 중앙 정렬
      textAlign: TextAlign.center,
      // 수평 중앙 정렬
      textAlignVertical: TextAlignVertical.center,
      // 수직 중앙 정렬 (새로 추가)
      inputFormatters: inputFormatters,
      enabled: enabled,
      style: textStyle ?? defaultTextStyle,
      decoration: InputDecoration(
        // 2. 패딩 조정: 수직 중앙 정렬을 돕기 위해 계산된 값 사용
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),

        // height 파라미터를 이용해 높이 강제 (기존 로직 유지)
        constraints: BoxConstraints(maxHeight: height.h, minHeight: height.h),

        // 헬퍼 메서드를 사용하여 중복 제거 (기존 로직 유지)
        focusedBorder: _buildBorder(defaultBorderRadius, borderColor),
        enabledBorder: _buildBorder(defaultBorderRadius, borderColor),
        border: _buildBorder(defaultBorderRadius, borderColor),

        hintText: hintText,
        hintStyle: hintTextStyle ?? defaultHintStyle,
        filled: false,

        // Prefix/Suffix Icon 로직 개선
        // Icon의 중앙 정렬을 돕기 위해 Padding 대신 InputDecoation 속성을 사용할 수 있으나,
        // 기존 스타일 유지 및 Padding 값만 수정하여 수직 중앙 정렬에 맞춥니다.
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(left: 12.w),
                child: prefix,
              ),
        // suffixIcon Padding에서 vertical padding 제거
        suffixIcon: suffixIcon == null
            ? null
            : Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: suffixIcon,
              ),
        // prefixIcon과 suffixIcon의 수직 위치를 TextFormField의 가운데에 맞추는 속성 추가
        prefixIconConstraints: BoxConstraints.loose(Size.fromHeight(height.h)),
        suffixIconConstraints: BoxConstraints.loose(Size.fromHeight(height.h)),
      ),
      validator: validator,
      onChanged: onChanged,
      onEditingComplete: onNext,
    );
  }
}
