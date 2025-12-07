import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../common/model/entity_enum.dart';
import '../../util/util.dart';
import 'game_status_chip.dart';

class GameListFilterStatusBar extends StatelessWidget {
  final List<GameStatusType> items;
  final Function(GameStatusType) onDeleted;
  final VoidCallback onFilterTap;

  const GameListFilterStatusBar(
      {super.key,
      required this.onFilterTap,
      required this.onDeleted,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _GameStatusChipsSection(
              onDeleted: onDeleted,
              items: items,
            ),
          ),
          SizedBox(width: 10.w),
          _FilterButton(
            onFilterTap: onFilterTap,
          )
        ],
      ),
    );
  }
}

class _GameStatusChipsSection extends ConsumerWidget {
  final List<GameStatusType> items;
  final Function(GameStatusType) onDeleted;

  const _GameStatusChipsSection(
      {super.key, required this.items, required this.onDeleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GameStatusChips(
      items: items,
      onDeleted: onDeleted,
    );
  }
}

class _GameStatusChips extends StatelessWidget {
  final List<GameStatusType> items;
  final Function(GameStatusType) onDeleted;

  const _GameStatusChips(
      {super.key, required this.onDeleted, required this.items});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) => GameStatusChip(
            text: items[index].displayName,
            onDeleted: () => onDeleted(items[index]),
          ),
          separatorBuilder: (_, __) => SizedBox(
            width: 6.w,
          ),
          itemCount: items.length,
        );
      },
    );
  }
}

class _FilterButton extends ConsumerWidget {
  final VoidCallback onFilterTap;

  const _FilterButton({super.key, required this.onFilterTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onFilterTap,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: SvgPicture.asset(
        AssetUtil.getAssetPath(type: AssetType.icon, name: 'menu'),
      ),
    );
  }
}
