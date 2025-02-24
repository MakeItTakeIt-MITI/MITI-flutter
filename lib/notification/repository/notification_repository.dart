import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/dio/provider/dio_provider.dart';
import 'package:miti/notification/model/notice_model.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart' hide Headers;

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
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
abstract class NoticePRepository
    extends IBasePaginationRepository<NoticeModel, NotificationParam> {
  factory NoticePRepository(Dio dio, {String baseUrl}) = _NoticePRepository;

  /// 공지사항 목록 조회 API
  @override
  @GET('/notifications')
  Future<ResponseModel<PaginationModel<NoticeModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() NotificationParam? param,
    @Path('userId') int? path,
  });

  /// 공지사항 상세 조회 API
  @GET('/notifications/{notificationId}')
  Future<ResponseModel<NoticeDetailModel>> get({
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
abstract class PushPRepository
    extends IBasePaginationRepository<PushModel, NotificationParam> {
  factory PushPRepository(Dio dio, {String baseUrl}) = _PushPRepository;

  /// 푸시 알림 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications')
  Future<ResponseModel<PaginationModel<PushModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() NotificationParam? param,
    @Path('userId') int? path,
  });

  /// 푸시 알림 설정 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications/setting')
  Future<ResponseModel<PushAllowModel>> getSetting({
    @Path() required int userId,
  });

  /// 푸시 알림 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications/{pushId}')
  Future<ResponseModel<PushDetailModel>> get({
    @Path() required int userId,
    @Path() required int pushId,
  });

  /// 푸시 알림 허용 API
  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/push-notifications/setting/on')
  Future<ResponseModel<PushAllowModel>> allowPush({
    @Path() required int userId,
    @Queries() required PushSettingParam? topic,
  });

  /// 푸시 알림 거부 API
  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/push-notifications/setting/off')
  Future<ResponseModel<PushAllowModel>> disallowPush({
    @Path() required int userId,
    @Queries() required PushSettingParam? topic,
  });

  /// 미확인 푸시 알림 정보 확인 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/unread-push-notifications')
  Future<ResponseModel<UnreadPushModel>> unreadPush({
    @Path() required int userId,
  });

  @Headers({'token': 'true'})
  @PUT('/users/{userId}/push-notifications')
  Future<ResponseModel<PaginationModel<PushModel>>> allReadPush({
    @Path() required int userId,
  });
}
