import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/dio/provider/dio_provider.dart';
import 'package:retrofit/http.dart';
import 'package:dio/dio.dart' hide Headers;

import '../../dio/dio_interceptor.dart';
import '../param/notification_param.dart';

part 'notification_repository.g.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final repository = NotificationRepository(dio);
  return repository;
});

@RestApi(baseUrl: serverURL)
abstract class NotificationRepository {
  factory NotificationRepository(Dio dio) = _NotificationRepository;

  @POST('/notifications/send-test-notification')
  Future<void> testNotification({@Body() required NotificationParam param});
}
