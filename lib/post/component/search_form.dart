import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class SearchForm extends StatefulWidget {
  final String? hintText;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted; // 검색 버튼 눌렀을 때 처리할 콜백 추가
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int maxLength;
  final bool showCounter;
  final String? Function(String?)? validator;
  final bool enabled;

  const SearchForm({
    super.key,
    this.hintText,
    required this.controller,
    this.onChanged,
    this.focusNode,
    this.decoration,
    this.style,
    this.maxLength = 1500,
    this.showCounter = true,
    this.validator,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  State<SearchForm> createState() => _MultiLineTextFieldState();
}

class _MultiLineTextFieldState extends State<SearchForm> {
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
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      style: widget.style ?? MITITextStyle.sm150,
      textAlignVertical: TextAlignVertical.center,
      maxLines: 1,
      // 줄 수 제한 없음
      minLines: 1,
      // 최소 1줄
      textInputAction: TextInputAction.search,
      decoration: (widget.decoration ??
              InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    MITITextStyle.sm150.copyWith(color: MITIColor.gray600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.r),
                  borderSide: BorderSide.none,
                  // borderSide: BorderSide(color: MITIColor.primary),
                ),
                fillColor: MITIColor.gray750.withOpacity(.5),
                // 최소 높이 설정 및 contentPadding 을 적용하기 위해  isDense true 설정
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                // EdgeInsets.all(12.r),
                constraints: BoxConstraints(
                  minHeight: 26.h,
                ),
              ))
          .copyWith(
        // 카운터는 별도로 표시
        counterText: '',
      ),
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        // 최대 글자 수 제한
        if (value.length > widget.maxLength) {
          widget.controller.text = value.substring(0, widget.maxLength);
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.maxLength),
          );
        }
      },
      // 키보드의 검색 버튼을 눌렀을 때 호출되는 콜백
      onFieldSubmitted: (value) {
        if (widget.onSubmitted != null) {
          widget.onSubmitted!(value);
        }
      },
    );
  }
}
