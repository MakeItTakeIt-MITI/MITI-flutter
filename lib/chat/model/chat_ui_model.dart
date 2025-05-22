import 'package:miti/common/model/default_model.dart';

class DateChatModel extends BaseModel {
  final int endIndex;
  final int currentIndex;
  final Map<String, List<UserChatModel>> chatsByDate;

  DateChatModel({
    required this.endIndex,
    required this.currentIndex,
    required this.chatsByDate,
  });

  DateChatModel copyWith(
      {required int? endIndex,
      required int? currentIndex,
      required Map<String, List<UserChatModel>>? chatsByDate}) {
    return DateChatModel(
      endIndex: endIndex ?? this.endIndex,
      currentIndex: currentIndex ?? this.currentIndex,
      chatsByDate: chatsByDate ?? this.chatsByDate,
    );
  }
}

class UserChatModel {
  final int userId;
  final bool isMine;
  final String nickname;
  final String imageUrl;
  final List<ChatModel> chats;

  UserChatModel({
    required this.userId,
    required this.isMine,
    required this.nickname,
    required this.imageUrl,
    required this.chats,
  });
}

class ChatModel {
  final int chatId;
  final String time;
  final String message;

  ChatModel({
    required this.chatId,
    required this.time,
    required this.message,
  });
}
