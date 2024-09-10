import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:flutter_switch/flutter_switch.dart';

class NotificationSettingScreen extends StatelessWidget {
  static String get routeName => 'notificationSetting';

  const NotificationSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: '알림 설정',
        backgroundColor: MITIColor.gray800,
        hasBorder: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
        child: Column(
          children: [
            _SwitchTile(
              title: '전체 서비스 알림 받기',
              isOn: false,
              onToggle: (bool value) {},
            ),
            Divider(
              height: 57.h,
              color: MITIColor.gray600,
            ),
            _SwitchTile(
              title: '공지사항 알림',
              desc: '공지사항이 업데이트 되면 안내해 드립니다.',
              isOn: false,
              onToggle: (bool value) {},
            ),
            SizedBox(height: 28.h),
            _SwitchTile(
              title: '경기상태 변경 알림',
              desc: '참여하는 경기의 상태가 변경되면 안내해 드립니다.',
              isOn: false,
              onToggle: (bool value) {},
            ),
            SizedBox(height: 28.h),
            _SwitchTile(
              title: '새로운 게스트 알림',
              desc: '새로운 게스트가 참여하면 호스트에게 안내해 드립니다.',
              isOn: false,
              onToggle: (bool value) {},
            ),
            SizedBox(height: 28.h),
            _SwitchTile(
              title: '경기 참여비용 변경 알림',
              desc: '경기 참여비용이 변경되면 게스트에게 안내해 드립니다.',
              isOn: false,
              onToggle: (bool value) {},
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? desc;
  final bool isOn;
  final ValueChanged<bool> onToggle;

  const _SwitchTile(
      {super.key,
      required this.title,
      this.desc,
      required this.onToggle,
      required this.isOn});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: MITITextStyle.smBold.copyWith(color: MITIColor.gray300),
              ),
              if (desc != null) SizedBox(height: 12.h),
              if (desc != null)
                Text(
                  desc!,
                  style: MITITextStyle.xxsmLight.copyWith(
                    color: MITIColor.gray300,
                  ),
                ),
            ],
          ),
        ),
        FlutterSwitch(
          width: 50.w,
          height: 28.h,
          toggleSize: 20.r,
          borderRadius: 100.r,
          value: isOn,
          padding: 4.w,
          onToggle: onToggle,
          activeColor: MITIColor.primary,
          toggleColor: MITIColor.gray800,
          inactiveColor: MITIColor.gray500,
        )
      ],
    );
  }
}
