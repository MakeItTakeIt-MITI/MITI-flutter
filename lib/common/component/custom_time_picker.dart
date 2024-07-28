import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/game/view/game_create_screen.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class CustomDateTimePicker extends ConsumerStatefulWidget {
  final bool isStart;

  const CustomDateTimePicker({
    super.key,
    required this.isStart,
  });

  @override
  ConsumerState<CustomDateTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends ConsumerState<CustomDateTimePicker> {
  int dateIdx = 0;

  DateTime selectedDate = DateTime.now();
  int selectedHour = DateTime.now().hour;
  int selectedMinute = (DateTime.now().minute ~/ 10) * 10;
  late final List<Widget> dateItems;
  late final FixedExtentScrollController dateController;

  String date = "";

  @override
  void initState() {
    super.initState();
    dateItems = generateDateItems();
    dateController =
        FixedExtentScrollController(initialItem: getCurrentDateIndex());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      date = generateDateString(0);
      selectedHour = DateTime.now().hour;
      selectedMinute = ((DateTime.now().minute ~/ 10) * 10);
      ref.read(datePickerProvider(widget.isStart).notifier).update((state) =>
          "$date ${selectedHour.toString()}:${selectedMinute.toString()}");
    });
  }

  String generateDateString(int idx) {
    log("index = $idx");
    List<String> items = [];
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime(2100);

    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1))) {
      items.add(
        '${date.year} / ${date.month} / ${date.day} (${[
          '월',
          '화',
          '수',
          '목',
          '금',
          '토',
          '일'
        ][date.weekday - 1]})',
      );
    }
    return items[idx];
  }

  List<Widget> generateDateItems() {
    List<Widget> items = [];
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime(2100);

    int idx = 0;
    for (DateTime date = startDate;
        date.isBefore(endDate);
        date = date.add(const Duration(days: 1)), idx++) {
      final showYear = date.month == 1 && date.day == 1;

      String year = "${date.year.toString().substring(2)} / ";
      if (!showYear) {
        year = "";
      }

      items.add(
        Center(
          child: Text(
              '$year${date.month} / ${date.day} (${[
                '월',
                '화',
                '수',
                '목',
                '금',
                '토',
                '일'
              ][date.weekday - 1]})',
              style: MITITextStyle.md.copyWith(
                color: dateIdx == idx ? MITIColor.primary : MITIColor.gray300,
              )),
        ),
      );
    }

    return items;
  }

  void changeSelectDate() {
    ref.read(datePickerProvider(widget.isStart).notifier).update((state) =>
        "$date ${selectedHour.toString()}:${selectedMinute.toString()}");
  }

  int getCurrentDateIndex() {
    DateTime startDate = DateTime.now();
    return DateTime.now().difference(startDate).inDays;
  }

  Widget selectionOverlay() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.all(Radius.circular(8.r)),
          color: CupertinoDynamicColor.resolve(
              MITIColor.white.withOpacity(0.1), context),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: CupertinoPicker(
            itemExtent: 32.h,
            diameterRatio: 10,
            squeeze: 1.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                DateTime startDate = DateTime.now();
                selectedDate = startDate.add(Duration(days: index));
                dateIdx = index;
                date = generateDateString(index);
                changeSelectDate();
              });
            },
            selectionOverlay: selectionOverlay(),
            scrollController: dateController,
            children: generateDateItems(),
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: CupertinoPicker(
            itemExtent: 32.h,
            diameterRatio: 10,
            squeeze: 1.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedHour = index;
                changeSelectDate();
              });
            },
            looping: true,
            selectionOverlay: selectionOverlay(),
            scrollController:
                FixedExtentScrollController(initialItem: selectedHour),
            children: List<Widget>.generate(24, (int index) {
              return Center(
                  child: Text('$index',
                      style: MITITextStyle.md.copyWith(
                        color: selectedHour == index
                            ? MITIColor.primary
                            : MITIColor.gray300,
                      )));
            }),
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: CupertinoPicker(
            itemExtent: 32.h,
            diameterRatio: 10,
            squeeze: 1.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedMinute = index * 10;

                changeSelectDate();
              });
            },
            looping: true,
            selectionOverlay: selectionOverlay(),
            scrollController:
                FixedExtentScrollController(initialItem: selectedMinute ~/ 10),
            children: List<Widget>.generate(6, (int index) {
              return Center(
                  child: Text(
                '${index * 10}',
                style: MITITextStyle.md.copyWith(
                  color: selectedMinute ~/ 10 == index
                      ? MITIColor.primary
                      : MITIColor.gray300,
                ),
              ));
            }),
          ),
        ),
      ],
    );
  }
}
