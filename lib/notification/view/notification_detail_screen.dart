import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/notification/model/notice_model.dart';
import 'package:miti/notification/provider/notification_provider.dart';
import 'package:miti/notification_provider.dart';

import '../../common/component/default_appbar.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final int notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(noticeProvider(notificationId: notificationId));
    if (result is LoadingModel) {
      return const Dialog.fullscreen(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    } else if (result is ErrorModel) {
      return const Dialog.fullscreen(
        child: Scaffold(
          body: Text('error'),
        ),
      );
    }

    final model = (result as ResponseModel<NoticeDetailModel>).data!;
    final date = DateTime.parse(model.createdAt);
    final createAt = DateFormat('yyyy년 MM월 dd일', "ko").format(date);
    return Dialog.fullscreen(
      backgroundColor: MITIColor.gray800,
      child: Scaffold(
        backgroundColor: MITIColor.gray800,
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
                model.title,
                style: MITITextStyle.xl150.copyWith(
                  color: MITIColor.white,
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
                    child: Text(
                      model.content,
                      style: MITITextStyle.sm150.copyWith(
                        color: MITIColor.gray300,
                      ),
                    ),
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
