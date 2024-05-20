import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final dropDownValueProvider = StateProvider.autoDispose<String?>((ref) => null);

class CustomDropDownButton extends ConsumerStatefulWidget {
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? initValue;
  final double? width;
  final double? height;
  final double? radius;
  final double? padding;
  final TextStyle? textStyle;

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
  });

  @override
  ConsumerState<CustomDropDownButton> createState() =>
      _CustomDropDownButtonState();
}

class _CustomDropDownButtonState extends ConsumerState<CustomDropDownButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(dropDownValueProvider.notifier)
          .update((state) => widget.initValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = ref.watch(dropDownValueProvider);
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        // isDense: true,
        style: widget.textStyle ?? TextStyle(
          color: const Color(0xFF333333),
          fontSize: 12.sp,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          letterSpacing: -0.25.sp,
        ),
        items: widget.items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      item,
                    ),
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: widget.onChanged,
        buttonStyleData: ButtonStyleData(
          padding: EdgeInsets.all(widget.padding ?? 8.r),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius ?? 4.r),
              color: const Color(0xFFF7F7F7)),
          height: widget.height ?? 39.h,
          width: widget.width ?? 85.w,
        ),
        iconStyleData: IconStyleData(
            icon: Icon(
          Icons.keyboard_arrow_down,
          size: 16.r,
        )),
        dropdownStyleData: DropdownStyleData(
            scrollPadding: EdgeInsets.zero,
            // width: 85.w,
            elevation: 0,
            maxHeight: MediaQuery.of(context).size.height < 600.h
                ? MediaQuery.of(context).size.height - 200.h
                : 300.h,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(4.r),
                ),
                color: const Color(0xFFF7F7F7))),
        menuItemStyleData: MenuItemStyleData(
          height: 30.h,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
