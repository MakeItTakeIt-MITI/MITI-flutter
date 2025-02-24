import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../util.dart';

class WidgetUtil {
  static List<Widget> getStar(double rating) {
    List<Widget> result = [];
    for (int i = 0; i < 5; i++) {
      bool flag = false;
      if (i == rating.toInt()) {
        final decimalPoint = rating - rating.toInt();
        flag = decimalPoint != 0;
      }
      final String star = flag
          ? 'Star_half_v2'
          : rating >= i + 1
              ? 'fill_star2'
              : 'unfill_star2';
      result.add(Padding(
        padding: EdgeInsets.only(right: 2.w),
        child: SvgPicture.asset(
          AssetUtil.getAssetPath(type: AssetType.icon, name: star),
          height: 16.r,
          width: 16.r,
        ),
      ));
    }
    return result;
  }
}
