import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../param/support_param.dart';

part 'support_form_provider.g.dart';

@riverpod
class SupportForm extends _$SupportForm {
  @override
  SupportParam build() {
    return SupportParam(title: '', content: '');
  }

  void update({String? title, String? content}) {
    state = state.copyWith(title: title, content: content);
  }
}
