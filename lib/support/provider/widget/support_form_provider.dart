import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';
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

@riverpod
class FAQSearchForm extends _$FAQSearchForm {
  @override
  FAQParam build() {
    return FAQParam(search: '');
  }

  FAQParam update({String? search}) {
    state = state.copyWith(search: search);
    return state;
  }
}

final faqCategoryProvider = StateProvider.autoDispose<FAQType>((ref) {
  return FAQType.all;
});
