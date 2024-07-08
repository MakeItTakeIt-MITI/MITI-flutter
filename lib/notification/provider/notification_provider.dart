import 'package:miti/common/model/default_model.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:miti/notification_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../param/notification_param.dart';

part 'notification_provider.g.dart';

// @Riverpod()
// class TestNotification extends _$TestNotification {
//   @override
//   BaseModel build() {
//     return LoadingModel();
//   }
//
//   void testNotification() {
//     final repository = ref.read(notificationRepositoryProvider);
//     repository.testNotification(fcm_token: fcmToken!);
//   }
// }
@riverpod
Future<BaseModel> testNotification(
  TestNotificationRef ref,
) async {
  final fcmToken = ref.read(fcmTokenProvider);
  final param = NotificationParam(fcmToken: fcmToken ?? '');
  return await ref
      .watch(notificationRepositoryProvider)
      .testNotification(param: param)
      .then<BaseModel>((value) async {
    // logger.i('oauthLogin $param!');
    return LoadingModel();
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
