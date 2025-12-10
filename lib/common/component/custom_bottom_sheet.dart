import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

Future<void> showCustomModalBottomSheet(
    BuildContext context, Widget child) async {
  await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      backgroundColor: V2MITIColor.gray12,
      builder: (context) {
        return Padding(
            padding: EdgeInsets.only(
                left: 16.w, right: 16.w, top: 20.h, bottom: 45.h),
            child: child);
      });
}

class CustomBottomSheet {
  static Widget popButton(BuildContext context) {
    return Align(
        alignment: Alignment.topRight,
        child: IconButton(
            onPressed: () => context.pop(),
            style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: WidgetStateProperty.all(EdgeInsets.zero)),
            constraints: BoxConstraints.tight(Size(24.r, 24.r)),
            icon: const Icon(
              Icons.close,
              color: MITIColor.white,
            )));
  }

  static Future<void> showStringContent(
      {required BuildContext context,
      String? title,
      required String content,
      required VoidCallback onPressed,
      required String buttonText,
      required EdgeInsetsGeometry contentPadding,
      bool hasPop = false}) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        backgroundColor: V2MITIColor.gray12,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  decoration: BoxDecoration(
                    color: V2MITIColor.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  height: 5.h,
                  width: 140.w,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title ?? '',
                      style: V2MITITextStyle.regularBoldTight
                          .copyWith(color: V2MITIColor.gray1),
                    ),
                    const Spacer(),
                    // title,
                    if (hasPop) popButton(context),
                  ],
                ),

                Padding(
                  padding: contentPadding,
                  child: Text(
                    content,
                    style: V2MITITextStyle.smallRegularNormal
                        .copyWith(color: V2MITIColor.gray1),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
                  child: TextButton(
                    onPressed: onPressed,
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static Future<void> showWidgetContent(
      {required BuildContext context,
      String? title,
      required Widget content,
      VoidCallback? onPressed,
      required String buttonText,
      EdgeInsetsGeometry contentPadding = EdgeInsets.zero,
      bool useRootNavigator = false,
      bool hasPop = false}) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        useRootNavigator: useRootNavigator,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        backgroundColor: V2MITIColor.gray12,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // drag handle
                Container(
                  decoration: BoxDecoration(
                    color: V2MITIColor.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  height: 5.h,
                  width: 140.w,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title ?? '',
                      style: V2MITITextStyle.regularBoldTight
                          .copyWith(color: V2MITIColor.gray1),
                    ),
                    const Spacer(),
                    // title,
                    if (hasPop) popButton(context),
                  ],
                ),

                content,
                if (onPressed != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
                    child: TextButton(
                      onPressed: onPressed,
                      child: Text(buttonText),
                    ),
                  ),
              ],
            ),
          );
        });
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<Widget> Function(void Function() refreshModal)
        childrenBuilder, // 변경된 부분
    VoidCallback? onClose,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      isScrollControlled: true,
      useRootNavigator: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r),
        ),
      ),
      backgroundColor: V2MITIColor.gray12,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // refreshModal 함수로 setState 전달
            void refreshModal() => setState(() {});

            return _buildContent(
              context: context,
              title: title,
              children: childrenBuilder(refreshModal),
              // setState 전달
              onClose: onClose,
              maxHeight: maxHeight,
            );
          },
        );
      },
    );
  }

  static Widget _buildContent({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    VoidCallback? onClose,
    double? maxHeight,
  }) {
    return Container(
      constraints:
          maxHeight != null ? BoxConstraints(maxHeight: maxHeight) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              decoration: BoxDecoration(
                color: V2MITIColor.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
              height: 5.h,
              width: 140.w,
              margin: EdgeInsets.symmetric(vertical: 8.h),
            ),

            // header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: V2MITITextStyle.regularBoldTight.copyWith(
                    color: V2MITIColor.gray1,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: SvgPicture.asset(
                    AssetUtil.getAssetPath(
                      type: AssetType.icon,
                      name: 'close',
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10.h),

            ...children,

            // 하단 여백 (SafeArea 대용)
            SizedBox(height: MediaQuery.of(context).padding.bottom + 24.h),
          ],
        ),
      ),
    );
  }
}
