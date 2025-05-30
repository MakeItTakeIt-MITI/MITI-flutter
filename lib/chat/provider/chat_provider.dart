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
import '../../user/model/v2/base_user_response.dart';
import '../model/base_game_chat_message_response.dart';
import '../model/chat_ui_model.dart';

part 'chat_provider.g.dart';

@Riverpod()
class ChatPagination extends _$ChatPagination {
  late final PaginationParam pageParams;

  @override
  BaseModel build({required int gameId}) {
    pageParams = const PaginationParam(page: 1);
    getChatPagination(gameId: gameId);
    return LoadingModel();
  }

  Future<BaseModel> sendMessage({required String message}) async {
    final repository = ref.watch(chatRepositoryProvider);
    return repository
        .postChatMessage(gameId: gameId, body: message)
        .then<BaseModel>((e) {
      final pState = (state as ResponseModel<PaginationModel<ChatModel>>).data!;
      final now = DateTime.now();
      final date = DateTimeUtil.formatDate(now);
      final time = DateTimeUtil.formatTime(now);
      final user = ref.read(authProvider);
      final isFirstMessage = pState.page_content.isEmpty;
      final lastIdx = pState.page_content.length - 1;

      pState.page_content.add(
        ChatModel(
          message: message,
          date: date,
          time: time,
          user: BaseUserResponse(
              nickname: user?.nickname ?? '익명',
              profileImageUrl: "",
              id: user?.id),
          isMine: true,
          showTime: true,
          showDate: true,
          isLastMessage: pState.page_content.isEmpty,
          showUserInfo: true,
        ),
      );
      if (!isFirstMessage) {
        // [기존 채팅 마지막, 새 채팅]
        // 채팅이 최소 2개까지 subList 생성
        log("=================================");
        for (final m in pState.page_content) {
          log("message = ${m.message} date = ${m.date} time = ${m.time} ");
        }
        log("=================================");

        log("lastIdx  = ${lastIdx}");
        final subList =
            pState.page_content.sublist(max(lastIdx - 1, 0), lastIdx + 2);

        log("subList length  = ${subList.length}");

        final existLastChat = pState.page_content[lastIdx].copyWith(
          showDate: subList.shouldShowDateAt(subList.length - 2),
          showTime: subList.shouldShowTimeAt(subList.length - 2),
          showUserInfo: subList.shouldShowUserInfoAt(subList.length - 2),
        );

        final newChat = pState.page_content[lastIdx + 1].copyWith(
          showDate: subList.shouldShowDateAt(subList.length - 1),
          showTime: subList.shouldShowTimeAt(subList.length - 1),
          showUserInfo: subList.shouldShowUserInfoAt(subList.length - 1),
        );

        pState.page_content
            .replaceRange(lastIdx, lastIdx + 2, [existLastChat, newChat]);
      }

      state = ResponseModel(
          status_code: 200,
          message: "message",
          data: pState.copyWith(page_content: pState.page_content));

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
    PaginationParam paginationParam = const PaginationParam(page: 1),
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
      final pState = (state as ResponseModel<PaginationModel<ChatModel>>).data!;
      if (pState.end_index == pState.current_index) {
        return;
      }

      paginationParam =
          paginationParam.copyWith(page: pState.current_index + 1);
    }

    repository
        .getChatMessages(gameId: gameId, paginationParams: paginationParam)
        .then((value) {
      // final value = ResponseModel(
      //     status_code: 0,
      //     message: '',
      //     data: ChatTimeTestDummyData.dateChangeTestData);
      final response = value.data!;
      final content = value.data!.page_content.reversed.toList();
      final newChatMessages =
          value.data!.page_content.reversed.mapIndexed((idx, e) {
        final isMine = e.user.id == currentUserId;

        final lastPage = value.data!.current_index == value.data!.end_index;
        final isLastMessage =
            lastPage && idx == value.data!.page_content.length - 1;

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
        final pState = state as ResponseModel<PaginationModel<ChatModel>>;
        final lastIdx = newChatMessages.length - 1;

        newChatMessages.insertAll(
            newChatMessages.length, pState.data!.page_content);

        // [새 채팅 마지막 이전, 새 채팅 마지막, 기존 채팅 처음, 기존 채팅 두번째,]

        // 채팅이 최소 2개까지 subList 생성
        final minExistChatSize = min(pState.data!.page_content.length, 2);

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
            start_index: pState.data!.start_index,
            end_index: pState.data!.end_index,
            current_index: pState.data!.current_index + 1,
            page_content: [
              ...newChatMessages,
            ],
          ),
        );
      } else {
        state = ResponseModel(
          status_code: value.status_code,
          message: value.message,
          data: PaginationModel(
              start_index: response.start_index,
              end_index: response.end_index,
              current_index: response.current_index,
              page_content: newChatMessages),
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

////////////
class ChatTimeTestDummyData {
  static List<BaseUserResponse> get testUsers => [
        BaseUserResponse(
          id: 1,
          nickname: "김철수",
          profileImageUrl: "https://example.com/profile1.jpg",
        ),
        BaseUserResponse(
          id: 2,
          nickname: "박영희",
          profileImageUrl: "https://example.com/profile2.jpg",
        ),
        BaseUserResponse(
          id: 3,
          nickname: "이민수",
          profileImageUrl: "https://example.com/profile3.jpg",
        ),
      ];

  /// 시간 표시 로직 테스트용 더미 데이터
  static PaginationModel<BaseGameChatMessageResponse> get timeTestData {
    final users = testUsers;
    final baseTime = DateTime(2025, 5, 30, 14, 0); // 2시 0분부터 시작

    final testMessages = [
      // 1. 김철수 연속 메시지 (1분 간격) - 마지막에만 시간 표시
      BaseGameChatMessageResponse(
        id: 1,
        body: "안녕하세요!",
        createdAt: baseTime, // 14:00
        user: users[0], // 김철수
      ),
      BaseGameChatMessageResponse(
        id: 2,
        body: "오늘 게임 참가하게 되어 기뻐요",
        createdAt: baseTime.add(Duration(seconds: 30)), // 14:00:30
        user: users[0], // 김철수 (연속)
      ),
      BaseGameChatMessageResponse(
        id: 3,
        body: "잘 부탁드립니다 😊",
        createdAt: baseTime.add(Duration(minutes: 1)), // 14:01
        user: users[0], // 김철수 (연속) - 여기서 시간 표시 (다음이 다른 사용자)
      ),

      // 2. 박영희 메시지 (사용자 변경)
      BaseGameChatMessageResponse(
        id: 4,
        body: "저도 잘 부탁드려요!",
        createdAt: baseTime.add(Duration(minutes: 2)), // 14:02
        user: users[1], // 박영희 - 여기서 시간 표시 (다음이 다른 사용자)
      ),

      // 3. 이민수 연속 메시지
      BaseGameChatMessageResponse(
        id: 5,
        body: "혹시 몇 시에 시작하나요?",
        createdAt: baseTime.add(Duration(minutes: 3)), // 14:03
        user: users[2], // 이민수
      ),
      BaseGameChatMessageResponse(
        id: 6,
        body: "주차는 어디서 하면 되나요?",
        createdAt: baseTime.add(Duration(minutes: 3, seconds: 20)), // 14:03:20
        user: users[2], // 이민수 (연속) - 여기서 시간 표시 (다음이 다른 사용자)
      ),

      // 4. 김철수 다시 등장 (5분 후)
      BaseGameChatMessageResponse(
        id: 7,
        body: "3시에 시작 예정이에요",
        createdAt: baseTime.add(Duration(minutes: 8)), // 14:08
        user: users[0], // 김철수
      ),
      BaseGameChatMessageResponse(
        id: 8,
        body: "주차장은 코트 바로 앞에 있어요",
        createdAt: baseTime.add(Duration(minutes: 8, seconds: 15)), // 14:08:15
        user: users[0], // 김철수 (연속) - 여기서 시간 표시 (다음과 시간 차이)
      ),

      // 5. 김철수 메시지 (6분 후 - 시간 차이로 인한 시간 표시)
      BaseGameChatMessageResponse(
        id: 9,
        body: "감사합니다!",
        createdAt: baseTime.add(Duration(minutes: 14)), // 14:14 (6분 차이)
        user: users[0], // 김철수 - 여기서 시간 표시 (다음이 다른 사용자)
      ),

      // 6. 박영희 마지막 메시지
      BaseGameChatMessageResponse(
        id: 10,
        body: "그럼 이따 뵙겠습니다!",
        createdAt: baseTime.add(Duration(minutes: 15)), // 14:15
        user: users[1], // 박영희 - 여기서 시간 표시 (마지막 메시지)
      ),
    ];

    return PaginationModel<BaseGameChatMessageResponse>(
      start_index: 1,
      end_index: 1,
      current_index: 1,
      page_content: testMessages.reversed.toList(),
    );
  }

  /// 날짜 변경 테스트용 더미 데이터
  static PaginationModel<BaseGameChatMessageResponse> get dateChangeTestData {
    final users = testUsers;
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    final testMessages = [
      // 어제 마지막 메시지
      BaseGameChatMessageResponse(
        id: 1,
        body: "내일 게임 기대돼요!",
        createdAt:
            DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 30),
        user: users[0], // 김철수
      ),
      BaseGameChatMessageResponse(
        id: 2,
        body: "잘 자요 😴",
        createdAt:
            DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 31),
        user: users[0], // 김철수 - 여기서 시간 표시 (날짜 변경)
      ),

      // 오늘 첫 메시지
      BaseGameChatMessageResponse(
        id: 3,
        body: "좋은 아침이에요!",
        createdAt: DateTime(today.year, today.month, today.day, 9, 0),
        user: users[1], // 박영희
      ),
      BaseGameChatMessageResponse(
        id: 4,
        body: "오늘 날씨가 좋네요 ☀️",
        createdAt: DateTime(today.year, today.month, today.day, 9, 1),
        user: users[1], // 박영희 - 여기서 시간 표시 (마지막)
      ),
    ];

    return PaginationModel<BaseGameChatMessageResponse>(
      start_index: 1,
      end_index: 1,
      current_index: 1,
      page_content: testMessages.reversed.toList(),
    );
  }

  /// 복잡한 시나리오 테스트용 더미 데이터
  static PaginationModel<BaseGameChatMessageResponse> get complexScenarioData {
    final users = testUsers;
    final baseTime = DateTime(2025, 5, 30, 10, 0);

    final testMessages = [
      // 시나리오 1: A → A → A (연속, 짧은 간격)
      BaseGameChatMessageResponse(
        id: 1,
        body: "안녕하세요",
        createdAt: baseTime,
        user: users[0],
      ),
      BaseGameChatMessageResponse(
        id: 2,
        body: "게임 방에 참가했습니다",
        createdAt: baseTime.add(Duration(seconds: 10)),
        user: users[0], // 연속
      ),
      BaseGameChatMessageResponse(
        id: 3,
        body: "잘 부탁드려요",
        createdAt: baseTime.add(Duration(seconds: 30)),
        user: users[0], // 연속 - 시간 표시 O (사용자 변경)
      ),

      // 시나리오 2: B → B (연속, 짧은 간격)
      BaseGameChatMessageResponse(
        id: 4,
        body: "반갑습니다!",
        createdAt: baseTime.add(Duration(minutes: 1)),
        user: users[1],
      ),
      BaseGameChatMessageResponse(
        id: 5,
        body: "함께 게임해요",
        createdAt: baseTime.add(Duration(minutes: 1, seconds: 20)),
        user: users[1], // 연속 - 시간 표시 O (긴 시간 간격)
      ),

      // 시나리오 3: A 다시 등장 (5분 후)
      BaseGameChatMessageResponse(
        id: 6,
        body: "네! 좋습니다",
        createdAt: baseTime.add(Duration(minutes: 6)),
        user: users[0], // 5분 차이 - 시간 표시 O (사용자 변경)
      ),

      // 시나리오 4: C → C → C (연속)
      BaseGameChatMessageResponse(
        id: 7,
        body: "저도 참가할게요",
        createdAt: baseTime.add(Duration(minutes: 7)),
        user: users[2],
      ),
      BaseGameChatMessageResponse(
        id: 8,
        body: "언제 시작하나요?",
        createdAt: baseTime.add(Duration(minutes: 7, seconds: 15)),
        user: users[2], // 연속
      ),
      BaseGameChatMessageResponse(
        id: 9,
        body: "기대돼요!",
        createdAt: baseTime.add(Duration(minutes: 7, seconds: 45)),
        user: users[2], // 연속 - 시간 표시 O (마지막 메시지)
      ),
    ];

    return PaginationModel<BaseGameChatMessageResponse>(
      start_index: 1,
      end_index: 1,
      current_index: 1,
      page_content: testMessages,
    );
  }
}
