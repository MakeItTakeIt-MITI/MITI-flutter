import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

enum DropButtonType {
  district,
  game,
  review,
  transfer,
  settlement,
  participation,
}

final dropDownValueProvider = StateProvider.family
    .autoDispose<String?, DropButtonType>((ref, type) => null);

class CustomDropDownButton extends ConsumerStatefulWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? initValue;
  final double? width;
  final double? height;
  final double? radius;
  final double? padding;
  final TextStyle? textStyle;
  final DropButtonType type;

  const CustomDropDownButton({
    super.key,
    required this.items,
    required this.onChanged,
    this.initValue,
    this.width,
    this.height,
    this.radius,
    this.padding,
    this.textStyle,
    required this.type,
  });

  @override
  ConsumerState<CustomDropDownButton> createState() =>
      _CustomDropDownButtonState();
}

class _CustomDropDownButtonState extends ConsumerState<CustomDropDownButton> {
  String? selectedValue = '전체';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(dropDownValueProvider(widget.type).notifier)
          .update((state) => widget.initValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedValue = ref.watch(dropDownValueProvider(widget.type));
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        // isDense: true,
        style: widget.textStyle ??
            MITITextStyle.xxsm.copyWith(
              color: MITIColor.gray100,
              fontWeight: FontWeight.w400,
            ),

        items: widget.items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                    ),
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: widget.onChanged,
        buttonStyleData: ButtonStyleData(
          padding: EdgeInsets.only(left: 16.w, right: 4.w),
          // padding: EdgeInsets.all(widget.padding ?? 8.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius ?? 100.r),
            color: MITIColor.gray700,
          ),
          height: widget.height ?? 28.h,
          width: widget.width ?? 92.w,
        ),
        iconStyleData: IconStyleData(
            openMenuIcon: Icon(
              Icons.keyboard_arrow_up,
              color: MITIColor.primary,
              size: 16.r,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: MITIColor.primary,
              size: 16.r,
            )),
        dropdownStyleData: DropdownStyleData(
            // scrollPadding: EdgeInsets.only(top: 4.h),
            // width: 85.w,
            offset: Offset(0, -4.h),
            elevation: 0,
            maxHeight: MediaQuery.of(context).size.height < 600.h
                ? MediaQuery.of(context).size.height - 200.h
                : 300.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: MITIColor.gray750)),
        menuItemStyleData: MenuItemStyleData(
          overlayColor: WidgetStateProperty.all(const Color(0xFF404040)),
          height: 24.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        ),
      ),
    );
  }
}
