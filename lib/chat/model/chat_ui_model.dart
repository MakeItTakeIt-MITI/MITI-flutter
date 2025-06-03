import 'dart:developer';
import 'dart:math' hide log;

import 'package:miti/common/model/default_model.dart';
import 'package:miti/util/util.dart';

import '../../user/model/v2/base_user_response.dart';
import 'base_game_chat_message_response.dart';

class ChatModel {
  final int id;
  final String message;
  final String date; // 01월 01일
  final String time; // 오후 01:01
  final BaseUserResponse user;
  final bool isMine;
  final bool showTime; // 사용자 별 시간의 마지막 메세지
  final bool showDate; // 오늘 첫 메세지
  final bool isFirstMessage; // 전체 메세지 중 마지막 메세지
  final bool showUserInfo;

  ChatModel({
    required this.id,
    required this.message,
    required this.date,
    required this.time,
    required this.user,
    required this.isMine,
    required this.showTime,
    required this.showDate,
    required this.isFirstMessage,
    required this.showUserInfo,
  });

  factory ChatModel.fromResponse({
    required BaseGameChatMessageResponse response,
    required bool isMine,
    required bool showTime,
    required bool showDate,
    required bool isFirstMessage,
    required bool showUserInfo,
  }) {
    return ChatModel(
      id: response.id,
      message: response.body,
      date: DateTimeUtil.formatDate(response.createdAt),
      time: DateTimeUtil.formatTime(response.createdAt),
      user: response.user,
      isMine: isMine,
      showTime: showTime,
      showDate: showDate,
      isFirstMessage: isFirstMessage,
      showUserInfo: showUserInfo,
    );
  }

  // copyWith 메서드
  ChatModel copyWith({
    int? id,
    String? message,
    String? date,
    String? time,
    BaseUserResponse? user,
    bool? isMine,
    bool? showTime,
    bool? showDate,
    bool? isFirstMessage,
    bool? showUserInfo,
  }) {
    return ChatModel(
      id: id ?? this.id,
      message: message ?? this.message,
      date: date ?? this.date,
      time: time ?? this.time,
      user: user ?? this.user,
      isMine: isMine ?? this.isMine,
      showTime: showTime ?? this.showTime,
      showDate: showDate ?? this.showDate,
      isFirstMessage: isFirstMessage ?? this.isFirstMessage,
      showUserInfo: showUserInfo ?? this.showUserInfo,
    );
  }
}

extension ChatModelValidation on List<ChatModel> {
  bool shouldShowTimeAt(int index) {
    if (isEmpty || index < 0 || index >= length) return false;

    final current = this[index];

    // 첫 번째 메시지는 항상 시간 표시
    if (index == length - 1) return true;

    // 마지막 메시지 처리
    if (index == 0) {
      final next = this[index + 1];

      // 이전 사용자와 다르면 시간 표시
      if (current.user.id != next.user.id) return true;

      // 같은 사용자지만 시간이 같으면 시간 숨김
      if (DateTimeUtil.isSameTime(
          _parseDateTime(next), _parseDateTime(current))) {
        return false;
      }

      return true;
    }

    final next = this[index + 1];
    final prev = this[index - 1];

    if (current.user.id != next.user.id) return true;

    if (DateTimeUtil.isSameTime(
        _parseDateTime(next), _parseDateTime(current))) {
      return false;
    }

    if (!DateTimeUtil.isSameTime(
        _parseDateTime(current), _parseDateTime(prev))) {
      return true;
    }

    if (!DateTimeUtil.isSameDay(
        _parseDateTime(current), _parseDateTime(prev))) {
      return true;
    }

    return true;
  }

  bool shouldShowDateAt(int index) {
    if (isEmpty || index < 0 || index >= length) return false;

    // 마지막 메시지는 무조건 날짜 표시
    if (index == 0) return true;

    final current = this[index];
    final prev = this[index - 1];

    return !DateTimeUtil.isSameDay(
        _parseDateTime(current), _parseDateTime(prev));
  }

  bool shouldShowUserInfoAt(int index) {
    if (isEmpty || index < 0 || index >= length) return false;

    final current = this[index];

    // 마지막 메시지는 무조건 사용자 정보 표시
    if (index == 0) return true;
    final prev = this[index - 1];
    return current.user.id != prev.user.id;
  }

  // ChatModel의 date, time을 DateTime으로 변환하는 헬퍼
  DateTime _parseDateTime(ChatModel message) {
    return DateTimeUtil.parseDateTime(message.date, message.time);
  }
}
