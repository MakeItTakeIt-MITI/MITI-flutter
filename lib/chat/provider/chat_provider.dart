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
import '../../common/model/cursor_model.dart';
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
    final repository = ref.watch(chatRepositoryProvider);
    int? cursor;
    if (state is ResponseModel<CursorPaginationModel<ChatModel>>) {
      // 기존 채팅 마지막 cursor
      cursor = (state as ResponseModel<CursorPaginationModel<ChatModel>>)
          .data!
          .lastCursor;
    }

    return repository
        .postChatMessage(gameId: gameId, body: message, cursor: cursor)
        .then<BaseModel>((value) {
      final response = value.data!;
      final content = value.data!.items.toList();

      final pState =
          (state as ResponseModel<CursorPaginationModel<ChatModel>>).data!;
      final isFirstMessage = pState.items.isEmpty;
      final lastIdx = pState.items.length - 1;
      final currentUserId = ref.read(authProvider)?.id ?? -1; // 현재 사용자 ID 가져오기

      final newChatMessages = value.data!.items.mapIndexed((idx, e) {
        final isMine = e.user.id == currentUserId;

        // 첫 커서와 현재 맨 앞 커서가 일치하면 맨 앞 페이지
        final lastPage = value.data!.firstCursor == value.data!.earliestCursor;
        // 메세지 커서와 첫 커서가 일치할 경우 맨 처음 메시지
        final isFirstMessage = lastPage &&
            value.data!.items[idx].id == value.data!.earliestCursor;

        final bool showDate = shouldShowDate(content, idx);
        final bool showTime = shouldShowTime(content, idx);
        final bool showUserInfo = shouldShowUserInfo(content, idx);

        return ChatModel.fromResponse(
          response: e,
          isMine: isMine,
          showTime: showTime,
          showDate: showDate,
          isFirstMessage: isFirstMessage,
          showUserInfo: showUserInfo,
        );
      }).toList();
      if (!isFirstMessage) {
        // [기존 채팅 마지막, 새 채팅들]
        // 채팅이 최소 2개까지 subList 생성
        log("=================================");
        for (final m in pState.items) {
          log("message = ${m.message} date = ${m.date} time = ${m.time} ");
        }
        log("=================================");

        log("lastIdx  = ${lastIdx}");
        int existLastMessageIdx = lastIdx - 1;
        // 기존 메시지 마지막 인덱스로 잡고 더 있을 경우 그 앞까지 잡기
        int subListStartIdx = lastIdx;
        if (existLastMessageIdx > 0) {
          subListStartIdx--;
        }

        pState.items.insertAll(pState.items.length, newChatMessages);

        final subList = pState.items.sublist(subListStartIdx, lastIdx + 2);

        final newSubList = subList.mapIndexed((idx, e) {
          return e.copyWith(
            showDate: pState.items.shouldShowDateAt(subListStartIdx + idx),
            showTime: pState.items.shouldShowTimeAt(subListStartIdx + idx),
            showUserInfo: pState.items.shouldShowUserInfoAt(subListStartIdx + idx),
          );
        }).toList();

        pState.items.replaceRange(
            subListStartIdx, lastIdx + 2, newSubList);
        state = ResponseModel(
            status_code: 200,
            message: "message",
            data: pState.copyWith(
              items: pState.items,
              firstCursor: pState.firstCursor,
              lastCursor: response.lastCursor,
              earliestCursor: response.earliestCursor,
              latestCursor: response.latestCursor,
            ));
      } else {
        // 새로 추가
        state = ResponseModel(
            status_code: 200,
            message: "message",
            data: pState.copyWith(
              items: newChatMessages,
              firstCursor: response.firstCursor,
              lastCursor: response.lastCursor,
              earliestCursor: response.earliestCursor,
              latestCursor: response.latestCursor,
            ));
      }

      return CompletedModel(status_code: 0, message: message, data: null);
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      return error;
      // state = error;
    });
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
      if (pState.earliestCursor == pState.firstCursor) {
        return;
      }

      // 현재 가장 오래된 커서 위치 이전부터 이전 방향으로 조회
      cursorParam = cursorParam.copyWith(
        cursor: pState.firstCursor,
        direction: Direction.prev,
      );
    }

    repository
        .getChatMessages(gameId: gameId, cursorParams: cursorParam)
        .then((value) {
      final response = value.data!;
      final content = value.data!.items.toList();
      final newChatMessages = value.data!.items.mapIndexed((idx, e) {
        final isMine = e.user.id == currentUserId;

        // 첫 커서와 현재 맨 앞 커서가 일치하면 맨 앞 페이지
        final lastPage = value.data!.firstCursor == value.data!.earliestCursor;
        // 메세지 커서와 첫 커서가 일치할 경우 맨 처음 메시지
        final isFirstMessage = lastPage &&
            value.data!.items[idx].id == value.data!.earliestCursor;

        final bool showDate = shouldShowDate(content, idx);
        final bool showTime = shouldShowTime(content, idx);
        final bool showUserInfo = shouldShowUserInfo(content, idx);

        return ChatModel.fromResponse(
          response: e,
          isMine: isMine,
          showTime: showTime,
          showDate: showDate,
          isFirstMessage: isFirstMessage,
          showUserInfo: showUserInfo,
        );
      }).toList();

      if (fetchMore) {
        final pState = state as ResponseModel<CursorPaginationModel<ChatModel>>;
        final lastIdx = newChatMessages.length - 1;

        newChatMessages.insertAll(
            newChatMessages.length, pState.data!.items);

        int existLastMessageIdx = lastIdx - 1;
        // 새 채팅 마지막 인덱스로 잡고 더 있을 경우 그 앞까지 잡기
        int subListStartIdx = lastIdx;
        if (existLastMessageIdx > 0) {
          subListStartIdx--;
        }

        final subList = newChatMessages.sublist(subListStartIdx, lastIdx + 2);

        final newSubList = subList.mapIndexed((idx, e) {
          return e.copyWith(
            showDate: newChatMessages.shouldShowDateAt(subListStartIdx + idx),
            showTime: newChatMessages.shouldShowTimeAt(subListStartIdx + idx),
            showUserInfo: newChatMessages.shouldShowUserInfoAt(subListStartIdx + idx),
          );
        }).toList();

        newChatMessages.replaceRange(
            subListStartIdx, lastIdx + 2, newSubList);

        // // [새 채팅 마지막 이전, 새 채팅 마지막, 기존 채팅 처음, 기존 채팅 두번째,]
        //
        // // 채팅이 최소 2개까지 subList 생성
        // final minExistChatSize = min(pState.data!.messages.length, 2);
        //
        // final subList = newChatMessages.sublist(
        //     max(lastIdx - 1, 0), lastIdx + 1 + minExistChatSize);
        //
        // final newLastChat = newChatMessages[lastIdx].copyWith(
        //   showDate: subList.shouldShowDateAt(1),
        //   showTime: subList.shouldShowTimeAt(1),
        //   showUserInfo: subList.shouldShowUserInfoAt(1),
        // );
        // final existFirstChat = newChatMessages[lastIdx + 1].copyWith(
        //   showDate: subList.shouldShowDateAt(2),
        //   showTime: subList.shouldShowTimeAt(2),
        //   showUserInfo: subList.shouldShowUserInfoAt(2),
        // );
        //
        // newChatMessages
        //     .replaceRange(lastIdx, lastIdx + 2, [newLastChat, existFirstChat]);

        state = ResponseModel(
          status_code: pState.status_code,
          message: pState.message,
          data: pState.data!.copyWith(
            firstCursor: newChatMessages[0].id,
            items: [
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
            items: newChatMessages,
            firstCursor: response.firstCursor,
            lastCursor: response.lastCursor,
          ),
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
