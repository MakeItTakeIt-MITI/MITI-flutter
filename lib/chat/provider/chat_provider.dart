import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/chat/repository/chat_repository.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

import '../../common/logger/custom_logger.dart';
import '../model/chat_ui_model.dart';

part 'chat_provider.g.dart';

@Riverpod()
class ChatPagination extends _$ChatPagination {
  @override
  BaseModel build({required int gameId}) {
    getChatPagination(gameId: gameId);
    return LoadingModel();
  }

  Future<void> getChatPagination(
      {required int gameId,
      PaginationParam paginationParam = const PaginationParam(page: 1)}) async {
    // if (state is DateChatModel) {
    //   final chats = state as DateChatModel;
    //   chats.chatsByDate;
    // }
    state = LoadingModel();
    final repository = ref.watch(chatRepositoryProvider);
    final currentUserId = ref.read(authProvider)?.id ?? -1; // 현재 사용자 ID 가져오기

    repository
        .getChatMessages(gameId: gameId, paginationParams: paginationParam)
        .then((value) {
      final response = value.data!.page_content;

      // 날짜별로 메시지 그룹화
      Map<String, Map<int, List<ChatModel>>> chatsByDateAndUser = {};

      for (var chatResponse in response) {
        // 날짜 포맷 (YYYY-MM-DD)
        final dateStr = DateFormat('yyyy-MM-dd').format(chatResponse.createdAt);

        // 시간 포맷 (HH:MM)
        final timeStr = DateFormat('HH:mm').format(chatResponse.createdAt);

        // 날짜별 맵이 없으면 생성
        if (!chatsByDateAndUser.containsKey(dateStr)) {
          chatsByDateAndUser[dateStr] = {};
        }

        // 사용자별 리스트가 없으면 생성
        final userId = chatResponse.user.id ?? 0;
        if (!chatsByDateAndUser[dateStr]!.containsKey(userId)) {
          chatsByDateAndUser[dateStr]![userId] = [];
        }

        // ChatModel 생성 및 추가
        final chatModel = ChatModel(
          chatId: chatResponse.id,
          time: timeStr,
          message: chatResponse.body,
        );

        chatsByDateAndUser[dateStr]![userId]!.add(chatModel);
      }

      // DateChatModel 구성
      Map<String, List<UserChatModel>> finalChatsByDate = {};

      // 날짜 정렬 (최신순)
      final sortedDates = SplayTreeMap<String, Map<int, List<ChatModel>>>.from(
          chatsByDateAndUser, (a, b) => b.compareTo(a) // 내림차순 (최신순)
          );

      for (var dateEntry in sortedDates.entries) {
        final date = dateEntry.key;
        final userChats = dateEntry.value;

        List<UserChatModel> userChatModels = [];

        for (var userEntry in userChats.entries) {
          final userId = userEntry.key;
          final chats = userEntry.value;

          // 첫 메시지에서 사용자 정보 가져오기 (응답에 포함된 사용자 정보)
          final userInfo =
              response.firstWhere((msg) => msg.user.id == userId).user;

          // UserChatModel 생성
          final userChatModel = UserChatModel(
            userId: userId,
            isMine: userId == currentUserId,
            nickname: userInfo.nickname,
            imageUrl: userInfo.profileImageUrl ?? '',
            // 프로필 이미지가 null일 경우 빈 문자열 사용
            chats: chats,
          );

          userChatModels.add(userChatModel);
        }

        finalChatsByDate[date] = userChatModels;
      }

      // 기존 상태가 DateChatModel이면 기존 채팅과 병합
      if (state is DateChatModel) {
        final existingModel = state as DateChatModel;
        final existingChats = existingModel.chatsByDate;

        // 기존 채팅에 새 채팅 추가 (날짜별로)
        for (var entry in finalChatsByDate.entries) {
          final date = entry.key;
          final newUserChats = entry.value;

          if (existingChats.containsKey(date)) {
            // 기존 날짜에 새 채팅 추가
            // 각 사용자별로 체크하여 기존 사용자의 채팅은 병합
            for (var newUserChat in newUserChats) {
              existingChats[date]!.add(newUserChat);
            }
          } else {
            // 새 날짜면 추가
            existingChats[date] = newUserChats;
          }
        }

        state = DateChatModel(
            endIndex: value.data!.end_index,
            currentIndex: value.data!.current_index,
            chatsByDate: existingChats);
      } else {
        // 처음 로드하는 경우 새로 생성
        state = DateChatModel(
            endIndex: value.data!.end_index,
            currentIndex: value.data!.current_index,
            chatsByDate: finalChatsByDate);
      }
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
    ;
  }
}
