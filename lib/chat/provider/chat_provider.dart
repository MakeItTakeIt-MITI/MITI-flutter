import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/util/util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/provider/auth_provider.dart';
import '../../common/logger/custom_logger.dart';
import '../../common/model/cursor_model.dart';
import '../../common/param/pagination_param.dart';
import '../model/base_game_chat_message_response.dart';
import '../model/chat_ui_model.dart';
import '../repository/chat_repository.dart';

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
          .pageFirstCursor;
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
        final lastPage = !value.data!.hasMore;
        // 메세지 커서와 첫 커서가 일치할 경우 맨 처음 메시지
        final isFirstMessage =
            lastPage && value.data!.items[idx].id == value.data!.pageLastCursor;

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

        newChatMessages.insertAll(newChatMessages.length, pState.items);
        // pState.items.insertAll(pState.items.length, newChatMessages);
        //
        // final subList = pState.items.sublist(subListStartIdx, lastIdx + 2);
        //
        // final newSubList = subList.mapIndexed((idx, e) {
        //   return e.copyWith(
        //     showDate: pState.items.shouldShowDateAt(subListStartIdx + idx),
        //     showTime: pState.items.shouldShowTimeAt(subListStartIdx + idx),
        //     showUserInfo: pState.items.shouldShowUserInfoAt(subListStartIdx + idx),
        //   );
        // }).toList();
        //
        // pState.items.replaceRange(
        //     subListStartIdx, lastIdx + 2, newSubList);
        state = ResponseModel(
            status_code: 200,
            message: "message",
            data: pState.copyWith(
              items: newChatMessages, //pState.items,
              pageFirstCursor: response.pageFirstCursor,
              pageLastCursor: pState.pageLastCursor,
              hasMore: pState.hasMore,
            ));
      } else {
        // 새로 추가
        state = ResponseModel(
            status_code: 200,
            message: "message",
            data: pState.copyWith(
              items: newChatMessages,
              pageFirstCursor: response.pageFirstCursor,
              pageLastCursor: response.pageLastCursor,
              hasMore: response.hasMore,
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
    final repository = ref.watch(chatRepositoryProvider);
    final currentUserId = ref.read(authProvider)?.id ?? -1; // 현재 사용자 ID 가져오기

    if (fetchMore) {
      final pState =
          (state as ResponseModel<CursorPaginationModel<ChatModel>>).data!;
      // 더 가져올 데이터가 없는경우
      if (!pState.hasMore) {
        return;
      }

      // 현재 마지막 커서 위치 조회
      cursorParam = cursorParam.copyWith(
        cursor: pState.pageLastCursor,
      );
    }

    repository
        .getChatMessages(gameId: gameId, cursorParams: cursorParam)
        .then((value) {
      final response = value.data!;
      final content = value.data!.items.toList();
      final newChatMessages = value.data!.items.mapIndexed((idx, e) {
        log("출력되는 idx ${idx} ${e.id}");
        final isMine = e.user.id == currentUserId;

        // 첫 커서와 현재 맨 앞 커서가 일치하면 맨 앞 페이지
        final lastPage = !value.data!.hasMore;
        // 메세지 커서와 첫 커서가 일치할 경우 맨 처음 메시지
        final isFirstMessage =
            lastPage && value.data!.items[idx].id == value.data!.pageLastCursor;

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
        int len = pState.data!.items.length;
        final lastIdx = len - 1;

        // newChatMessages.insertAll(
        //     .length, pState.data!.items);

        pState.data!.items.insertAll(len, newChatMessages);

        int existLastMessageIdx = lastIdx - 1;
        // 새 채팅 마지막 인덱스로 잡고 더 있을 경우 그 앞까지 잡기
        int subListStartIdx = lastIdx;
        if (existLastMessageIdx > 0) {
          subListStartIdx--;
        }

        final subList =
            pState.data!.items.sublist(subListStartIdx, lastIdx + 2);

        final newSubList = subList.mapIndexed((idx, e) {
          return e.copyWith(
            showDate:
                pState.data!.items.shouldShowDateAt(subListStartIdx + idx),
            showTime:
                pState.data!.items.shouldShowTimeAt(subListStartIdx + idx),
            showUserInfo:
                pState.data!.items.shouldShowUserInfoAt(subListStartIdx + idx),
          );
        }).toList();

        pState.data!.items
            .replaceRange(subListStartIdx, lastIdx + 2, newSubList);

        state = ResponseModel(
          status_code: pState.status_code,
          message: pState.message,
          data: pState.data!.copyWith(
            //newChatMessages[0].id
            hasMore: response.hasMore,
            pageLastCursor: pState.data!.pageLastCursor,
            items: [
              ...pState.data!.items,
            ],
          ),
        );
      } else {
        // 처음 불러오기
        state = ResponseModel(
          status_code: value.status_code,
          message: value.message,
          data: CursorPaginationModel(
            pageFirstCursor: response.pageFirstCursor,
            pageLastCursor: response.pageLastCursor,
            items: newChatMessages,
            hasMore: response.hasMore,
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
    if (currentIndex == messages.length - 1) {
      return true;
    }
    final currentMessage = messages[currentIndex];

    // 이전에 작성한 메시지
    final prevMessage = messages[currentIndex + 1];

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
    if (currentIndex == messages.length - 1) {
      return true;
    }
    final currentMessage = messages[currentIndex];
    final prevMessage = messages[currentIndex + 1];
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
    if (currentIndex == 0) {
      return true;
    }

    if (currentIndex == messages.length - 1) {
      final nextMessage = messages[currentIndex - 1];
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

    final nextMessage = messages[currentIndex - 1];
    final prevMessage = messages[currentIndex + 1];
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
