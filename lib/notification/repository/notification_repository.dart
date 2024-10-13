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
  final dio = ref.watch(dioProvider);
  return NoticePRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class NoticePRepository
    extends IBasePaginationRepository<NoticeModel, NotificationParam> {
  factory NoticePRepository(Dio dio) = _NoticePRepository;

  @override
  @GET('/notifications')
  Future<ResponseModel<PaginationModel<NoticeModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() NotificationParam? param,
    @Path('userId') int? path,
  });

  @GET('/notifications/{notificationId}')
  Future<ResponseModel<NoticeDetailModel>> get({
    @Path() required int notificationId,
  });
}

final pushPRepositoryProvider = Provider<PushPRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return PushPRepository(dio);
});

@RestApi(baseUrl: serverURL)
abstract class PushPRepository
    extends IBasePaginationRepository<PushModel, NotificationParam> {
  factory PushPRepository(Dio dio) = _PushPRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications')
  Future<ResponseModel<PaginationModel<PushModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() NotificationParam? param,
    @Path('userId') int? path,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications/setting')
  Future<ResponseModel<PushAllowModel>> getSetting({
    @Path() required int userId,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/push-notifications/{pushId}')
  Future<ResponseModel<PushDetailModel>> get({
    @Path() required int userId,
    @Path() required int pushId,
  });

  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/push-notifications/setting/on')
  Future<ResponseModel<PushAllowModel>> allowPush({
    @Path() required int userId,
    @Queries() required PushSettingParam? topic,
  });

  @Headers({'token': 'true'})
  @PATCH('/users/{userId}/push-notifications/setting/off')
  Future<ResponseModel<PushAllowModel>> disallowPush({
    @Path() required int userId,
    @Queries() required PushSettingParam? topic,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/unread-push-notifications')
  Future<ResponseModel<UnreadPushModel>> unreadPush({
    @Path() required int userId,
  });
}
