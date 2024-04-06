import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../component/custom_text_form_field.dart';

enum InputFormType {
  login, passwordCode
}

final formDescProvider = StateProvider.family.autoDispose<
    InteractionDesc?,
    InputFormType>((ref, InputFormType type) => null);

final passwordVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);