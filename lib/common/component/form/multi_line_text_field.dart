import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/color_theme.dart';

class MultiLineTextField extends StatelessWidget {
  final TextEditingController textController;
  final InputBorder inputBorder;
  final ValueChanged<String> onChanged;
  final TextStyle textStyle;
  final String hintText;
  final FocusNode focusNode;

  const MultiLineTextField(
      {super.key,
      required this.textController,
      required this.inputBorder,
      required this.onChanged,
      required this.hintText,
      required this.textStyle,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: textController,
      maxLines: null,
      expands: true,
      maxLength: 3000,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: textStyle.copyWith(
          color: MITIColor.gray600,
        ),
        enabledBorder: inputBorder.copyWith(borderSide: BorderSide.none),
        border: inputBorder.copyWith(borderSide: BorderSide.none),
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide.none),
        contentPadding: EdgeInsets.all(0.r),
        filled: false,
      ),
      onChanged: onChanged,
      style: textStyle.copyWith(
        color: MITIColor.gray100,
      ),
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.top,
    );
  }
}
