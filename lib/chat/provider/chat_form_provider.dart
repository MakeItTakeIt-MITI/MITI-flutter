import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../param/chat_notice_param.dart';

part 'chat_form_provider.g.dart';

@riverpod
class ChatForm extends _$ChatForm {
  @override
  ChatNoticeParam build() {
    return const ChatNoticeParam(title: '', body: '');
  }

  void update({String? title, String? body}) {
    state = state.copyWith(title: title, body: body);
  }

  bool valid(){
    return validTitle() && validBody();
  }

  bool validTitle() {
    return state.title.isNotEmpty && state.title.length <= 32;
  }

  bool validBody() {
    return state.body.isNotEmpty && state.body.length <= 3000;
  }
}
