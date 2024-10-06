import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/notification/provider/notification_provider.dart';
import 'package:miti/notification/provider/widget/unconfirmed_provider.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:miti/notification_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../user/param/user_profile_param.dart';
import '../model/notice_model.dart';
import '../model/push_model.dart';
import '../param/notification_param.dart';

final noticePProvider = StateNotifierProvider.family.autoDispose<
    NoticePageStateNotifier,
    BaseModel,
    PaginationStateParam<NotificationParam>>((ref, param) {
  final repository = ref.watch(noticePRepositoryProvider);
  return NoticePageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class NoticePageStateNotifier extends PaginationProvider<NoticeModel,
    NotificationParam, NoticePRepository> {
  NoticePageStateNotifier({
    required super.repository,
    required super.pageParams,
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
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class PushPageStateNotifier
    extends PaginationProvider<PushModel, NotificationParam, PushPRepository> {
  PushPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });

  /// optimistic response
  void read({required int pushId, required WidgetRef ref}) {
    final model = (state as ResponseModel<PaginationModel<PushModel>>);
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
    ref.read(unconfirmedProvider.notifier).update((s) => hasUnConfirmed);
    final newData = pState.copyWith(page_content: newPageContent);
    state = model.copyWith(data: newData);
  }
}
