import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../model/push_model.dart';

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

@Riverpod(keepAlive: false)
class PushSetting extends _$PushSetting {
  @override
  BaseModel build({required int notificationId}) {
    return LoadingModel();
  }

  Future<void> get({required int notificationId}) async {
    state = LoadingModel();
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
}

@riverpod
Future<BaseModel> pushStatusUpdate(PushStatusUpdateRef ref,
    {required bool isOn, required PushAllowModel push}) async {
  final repository = ref.watch(pushPRepositoryProvider);
  final userId = ref.read(authProvider)!.id!;
  if (isOn) {
    return await repository
        .allowPush(topic: push, userId: userId)
        .then<BaseModel>((value) {
      logger.i(value);

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
      return value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      return error;
    });
  }
}
