import 'dart:developer';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/notification/param/push_setting_param.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/secure_storage_provider.dart';
import '../model/push_model.dart';
import '../model/unread_push_model.dart';
import 'notification_pagination_provider.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: false)
class Notice extends _$Notice {
  @override
  BaseModel build({required int notificationId}) {
    get(notificationId: notificationId);
    return LoadingModel();
  }

  Future<void> get({required int notificationId}) async {
    state = LoadingModel();
    final repository = ref.watch(noticePRepositoryProvider);
    repository.get(notificationId: notificationId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@Riverpod(keepAlive: true)
class Push extends _$Push {
  @override
  BaseModel build({required int pushId}) {
    get(pushId: pushId);
    return LoadingModel();
  }

  Future<void> get({required int pushId}) async {
    final repository = ref.watch(pushPRepositoryProvider);
    final userId = ref.read(authProvider)!.id!;
    repository.get(userId: userId, pushId: pushId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

// void update({required PushAllowModel model}) {
//   final uState = (state as ResponseModel<PushAllowModel>);
//   state = ResponseModel(
//       status_code: uState.status_code, message: uState.message, data: model);
// }
}

@Riverpod(keepAlive: true)
class PushSetting extends _$PushSetting {
  @override
  BaseModel build() {
    get();
    return LoadingModel();
  }

  Future<void> get() async {
    final repository = ref.watch(pushPRepositoryProvider);
    final userId = ref.read(authProvider)!.id!;
    repository.getSetting(userId: userId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  void update({required PushAllowModel model}) {
    final uState = (state as ResponseModel<PushAllowModel>);
    state = ResponseModel(
        status_code: uState.status_code, message: uState.message, data: model);
  }
}

PushAllowModel optimisticSetting(
    {required PushAllowModel model,
    required bool isOn,
    PushNotificationTopicType? topic}) {
  List<PushNotificationTopicType> topics = model.allowedTopic;
  if (isOn) {
    if (topic == null) {
      topics =
          PushNotificationTopicType.values.where((p) => p.canSetting).toList();
    } else {
      topics.add(topic);
    }
  } else {
    if (topic == null) {
      topics = [];
    } else {
      topics.remove(topic);
    }
  }
  return PushAllowModel(allowedTopic: topics);
}

@riverpod
Future<BaseModel> pushStatusUpdate(PushStatusUpdateRef ref,
    {required bool isOn, PushSettingParam? push}) async {
  final baseModel = ref.read(pushSettingProvider);
  final model = (baseModel as ResponseModel<PushAllowModel>).data!;

  final repository = ref.watch(pushPRepositoryProvider);
  final userId = ref.read(authProvider)!.id!;

  if (isOn) {
    return await repository
        .allowPush(topic: push, userId: userId)
        .then<BaseModel>((value) {
      logger.i(value);
      // ref.read(pushSettingProvider.notifier).get();
      return value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      return error;
    });
  } else {
    return await repository
        .disallowPush(topic: push, userId: userId)
        .then<BaseModel>((value) {
      logger.i(value);
      // ref.read(pushSettingProvider.notifier).get();
      return value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      return error;
    });
  }
}

@Riverpod(keepAlive: false)
class UnreadPush extends _$UnreadPush {
  @override
  BaseModel build() {
    get();
    return LoadingModel();
  }

  Future<void> get() async {
    final repository = ref.watch(pushPRepositoryProvider);
    final userId = ref.read(authProvider)!.id!;
    final secureProvider = ref.read(secureStorageProvider);

    repository.unreadPush(userId: userId).then((value) {
      logger.i(value);
      AppBadgePlus.isSupported().then((isAllow) {
        if (isAllow) {
          int cnt = value.data!.pushCnt;
          if (cnt > 999) {
            cnt = 999;
          }
          AppBadgePlus.updateBadge(cnt);
          secureProvider.write(key: 'pushCnt', value: cnt.toString());
        }
      });
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  void allRead() {
    final newState = state as ResponseModel<UnreadPushModel>;
    state = newState.copyWith(data: newState.data!.copyWith(pushCnt: 0));
    final secureProvider = ref.read(secureStorageProvider);
    AppBadgePlus.isSupported().then((isAllow) {
      if (isAllow) {
        secureProvider.write(key: 'pushCnt', value: '0');
        AppBadgePlus.updateBadge(0);
      }
    });
  }
}

@riverpod
Future<BaseModel> allReadPush(AllReadPushRef ref) async {
  final repository = ref.watch(pushPRepositoryProvider);
  final userId = ref.read(authProvider)!.id!;
  return await repository.allReadPush(userId: userId).then<BaseModel>((value) {
    logger.i(value);
    ref.read(unreadPushProvider.notifier).allRead();

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
