import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/chat/param/chat_notice_param.dart';
import 'package:miti/chat/provider/chat_form_provider.dart';
import 'package:miti/chat/repository/chat_repository.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/notification/provider/notification_provider.dart';
import 'package:miti/notification/repository/notification_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'chat_notice_provider.g.dart';

@Riverpod(keepAlive: false)
class ChatNotice extends _$ChatNotice {
  @override
  BaseModel build({required int gameId}) {
    get(gameId: gameId);
    return LoadingModel();
  }

  Future<void> get({required int gameId}) async {
    final repository = ref.watch(chatRepositoryProvider);
    repository.getGameChatNotifications(gameId: gameId).then((value) {
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
class ChatNoticeDetail extends _$ChatNoticeDetail {
  @override
  BaseModel build({required int gameId, required int notificationId}) {
    get(gameId: gameId, notificationId: notificationId);
    return LoadingModel();
  }

  Future<void> get({required int gameId, required int notificationId}) async {
    final repository = ref.watch(chatRepositoryProvider);
    repository
        .getChatNotificationDetail(
            gameId: gameId, notificationId: notificationId)
        .then((value) {
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
Future<BaseModel> chatNoticeCreate(ChatNoticeCreateRef ref,
    {required int gameId}) async {
  final repository = ref.watch(chatRepositoryProvider);
  final form = ref.watch(chatFormProvider(gameId: gameId));
  final param = ChatNoticeParam(title: form.title, body: form.body);

  return await repository
      .postChatNotifications(param: param, gameId: gameId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(chatNoticeProvider(gameId: gameId).notifier).get(gameId: gameId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> chatNoticeUpdate(ChatNoticeUpdateRef ref,
    {required int gameId, required int notificationId}) async {
  final repository = ref.watch(chatRepositoryProvider);
  final form = ref
      .watch(chatFormProvider(gameId: gameId, notificationId: notificationId));
  final param = ChatNoticeParam(title: form.title, body: form.body);

  return await repository
      .putChatNotification(
          param: param, gameId: gameId, notificationId: notificationId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(chatNoticeProvider(gameId: gameId).notifier).get(gameId: gameId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> chatNoticeDelete(ChatNoticeDeleteRef ref,
    {required int gameId, required int notificationId}) async {
  final repository = ref.watch(chatRepositoryProvider);

  return await repository
      .deleteChatNotification(gameId: gameId, notificationId: notificationId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(chatNoticeProvider(gameId: gameId).notifier).get(gameId: gameId);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> userChatNotice(UserChatNoticeRef ref,
    {PaginationParam paginationParam = const PaginationParam(page: 1)}) async {

  final repository = ref.watch(chatRepositoryProvider);
  final userId = ref.read(authProvider)?.id ?? 0;
  return await repository
      .getUserChatNotifications(
          userId: userId, paginationParam: paginationParam)
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
