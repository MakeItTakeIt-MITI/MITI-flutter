import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/model/find_info_model.dart';
import '../component/custom_text_form_field.dart';

enum InputFormType { login, passwordCode, nickname }

enum PasswordFormType { password, newPassword, newPasswordCheck }

final codeDescProvider = StateProvider.family
    .autoDispose<InteractionDesc?, FindInfoType>(
        (ref, FindInfoType type) => null);


final formDescProvider = StateProvider.family
    .autoDispose<InteractionDesc?, InputFormType>(
        (ref, InputFormType type) => null);

final passwordVisibleProvider = StateProvider.family
    .autoDispose<bool, PasswordFormType>((ref, type) => false);
