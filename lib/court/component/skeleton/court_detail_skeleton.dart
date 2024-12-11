import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/common/component/skeleton.dart';
import 'package:miti/game/component/skeleton/game_list_skeleton.dart';
import 'package:miti/theme/color_theme.dart';

import '../../../theme/text_theme.dart';
import '../../../util/util.dart';

class CourtDetailSkeleton extends StatelessWidget {
  const CourtDetailSkeleton({super.key});

  Widget getDivider() {
    return Container(color: MITIColor.gray800, height: 4.h);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MITIColor.gray700,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MapSkeleton(),
            getDivider(),
            const CourtInfoSkeleton(),
            getDivider(),
            const CourtGameSkeleton(),
          ],
        ),
      ),
    );
  }
}

class MapSkeleton extends StatelessWidget {
  const MapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(13.r),
      child: const BoxSkeleton(
        height: 200,
        width: 350,
        borderRadius: 20,
      ),
    );
  }
}

class CourtInfoSkeleton extends StatelessWidget {
  const CourtInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const BoxSkeleton(height: 18, width: 333),
          SizedBox(height: 8.h),
          const BoxSkeleton(height: 14, width: 190),
          SizedBox(height: 20.h),
          const BoxSkeleton(height: 20, width: 333),
          SizedBox(height: 5.h),
          const BoxSkeleton(height: 20, width: 333),
          SizedBox(height: 5.h),
          const BoxSkeleton(height: 20, width: 333),
        ],
      ),
    );
  }
}

class CourtGameSkeleton extends StatelessWidget {
  const CourtGameSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 24.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "이 경기장에 생성된 경기",
                style: MITITextStyle.lgBold.copyWith(
                  color: MITIColor.gray100,
                ),
              ),
              Row(
                children: [
                  Text(
                    '더보기',
                    style: MITITextStyle.xxsmLight.copyWith(
                      color: MITIColor.gray100,
                    ),
                  ),
                  SvgPicture.asset(
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: 'chevron_right',
                    ),
                    colorFilter: const ColorFilter.mode(
                      MITIColor.gray400,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              )
            ],
          ),
          const GameListSkeleton()
        ],
      ),
    );
  }
}
