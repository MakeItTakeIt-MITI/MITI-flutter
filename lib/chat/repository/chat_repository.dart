import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/param/cursor_pagination_param.dart';
import '../../common/param/pagination_param.dart';
import '../../dio/provider/dio_provider.dart';
import '../../notification/model/base_game_chat_notification_response.dart';
import '../../notification/model/game_chat_notification_response.dart';
import '../model/base_game_chat_message_response.dart';
import '../model/game_chat_member_response.dart';
import '../model/game_chat_room_approved_users_response.dart';
import '../param/chat_notice_param.dart';

part 'chat_repository.g.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return ChatRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class ChatRepository {
  factory ChatRepository(Dio dio, {String baseUrl}) = _ChatRepository;

  /// 경기 채팅방 접근 승인 유저 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/chat-room/approved-users')
  Future<ResponseModel<GameChatRoomApprovedUsersResponse>> getChatApproveInfo({
    @Path('gameId') required int gameId,
  });

  /// 경기 채팅 참가자 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/chat-room/members')
  Future<ResponseModel<GameChatMemberResponse>> getChatMembers({
    @Path('gameId') required int gameId,
  });

  // todo 채팅 메세지 페이지네이션 구현
  /// 경기 채팅 메세지 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/chat-room/messages')
  Future<ResponseModel<CursorPaginationModel<BaseGameChatMessageResponse>>>
      getChatMessages({
    @Path('gameId') required int gameId,
    @Queries() required CursorPaginationParam cursorParams,
  });

  // todo 채팅 메세지 페이지네이션 구현
  /// 경기 채팅 메세지 작성 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/chat-room/messages')
  Future<ResponseModel<CursorPaginationModel<BaseGameChatMessageResponse>>>
      postChatMessage({
    @Path('gameId') required int gameId,
    @Field("body") required String body,
    @Field("cursor") int? cursor,
  });

  /// 경기 채팅 공지사항 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/chat-room/notifications')
  Future<ResponseListModel<BaseGameChatNotificationResponse>>
      getGameChatNotifications({
    @Path('gameId') required int gameId,
  });

  /// 경기 채팅 공지사항 생성 API
  @Headers({'token': 'true'})
  @POST('/games/{gameId}/chat-room/notifications')
  Future<ResponseModel<BaseGameChatNotificationResponse>>
      postChatNotifications({
    @Path('gameId') required int gameId,
    @Body() required ChatNoticeParam param,
  });

  /// 경기 채팅 공지사항 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/games/{gameId}/chat-room/notifications/{notificationId}')
  Future<ResponseModel<GameChatNotificationResponse>>
      getChatNotificationDetail({
    @Path('gameId') required int gameId,
    @Path('notificationId') required int notificationId,
  });

  /// 경기 채팅 공지사항 삭제 API
  @Headers({'token': 'true'})
  @DELETE('/games/{gameId}/chat-room/notifications/{notificationId}')
  Future<ResponseModel<GameChatNotificationResponse?>> deleteChatNotification({
    @Path('gameId') required int gameId,
    @Path('notificationId') required int notificationId,
  });

  /// 경기 채팅 공지사항 수정 API
  @Headers({'token': 'true'})
  @PUT('/games/{gameId}/chat-room/notifications/{notificationId}')
  Future<ResponseModel<GameChatNotificationResponse?>> putChatNotification({
    @Path('gameId') required int gameId,
    @Path('notificationId') required int notificationId,
    @Body() required ChatNoticeParam param,
  });

  /// 작성 경기 채팅 공지사항 목록 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/game-chat-notifications')
  Future<ResponseModel<PaginationModel<GameChatNotificationResponse>>>
      getUserChatNotifications({
    @Path('userId') required int userId,
    @Queries() required PaginationParam paginationParam,
  });
}
