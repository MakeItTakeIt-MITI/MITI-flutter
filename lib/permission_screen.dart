import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/provider/secure_storage_provider.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  static String get routeName => 'permission';

  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  late final Box<bool> _permissionBox;

  @override
  void initState() {
    super.initState();
    _permissionBox = Hive.box('permission');
  }

  void _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    log('requestStatus = ${requestStatus}');
    if (requestStatus.isGranted && status.isLimited) {
      // isLimited - 제한적 동의 (ios 14 < )
      // 요청 동의됨
      print("isGranted");
      if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
        // 요청 동의 + gps 켜짐
        var position = await Geolocator.getCurrentPosition();
        print("serviceStatusIsEnabled position = ${position.toString()}");
      } else {
        // 요청 동의 + gps 꺼짐
        print("serviceStatusIsDisabled");
      }
    } else if (requestStatus.isPermanentlyDenied ||
        status.isPermanentlyDenied) {
      // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
      print("isPermanentlyDenied");
      await openAppSettings();
    } else if (status.isRestricted) {
      // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
      print("isRestricted");
      await openAppSettings();
    } else if (status.isDenied) {
      // 권한 요청 거절
      print("isDenied");
    }
    print("requestStatus ${requestStatus.name}");
    print("status ${status.name}");
    // final storage = ref.read(secureStorageProvider);
    // await storage.write(key: 'firstJoin', value: 'true');
    await _permissionBox.put('permission', true);
    if (mounted) {
      context.goNamed(CourtMapScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.w),
            child: Column(
              children: [
                SizedBox(height: 196.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '앱 접근 권한 안내',
                      style: MITITextStyle.pageMainTextStyle,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'MITI 서비스 사용을 위해서는 다음의 권한 허용이 필요합니다.',
                      style: MITITextStyle.pageSubTextStyle.copyWith(
                        color: const Color(0xff1c1c1c),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/icon/locator.svg',
                      width: 32.r,
                      height: 32.r,
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '위치(필수)',
                            style: MITITextStyle.pageSubTextStyle.copyWith(
                              color: const Color(0xff1c1c1c),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '주변 경기 검색 시 사용',
                            style: MITITextStyle.emailTextStyle.copyWith(
                              color: const Color(0xff969696),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: TextButton(
                onPressed: () {
                  _permission();
                },
                child: const Text('확인')),
          )
        ],
      ),
    );
  }
}
