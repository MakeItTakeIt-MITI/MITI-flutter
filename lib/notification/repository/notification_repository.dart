import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/dio/provider/dio_provider.dart';
import 'package:miti/notification/model/notice_model.dart';
import 'package:retrofit/http.dart';

import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../game/model/v2/notification/base_notification_response.dart';
import '../../game/model/v2/notification/base_push_notification_response.dart';
import '../../game/model/v2/notification/notification_response.dart';
import '../../game/model/v2/notification/push_notification_response.dart';
import '../../game/model/v2/notification/push_notification_setting_response.dart';
import '../../user/param/user_profile_param.dart';
import '../model/push_model.dart';
import '../model/unread_push_model.dart';
import '../param/notification_param.dart';
import '../param/push_setting_param.dart';

part 'notification_repository.g.dart';

final noticePRepositoryProvider = Provider<NoticePRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return NoticePRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class NoticePRepository extends IBaseCursorPaginationRepository<
    BaseNotificationResponse, NotificationParam> {
  factory NoticePRepository(Dio dio, {String baseUrl}) = _NoticePRepository;

  /// 공지사항 목록 조회 API
  @override
  @GET('/notifications')
  Future<ResponseModel<CursorPaginationModel<BaseNotificationResponse>>> paginate({
    @Queries() required CursorPaginationParam cursorPaginationParams,
    @Queries() NotificationParam? param,
    @Path('userId') int? path,
  });

  /// 공지사항 상세 조회 API
  @GET('/notifications/{notificationId}')
  Future<ResponseModel<NotificationResponse>> get({
    @Path() required int notificationId,
  });
}

final pushPRepositoryProvider = Provider<PushPRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return PushPRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class PushPRepository extends IBaseCursorPaginationRepository<
    BasePushNotificationResponse, NotificationParam> {
  factory PushPRepository(Dio dio, {String baseUrl}) = _PushPRepository;

  /// 푸시 알림 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications')
  Future<ResponseModel<CursorPaginationModel<BasePushNotificationResponse>>>
      paginate({
    @Queries() required CursorPaginationParam cursorPaginationParams,
    @Queries() NotificationParam? param,
    @Path('userId') int? path,
  });

  /// 푸시 알림 설정 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications/setting')
  Future<ResponseModel<PushNotificationSettingResponse>> getSetting({
    @Path() required int userId,
  });

  /// 푸시 알림 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications/{pushId}')
  Future<ResponseModel<PushNotificationResponse>> get({
    @Path() required int userId,
    @Path() required int pushId,
  });

  /// 푸시 알림 허용 API
  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/push-notifications/setting/on')
  Future<ResponseModel<PushNotificationSettingResponse>> allowPush({
    @Path() required int userId,
    @Queries() required PushSettingParam? topic,
  });

  /// 푸시 알림 거부 API
  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/push-notifications/setting/off')
  Future<ResponseModel<PushNotificationSettingResponse>> disallowPush({
    @Path() required int userId,
    @Queries() required PushSettingParam? topic,
  });

  /// 미확인 푸시 알림 정보 확인 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/unread-push-notifications')
  Future<ResponseModel<UnreadPushModel>> unreadPush({
    @Path() required int userId,
  });

  /// 푸시 알림 전체 읽음 처리 API
  @Headers({'token': 'true'})
  @PUT('/users/{userId}/push-notifications')
  Future<ResponseModel<CursorPaginationModel<BasePushNotificationResponse>>>
      allReadPush({
    @Path() required int userId,
  });
}
