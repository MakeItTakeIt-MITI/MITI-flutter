
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/theme/color_theme.dart';

import '../../theme/text_theme.dart';
import '../model/default_model.dart';

typedef OnTapPage = void Function(int page);

class BottomPageCount<T> extends ConsumerWidget {
  final PaginationModel<T> pModelList;
  final VoidCallback onPageStart;
  final VoidCallback onPageLast;
  final OnTapPage onTapPage;
  final bool isSliver;

  const BottomPageCount({
    super.key,
    required this.pModelList,
    required this.onTapPage,
    required this.onPageStart,
    required this.onPageLast,
    this.isSliver = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // log('pModelList.pageNumber = ${pModelList.pageNumber}');
    // log('pModelList.totalPages = ${pModelList.totalPages}');
    // log('pModelList.numberOfElements = ${pModelList.numberOfElements}');
    int startPage = (pModelList.current_index ~/ 5) * 5 + 1;
    final bool isLastPage =
        ((pModelList.current_index ~/ 5) + 1) * 5 > pModelList.end_index;
    int lastPage = isLastPage // 마지막 페이지면 totalPage 아니면 시작페이지 + 5
        ? pModelList.end_index
        : ((pModelList.current_index ~/ 5) + 1) * 5;

    final lastDiff = pModelList.end_index - pModelList.current_index;
    // 1 2 3 4     5 6   7 8 9 10 11
    if (lastDiff < 2 && pModelList.end_index >= 5) {
      startPage = pModelList.end_index - 4;
      lastPage = pModelList.end_index;
    } else if (pModelList.current_index <= 2 && pModelList.end_index >= 5) {
      startPage = 1;
      lastPage = 5;
    } else if (pModelList.end_index < 5) {
      startPage = (pModelList.current_index ~/ 5) * 5 + 1;
      final bool isLastPage =
          ((pModelList.current_index ~/ 5) + 1) * 5 > pModelList.end_index;
      lastPage = isLastPage // 마지막 페이지면 totalPage 아니면 시작페이지 + 5
          ? pModelList.end_index
          : ((pModelList.current_index ~/ 5) + 1) * 5;
    } else {
      startPage = pModelList.current_index - 2;
      lastPage = pModelList.current_index + 2;
    }

    //
    // log("startPage ${startPage}");
    // log("lastDividePage ${((pModelList.pageNumber! ~/ 5) + 1) * 5}");
    if (pModelList.page_content.isEmpty && !isSliver) {
      return Container();
    } else if (pModelList.page_content.isEmpty) {
      return const SliverToBoxAdapter();
    }

    if (!isSliver) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPageStart,
            child: Icon(
              Icons.chevron_left,
              size: 24.r,
              color: const Color(0xFF999999),
            ),
          ),
          SizedBox(width: 20.w),
          for (int i = startPage; i < lastPage + 1; i++)
            GestureDetector(
              onTap: () {
                onTapPage(i);
              },
              child: Container(
                height: 24.r,
                width: 24.r,
                padding: EdgeInsets.only(left: i != startPage ? 4.w : 0),
                alignment: Alignment.center,
                child: Text((i).toString(),
                    style: MITITextStyle.xxsmBold.copyWith(
                        color: (pModelList.current_index) == (i)
                            ? MITIColor.primary
                            : MITIColor.gray500)),
              ),
            ),
          SizedBox(width: 20.w),
          GestureDetector(
            onTap: onPageLast,
            child: Icon(
              Icons.chevron_right,
              size: 24.r,
              color: const Color(0xFF999999),
            ),
          )
        ],
      );
    }

    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPageStart,
            child: Icon(
              Icons.chevron_left,
              size: 24.r,
              color: const Color(0xFF999999),
            ),
          ),
          for (int i = startPage; i < lastPage + 1; i++)
            GestureDetector(
              onTap: () {
                onTapPage(i);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: Text((i).toString(),
                    style: MITITextStyle.xxsmBold.copyWith(
                        color: (pModelList.current_index) == (i)
                            ? MITIColor.primary
                            : MITIColor.gray500)),
              ),
            ),
          GestureDetector(
            onTap: onPageLast,
            child: Icon(
              Icons.chevron_right,
              size: 24.r,
              color: const Color(0xFF999999),
            ),
          )
        ],
      ),
    );
  }
}
