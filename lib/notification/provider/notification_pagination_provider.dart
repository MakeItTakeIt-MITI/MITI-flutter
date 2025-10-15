import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/notification/provider/notification_provider.dart';
import 'package:miti/notification/repository/notification_repository.dart';

import '../../common/param/pagination_param.dart';
import '../../common/provider/cursor_pagination_provider.dart';
import '../../game/model/v2/notification/base_notification_response.dart';
import '../../game/model/v2/notification/base_push_notification_response.dart';
import '../param/notification_param.dart';

final noticePProvider = StateNotifierProvider.family.autoDispose<
    NoticePageStateNotifier,
    BaseModel,
    PaginationStateParam<NotificationParam>>((ref, param) {
  final repository = ref.watch(noticePRepositoryProvider);
  return NoticePageStateNotifier(
    repository: repository,
    cursorPageParams: const CursorPaginationParam(),
    param: param.param,
    path: param.path,
  );
});

class NoticePageStateNotifier extends CursorPaginationProvider<
    BaseNotificationResponse, NotificationParam, NoticePRepository> {
  NoticePageStateNotifier({
    required super.repository,
    required super.cursorPageParams,
    super.param,
    super.path,
  });
}

final pushPProvider = StateNotifierProvider.family.autoDispose<
    PushPageStateNotifier,
    BaseModel,
    PaginationStateParam<NotificationParam>>((ref, param) {
  final repository = ref.watch(pushPRepositoryProvider);
  return PushPageStateNotifier(
    repository: repository,
    cursorPageParams: const CursorPaginationParam(),
    param: param.param,
    path: param.path,
  );
});

class PushPageStateNotifier extends CursorPaginationProvider<
    BasePushNotificationResponse, NotificationParam, PushPRepository> {
  PushPageStateNotifier({
    required super.repository,
    required super.cursorPageParams,
    super.param,
    super.path,
  });

  /// optimistic response
  void read({required int pushId, required WidgetRef ref}) {
    final model =
        (state as ResponseModel<PaginationModel<BasePushNotificationResponse>>);
    final pState = model.data!;
    bool hasUnConfirmed = false;
    final newPageContent = pState.page_content.map((e) {
      if (e.id == pushId) {
        return e.copyWith(isRead: true);
      }
      // 확인 안 한 푸시 알림이 있을 경우 true
      if (!e.isRead) {
        hasUnConfirmed = !e.isRead;
      }
      return e;
    }).toList();
    ref.read(unreadPushProvider.notifier).get();

    final newData = pState.copyWith(page_content: newPageContent);
    state = model.copyWith(data: newData);
  }

  void allRead({required WidgetRef ref}) {
    final model =
        (state as ResponseModel<PaginationModel<BasePushNotificationResponse>>);
    final pState = model.data!;
    final newPageContent = pState.page_content.map((e) {
      return e.copyWith(isRead: true);
    }).toList();
    ref.read(unreadPushProvider.notifier).get();

    final newData = pState.copyWith(page_content: newPageContent);
    state = model.copyWith(data: newData);
  }
}
