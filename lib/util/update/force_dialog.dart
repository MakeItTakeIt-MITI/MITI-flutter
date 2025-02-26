import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/util/util.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/model/remote_config_model.dart';

class AppStoreStyleUpdateDialog extends StatelessWidget {
  final RemoteConfigState remoteConfig;

  const AppStoreStyleUpdateDialog({
    super.key,
    required this.remoteConfig,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !remoteConfig.forceUpdate, // 뒤로가기 방지
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 앱 아이콘 (실제 앱에서는 앱 아이콘 이미지를 사용)
                Container(
                  width: 75.r,
                  height: 75.r,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    AssetUtil.getAssetPath(type: AssetType.logo, name: 'MITI'),
                    width: 80.w,
                    height: 42.h,
                  ),
                ),
                SizedBox(height: 20.h),

                // 앱 이름과 업데이트 텍스트
                Text(
                  'MITI 업데이트',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '버전 ${remoteConfig.updateVersion}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),

                // 업데이트 내용
                Container(
                  padding: EdgeInsets.all(12.r),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '새로운 기능',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200.h),
                        child: ListView.separated(
                          shrinkWrap: true,
                          // physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, idx) {
                            return getUpdateMessage(
                                remoteConfig.updateMessage[idx]);
                          },
                          separatorBuilder: (_, __) => SizedBox(height: 4.h),
                          itemCount: remoteConfig.updateMessage.length,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 업데이트 버튼

                if (remoteConfig.forceUpdate)
                  TextButton(
                      onPressed: () {
                        launchStore(remoteConfig.storeUrl);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: MITIColor.gray900,
                      ),
                      child: Text(
                        '업데이트',
                        style: MITITextStyle.smBold.copyWith(
                          color: MITIColor.gray50,
                        ),
                      ))
                else
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            onPressed: () {
                              launchStore(remoteConfig.storeUrl);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: MITIColor.gray900,
                            ),
                            child: Text(
                              '업데이트',
                              style: MITITextStyle.smBold.copyWith(
                                color: MITIColor.gray50,
                              ),
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton(
                            onPressed: () {
                              context.pop();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: MITIColor.gray900,
                            ),
                            child: Text(
                              '나중에',
                              style: MITITextStyle.smBold.copyWith(
                                color: MITIColor.gray50,
                              ),
                            )),
                      ),
                    ],
                  ),
                SizedBox(height: 8.h),

                // 현재 버전 정보
                Text(
                  '현재 버전: ${remoteConfig.currentAppVersion}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getUpdateMessage(String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

// 스토어로 이동하는 로직
Future<void> launchStore(String storeUrl) async {
  final Uri url = Uri.parse(storeUrl);

  if (!await launchUrl(url)) {
    throw Exception('스토어를 열 수 없습니다');
  }
}
