import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/default_model.dart';
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
}
