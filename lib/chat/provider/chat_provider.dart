import 'dart:developer';
import 'dart:math' hide log;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:miti/account/view/bank_transfer_form_screen.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/chat/repository/chat_repository.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/util/util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../common/logger/custom_logger.dart';
import '../../common/param/cursor_pagination_param.dart';
import '../../user/model/v2/base_user_response.dart';
import '../model/base_game_chat_message_response.dart';
import '../model/chat_ui_model.dart';

part 'chat_provider.g.dart';

@Riverpod()
class ChatPagination extends _$ChatPagination {
  late final CursorPaginationParam cursorParams;

  @override
  BaseModel build({required int gameId}) {
    cursorParams = const CursorPaginationParam();
    getChatPagination(gameId: gameId);
    return LoadingModel();
  }

  Future<BaseModel> sendMessage({required String message}) async {
    return LoadingModel();

    // final repository = ref.watch(chatRepositoryProvider);
    // return repository
    //     .postChatMessage(gameId: gameId, body: message)
    //     .then<BaseModel>((e) {
    //   final pState = (state as ResponseModel<CursorPaginationModel<ChatModel>>).data!;
    //   final now = DateTime.now();
    //   final date = DateTimeUtil.formatDate(now);
    //   final time = DateTimeUtil.formatTime(now);
    //   final user = ref.read(authProvider);
    //   final isFirstMessage = pState.page_content.isEmpty;
    //   final lastIdx = pState.page_content.length - 1;
    //
    //   // pState.page_content.add(
    //   //   ChatModel(
    //   //     id: ,
    //   //     message: message,
    //   //     date: date,
    //   //     time: time,
    //   //     user: BaseUserResponse(
    //   //         nickname: user?.nickname ?? '익명',
    //   //         profileImageUrl: "",
    //   //         id: user?.id),
    //   //     isMine: true,
    //   //     showTime: true,
    //   //     showDate: true,
    //   //     isLastMessage: pState.page_content.isEmpty,
    //   //     showUserInfo: true,
    //   //   ),
    //   // );
    //   if (!isFirstMessage) {
    //     // [기존 채팅 마지막, 새 채팅]
    //     // 채팅이 최소 2개까지 subList 생성
    //     log("=================================");
    //     for (final m in pState.page_content) {
    //       log("message = ${m.message} date = ${m.date} time = ${m.time} ");
    //     }
    //     log("=================================");
    //
    //     log("lastIdx  = ${lastIdx}");
    //     final subList =
    //         pState.page_content.sublist(max(lastIdx - 1, 0), lastIdx + 2);
    //
    //     log("subList length  = ${subList.length}");
    //
    //     final existLastChat = pState.page_content[lastIdx].copyWith(
    //       showDate: subList.shouldShowDateAt(subList.length - 2),
    //       showTime: subList.shouldShowTimeAt(subList.length - 2),
    //       showUserInfo: subList.shouldShowUserInfoAt(subList.length - 2),
    //     );
    //
    //     final newChat = pState.page_content[lastIdx + 1].copyWith(
    //       showDate: subList.shouldShowDateAt(subList.length - 1),
    //       showTime: subList.shouldShowTimeAt(subList.length - 1),
    //       showUserInfo: subList.shouldShowUserInfoAt(subList.length - 1),
    //     );
    //
    //     pState.page_content
    //         .replaceRange(lastIdx, lastIdx + 2, [existLastChat, newChat]);
    //   }
    //
    //   state = ResponseModel(
    //       status_code: 200,
    //       message: "message",
    //       data: pState.copyWith(page_content: pState.page_content));
    //
    //   return CompletedModel(status_code: 0, message: message, data: null);
    // }).catchError((e) {
    //   final error = ErrorModel.respToError(e);
    //   logger.e(
    //       'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    //   return error;
    //   // state = error;
    // });
  }

  Future<void> getChatPagination({
    required int gameId,
    CursorPaginationParam cursorParam = const CursorPaginationParam(),
    fetchMore = false,
  }) async {
    // if (state is DateChatModel) {
    //   final chats = state as DateChatModel;
    //   chats.chatsByDate;
    // }
    // state = LoadingModel();
    final repository = ref.watch(chatRepositoryProvider);
    final currentUserId = ref.read(authProvider)?.id ?? -1; // 현재 사용자 ID 가져오기

    if (fetchMore) {
      final pState =
          (state as ResponseModel<CursorPaginationModel<ChatModel>>).data!;
      if (pState.earliestCursor == null) {
        return;
      }

      // 현재 가장 오래된 커서 위치 이전부터 이전 방향으로 조회
      cursorParam = cursorParam.copyWith(
        cursor: pState.earliestCursor,
        direction: Direction.prev,
      );
    }

    repository
        .getChatMessages(gameId: gameId, cursorParams: cursorParam)
        .then((value) {
      final response = value.data!;
      final content = value.data!.messages.toList();
      final newChatMessages = value.data!.messages.mapIndexed((idx, e) {
        final isMine = e.user.id == currentUserId;

        // todo 마지막 페이지인지 확인하는 로직 변경
        final lastPage = value.data!.earliestCursor == null;
        final isLastMessage = lastPage && value.data!.earliestCursor == null;

        final bool showDate = shouldShowDate(content, idx);
        final bool showTime = shouldShowTime(content, idx);
        final bool showUserInfo = shouldShowUserInfo(content, idx);

        return ChatModel.fromResponse(
          response: e,
          isMine: isMine,
          showTime: showTime,
          showDate: showDate,
          isLastMessage: isLastMessage,
          showUserInfo: showUserInfo,
        );
      }).toList();

      if (fetchMore) {
        final pState = state as ResponseModel<CursorPaginationModel<ChatModel>>;
        final lastIdx = newChatMessages.length - 1;

        newChatMessages.insertAll(
            newChatMessages.length, pState.data!.messages);

        // [새 채팅 마지막 이전, 새 채팅 마지막, 기존 채팅 처음, 기존 채팅 두번째,]

        // 채팅이 최소 2개까지 subList 생성
        final minExistChatSize = min(pState.data!.messages.length, 2);

        final subList = newChatMessages.sublist(
            max(lastIdx - 1, 0), lastIdx + 1 + minExistChatSize);

        final newLastChat = newChatMessages[lastIdx].copyWith(
          showDate: subList.shouldShowDateAt(1),
          showTime: subList.shouldShowTimeAt(1),
          showUserInfo: subList.shouldShowUserInfoAt(1),
        );
        final existFirstChat = newChatMessages[lastIdx + 1].copyWith(
          showDate: subList.shouldShowDateAt(2),
          showTime: subList.shouldShowTimeAt(2),
          showUserInfo: subList.shouldShowUserInfoAt(2),
        );

        newChatMessages
            .replaceRange(lastIdx, lastIdx + 2, [newLastChat, existFirstChat]);

        state = ResponseModel(
          status_code: pState.status_code,
          message: pState.message,
          data: pState.data!.copyWith(
            earliestCursor: newChatMessages[0].id,
            messages: [
              ...newChatMessages,
            ],
          ),
        );
      } else {
        // 처음 불러오기
        state = ResponseModel(
          status_code: value.status_code,
          message: value.message,
          data: CursorPaginationModel(
              earliestCursor: response.earliestCursor,
              latestCursor: response.latestCursor,
              messages: newChatMessages),
        );
      }
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  bool shouldShowDate(
      List<BaseGameChatMessageResponse> messages, int currentIndex) {
    if (messages.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= messages.length) {
      return false;
    }
    // 마지막은 무조건 보이도록
    if (currentIndex == 0) {
      return true;
    }
    final currentMessage = messages[currentIndex];

    final prevMessage = messages[currentIndex - 1];
    return !DateTimeUtil.isSameDay(
        currentMessage.createdAt, prevMessage.createdAt);
  }

  bool shouldShowUserInfo(
      List<BaseGameChatMessageResponse> messages, int currentIndex) {
    if (messages.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= messages.length) {
      return false;
    }
    // 처음은 무조건 보이도록
    if (currentIndex == 0) {
      return true;
    }
    final currentMessage = messages[currentIndex];
    final prevMessage = messages[currentIndex - 1];
    return currentMessage.user.id != prevMessage.user.id;
  }

  /// DateTimeUtil.isSameTime을 사용한 정확한 시간 표시 로직
  bool shouldShowTime(
      List<BaseGameChatMessageResponse> messages, int currentIndex) {
    if (messages.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= messages.length) {
      return false;
    }

    final currentMessage = messages[currentIndex];

    // 1. 마지막 메시지는 항상 시간 표시
    if (currentIndex == messages.length - 1) {
      return true;
    }

    if (currentIndex == 0) {
      final nextMessage = messages[currentIndex + 1];
      // 2. 다음 메시지의 사용자가 다른 경우 (현재 사용자의 마지막 연속 메시지)
      if (currentMessage.user.id != nextMessage.user.id) {
        return true;
      }
      // 3. 같은 사용자지만 이전 메세지 시간(시:분)이 같은 경우
      if (DateTimeUtil.isSameTime(
          nextMessage.createdAt, currentMessage.createdAt)) {
        return false;
      }
      return true;
    }

    final nextMessage = messages[currentIndex + 1];
    final prevMessage = messages[currentIndex - 1];
    // log("====================================");
    // for(final m in messages){
    //   log("id = ${m.user.id} date = ${m.createdAt}\n");
    // }
    // log("====================================");
    // 2. 다음 메시지의 사용자가 다른 경우 (현재 사용자의 마지막 연속 메시지)
    if (currentMessage.user.id != nextMessage.user.id) {
      return true;
    }

    // 3. 같은 사용자지만 이전 메세지 시간(시:분)이 같은 경우
    if (DateTimeUtil.isSameTime(
        nextMessage.createdAt, currentMessage.createdAt)) {
      return false;
    }

    // 4. 같은 사용자지만 시간(시:분)이 다른 경우
    if (!DateTimeUtil.isSameTime(
        currentMessage.createdAt, prevMessage.createdAt)) {
      return true;
    }

    // 4. 날짜가 다른 경우
    if (!DateTimeUtil.isSameDay(
        currentMessage.createdAt, prevMessage.createdAt)) {
      return true;
    }

    return true;
  }
}
