import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../util/util.dart';
import '../provider/search_history_provider.dart';

class RecentSearchHistoryComponent extends ConsumerWidget {
  final OnSearch onSearch;

  const RecentSearchHistoryComponent({
    super.key,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchHistory = ref.watch(searchHistoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "최근 검색어",
              style: MITITextStyle.mdBold.copyWith(color: Colors.white),
            ),
            InkWell(
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                ref.read(searchHistoryProvider.notifier).clearAll();
              },
              child: Container(
                margin: EdgeInsets.all(4.r),
                child: Text(
                  "전체 삭제",
                  style: MITITextStyle.xxsmLight
                      .copyWith(color: MITIColor.gray600),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            if (searchHistory.isEmpty) {
              return Center(
                child: Text(
                  "검색한 기록이 없습니다.",
                  style: MITITextStyle.sm,
                ),
              );
            }

            return ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, idx) => SearchHistory(
                      history: searchHistory[idx],
                      onDelete: () {
                        ref
                            .read(searchHistoryProvider.notifier)
                            .removeSearch(searchHistory[idx]);
                      },
                      onSearch: () {
                        onSearch(searchHistory[idx]);
                      },
                    ),
                itemCount: searchHistory.length);
          },
        )
      ],
    );
  }
}

class SearchHistory extends StatelessWidget {
  final String history;
  final VoidCallback onSearch;
  final VoidCallback onDelete;

  const SearchHistory(
      {super.key,
      required this.history,
      required this.onDelete,
      required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onSearch,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              color: MITIColor.gray900,
              child: Row(
                children: [
                  SvgPicture.asset(
                    AssetUtil.getAssetPath(
                        type: AssetType.icon, name: 'clock_v2'),
                    width: 20.r,
                    height: 20.r,
                    colorFilter: const ColorFilter.mode(
                      MITIColor.gray400,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Text(
                      history,
                      style:
                          MITITextStyle.sm150.copyWith(color: MITIColor.gray400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onDelete,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.h),
            child: SvgPicture.asset(
              AssetUtil.getAssetPath(type: AssetType.icon, name: 'close'),
              width: 20.r,
              height: 20.r,
              colorFilter: const ColorFilter.mode(
                MITIColor.gray400,
                BlendMode.srcIn,
              ),
            ),
          ),
        )
      ],
    );
  }
}
