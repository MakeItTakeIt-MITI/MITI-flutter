import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/notification/param/push_setting_param.dart';
import 'package:miti/notification/provider/notification_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/component/custom_dialog.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/v2/notification/push_notification_setting_response.dart';
import '../model/push_model.dart';

final permissionNotiProvider = StateProvider<bool>((s) => true);

class NotificationSettingScreen extends ConsumerStatefulWidget {
  static String get routeName => 'notificationSetting';

  const NotificationSettingScreen({super.key});

  @override
  ConsumerState<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends ConsumerState<NotificationSettingScreen>
    with WidgetsBindingObserver {
  /// 세팅 가능한 topic 만 가져오기
  List<PushNotificationTopicType> topics = [];

  //PushNotificationTopicType.values.where((p) => p.canSetting).toList();

  // bool viewPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 앱 라이프사이클 감지기 등록
    WidgetsBinding.instance.addPostFrameCallback((p) async {
      await getPermission();
    });
  }

  Future<void> getPermission() async {
    final status = await Permission.notification.status;
    final viewPermission = status != PermissionStatus.granted;
    ref.read(permissionNotiProvider.notifier).update((s) {
      // viewPermission = after;
      final bModel = ref.read(pushSettingProvider);
      if (viewPermission) {
        topics = [];
      } else if (bModel is ResponseModel<PushNotificationSettingResponse>) {
        topics = bModel.data!.allowedTopic;
      }
      return viewPermission;
    });
    log('status = $viewPermission');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 감지기 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화되었을 때 실행할 동작
      print('앱이 다시 활성화되었습니다.');
      WidgetsBinding.instance.addPostFrameCallback((p) {
        setState(() {
          getPermission();
        });
      });
      // 앱이 활성화되면 애니메이션 재개
    } else if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 전환될 때 실행할 동작
      print('앱이 백그라운드로 전환되었습니다.');
      // 앱이 백그라운드로 가면 애니메이션 정지
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(pushSettingProvider);
    // log('prev topics = $topics');
    final viewPermission = ref.watch(permissionNotiProvider);
    if (result is ResponseModel<PushNotificationSettingResponse> && !viewPermission) {
      topics = result.data!.allowedTopic;
    }
    // log('after topics = $topics');
    final all = topics.length == 4;
    final general = topics.contains(PushNotificationTopicType.general);
    final status =
        topics.contains(PushNotificationTopicType.game_status_changed);
    final guest = topics.contains(PushNotificationTopicType.new_participation);
    final fee = topics.contains(PushNotificationTopicType.game_fee_changed);
    ref.listen(permissionNotiProvider, (prev, after) {});

    return Scaffold(
      appBar: const DefaultAppBar(
        title: '알림 설정',
        backgroundColor: MITIColor.gray800,
        hasBorder: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
        child: Column(
          children: [
            Visibility(
              visible: viewPermission,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
                margin: EdgeInsets.only(bottom: 28.h),
                decoration: BoxDecoration(
                    color: MITIColor.gray700,
                    borderRadius: BorderRadius.circular(12.r)),
                child: Text(
                  '서비스 알림을 받으려면 고객님 기기 내 설정에서 알림을 허용해 주세요.',
                  style: MITITextStyle.sm150.copyWith(
                    color: MITIColor.gray200,
                  ),
                ),
              ),
            ),
            _SwitchTile(
              title: '전체 서비스 알림 받기',
              isOn: all,
              onToggle: (bool value) async {
                if (viewPermission) {
                  showPermissionDialog(context);
                  return;
                }

                /// optimistic update
                final model = ref.read(pushSettingProvider);
                if (model is ResponseModel<PushNotificationSettingResponse>) {
                  ref.read(pushSettingProvider.notifier).update(
                      model:
                          optimisticSetting(isOn: value, model: model.data!));
                }
                final result = await ref
                    .read(pushStatusUpdateProvider(isOn: value).future);
              },
            ),
            Divider(
              height: 57.h,
              color: MITIColor.gray600,
            ),
            _SwitchTile(
              title: '공지사항 알림',
              desc: '공지사항이 업데이트 되면 안내해 드립니다.',
              isOn: general,
              onToggle: (bool value) async {
                if (viewPermission) {
                  showPermissionDialog(context);
                  return;
                }

                /// optimistic update
                final model = ref.read(pushSettingProvider);
                if (model is ResponseModel<PushNotificationSettingResponse>) {
                  ref.read(pushSettingProvider.notifier).update(
                      model: optimisticSetting(
                          isOn: value,
                          model: model.data!,
                          topic: PushNotificationTopicType.general));
                }
                final result = await ref.read(pushStatusUpdateProvider(
                        isOn: value,
                        push: PushSettingParam(
                            topic: PushNotificationTopicType.general))
                    .future);
              },
            ),
            SizedBox(height: 28.h),
            _SwitchTile(
              title: '경기상태 변경 알림',
              desc: '참여하는 경기의 상태가 변경되면 안내해 드립니다.',
              isOn: status,
              onToggle: (bool value) async {
                if (viewPermission) {
                  showPermissionDialog(context);
                  return;
                }

                /// optimistic update
                final model = ref.read(pushSettingProvider);
                if (model is ResponseModel<PushNotificationSettingResponse>) {
                  ref.read(pushSettingProvider.notifier).update(
                      model: optimisticSetting(
                          isOn: value,
                          model: model.data!,
                          topic:
                              PushNotificationTopicType.game_status_changed));
                }
                final result = await ref.read(pushStatusUpdateProvider(
                        isOn: value,
                        push: PushSettingParam(
                            topic:
                                PushNotificationTopicType.game_status_changed))
                    .future);
              },
            ),
            SizedBox(height: 28.h),
            _SwitchTile(
              title: '새로운 게스트 알림',
              desc: '새로운 게스트가 참여하면 호스트에게 안내해 드립니다.',
              isOn: guest,
              onToggle: (bool value) async {
                if (viewPermission) {
                  showPermissionDialog(context);
                  return;
                }

                /// optimistic update
                final model = ref.read(pushSettingProvider);
                if (model is ResponseModel<PushNotificationSettingResponse>) {
                  ref.read(pushSettingProvider.notifier).update(
                      model: optimisticSetting(
                          isOn: value,
                          model: model.data!,
                          topic: PushNotificationTopicType.new_participation));
                }
                final result = await ref.read(pushStatusUpdateProvider(
                        isOn: value,
                        push: PushSettingParam(
                            topic: PushNotificationTopicType.new_participation))
                    .future);
              },
            ),
            SizedBox(height: 28.h),
            _SwitchTile(
              title: '경기 참여비용 변경 알림',
              desc: '경기 참여비용이 변경되면 게스트에게 안내해 드립니다.',
              isOn: fee,
              onToggle: (bool value) async {
                if (viewPermission) {
                  showPermissionDialog(context);
                  return;
                }

                /// optimistic update
                final model = ref.read(pushSettingProvider);
                if (model is ResponseModel<PushNotificationSettingResponse>) {
                  ref.read(pushSettingProvider.notifier).update(
                      model: optimisticSetting(
                          isOn: value,
                          model: model.data!,
                          topic: PushNotificationTopicType.game_fee_changed));
                }
                final result = await ref.read(pushStatusUpdateProvider(
                        isOn: value,
                        push: PushSettingParam(
                            topic: PushNotificationTopicType.game_fee_changed))
                    .future);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showPermissionDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return const PermissionDialog(
            title: '설정>개인정보보호>위치서비스와\n설정>MITI에서 위치 정보 접근을\n모두 허용해 주세요.',
          );
        });
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
