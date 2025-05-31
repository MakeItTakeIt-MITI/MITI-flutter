import 'package:miti/chat/provider/chat_notice_provider.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/notification_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../notification/model/game_chat_notification_response.dart';
import '../param/chat_notice_param.dart';

part 'chat_form_provider.g.dart';

@riverpod
class ChatForm extends _$ChatForm {
  @override
  ChatNoticeParam build({ int? gameId,  int? notificationId}) {
    if (gameId != null && notificationId != null) {
      final result = ref.read(chatNoticeDetailProvider(
          gameId: gameId, notificationId: notificationId));
      if (result is ResponseModel<GameChatNotificationResponse>) {
        final model = result.data!;
        return ChatNoticeParam(title: model.title, body: model.body);
      }
    }

    return const ChatNoticeParam(title: '', body: '');
  }

  void update({String? title, String? body}) {
    state = state.copyWith(title: title, body: body);
  }

  bool valid() {
    return validTitle() && validBody();
  }

  bool validTitle() {
    return state.title.isNotEmpty && state.title.length <= 32;
  }

  bool validBody() {
    return state.body.isNotEmpty && state.body.length <= 3000;
  }
}
