import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/component/html_component.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/notification/provider/notification_provider.dart';

import '../../common/component/default_appbar.dart';
import '../../common/param/pagination_param.dart';
import '../../etc/component/skeleton/tc_policy_detail_skeleton.dart';
import '../../game/model/v2/notification/notification_response.dart';
import '../../game/model/v2/notification/push_notification_response.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../provider/notification_pagination_provider.dart';

enum NoticeScreenType {
  push,
  notification;
}

class NoticeDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'noticeDetail';

  final int id;
  final NoticeScreenType type;

  const NoticeDetailScreen({
    super.key,
    required this.id,
    required this.type,
  });

  @override
  ConsumerState<NoticeDetailScreen> createState() => _PushDetailScreenState();
}

class _PushDetailScreenState extends ConsumerState<NoticeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((t) {
      if (widget.type == NoticeScreenType.push) {
        final userId = ref.read(authProvider)!.id!;
        ref
            .read(pushPProvider(PaginationStateParam(path: userId)).notifier)
            .read(pushId: widget.id, ref: ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.type == NoticeScreenType.push
        ? ref.watch(pushProvider(pushId: widget.id))
        : ref.watch(noticeProvider(notificationId: widget.id));
    if (result is LoadingModel) {
      return const Dialog.fullscreen(
        child: TcPolicyDetailSkeleton(),
      );
    } else if (result is ErrorModel) {
      return const Dialog.fullscreen(
        child: Scaffold(
          body: Text('error'),
        ),
      );
    }

    DateTime date;
    String title = "";
    String content = "";
    if (widget.type == NoticeScreenType.push) {
      final model = (result as ResponseModel<PushNotificationResponse>).data!;
      date = DateTime.parse(model.createdAt);
      title = model.title;
      content = model.content;
    } else {
      final model = (result as ResponseModel<NotificationResponse>).data!;
      date = DateTime.parse(model.createdAt);
      title = model.title;
      content = model.content;
    }

    final createAt = DateFormat('yyyy년 MM월 dd일', "ko").format(date);
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: const DefaultAppBar(
          hasBorder: false,
          leadingIcon: "remove",
        ),
        body: Padding(
          padding:
              EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: MITITextStyle.xl150.copyWith(
                  color: V2MITIColor.white,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                createAt,
                style:
                    MITITextStyle.xxsmLight.copyWith(color: MITIColor.gray300),
              ),
              SizedBox(height: 48.h),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: HtmlComponent(content: content),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              TextButton(
                  onPressed: () => context.pop(), child: const Text("닫기")),
            ],
          ),
        ),
      ),
    );
  }
}
