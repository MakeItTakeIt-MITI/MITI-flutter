import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../post/provider/search_history_provider.dart';
import '../../../theme/color_theme.dart';
import '../../../theme/text_theme.dart';

class OverlayNumberPicker extends StatefulWidget {
  final int? initialValue;
  final int start;
  final int end;
  final OnSelect onSelect;

  const OverlayNumberPicker(
      {super.key,
      required this.start,
      required this.end,
      required this.onSelect,
      this.initialValue});

  @override
  State<OverlayNumberPicker> createState() => _OverlayNumberPickerState();
}

class _OverlayNumberPickerState extends State<OverlayNumberPicker> {
  late final FixedExtentScrollController scrollController;
  late int selectedNumber;

  @override
  void initState() {
    super.initState();
    // start~end 범위의 중간값으로 초기화
    int mid = ((widget.start + widget.end) / 2).round();
    // 스크롤 컨트롤러는 인덱스 기준이므로 start를 빼줌
    int initialIndex = widget.initialValue == null
        ? mid - widget.start
        : widget.initialValue! - widget.start;
    scrollController = FixedExtentScrollController(initialItem: initialIndex);
    selectedNumber = widget.initialValue ?? mid;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      itemExtent: 32.h,
      diameterRatio: 10,
      squeeze: 1.0,
      onSelectedItemChanged: (int index) {
        setState(() {
          // 인덱스를 실제 값으로 변환
          selectedNumber = widget.start + index;
          widget.onSelect(selectedNumber);
          // changeSelectDate();
        });
      },
      looping: false,
      selectionOverlay: selectionOverlay(),
      scrollController: scrollController,
      // start~end 범위만큼 생성
      children: List<Widget>.generate(
        widget.end - widget.start + 1, // 범위 크기
        (int index) {
          int actualValue = widget.start + index; // 실제 값
          return Center(
            child: Text(
              '$actualValue',
              style: MITITextStyle.md.copyWith(
                color: selectedNumber == actualValue
                    ? V2MITIColor.primary5
                    : MITIColor.gray300,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget selectionOverlay() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.all(Radius.circular(8.r)),
          color: CupertinoDynamicColor.resolve(
              V2MITIColor.white.withValues(alpha: 0.1), context),
        ),
      );
}
