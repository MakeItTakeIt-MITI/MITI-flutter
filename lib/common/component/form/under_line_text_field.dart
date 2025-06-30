import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../theme/color_theme.dart';

class UnderLineTextField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController textEditingController;
  final ValueChanged<String>? onChanged;
  final TextStyle textStyle;
  final FocusNode focusNode;

  final inputBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: MITIColor.gray600, width: .5));

  const UnderLineTextField({
    super.key,
    required this.textEditingController,
    this.onChanged,
    required this.title,
    required this.hintText,
    required this.textStyle, required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      controller: textEditingController,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: textStyle.copyWith(
            color: MITIColor.gray600,
          ),
          enabledBorder: inputBorder,
          border: inputBorder,
          focusedBorder: inputBorder,
          contentPadding: EdgeInsets.all(0.r),
          counterText: "",
          filled: false,
          suffixText: "(${title.length}/32)",
          suffixStyle: textStyle.copyWith(
            color: MITIColor.gray600,
          )),
      maxLength: 32,
      maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
      style: textStyle.copyWith(
        color: MITIColor.gray100,
      ),
      onChanged: onChanged,
    );
  }
}
