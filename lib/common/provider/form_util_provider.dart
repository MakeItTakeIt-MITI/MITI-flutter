import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../auth/model/find_info_model.dart';
import '../component/custom_text_form_field.dart';


final codeDescProvider = StateProvider.family
    .autoDispose<InteractionDesc?, PhoneAuthenticationPurposeType>(
        (ref, PhoneAuthenticationPurposeType type) => null);


final formDescProvider = StateProvider.family
    .autoDispose<InteractionDesc?, InputFormType>(
        (ref, InputFormType type) => null);

final passwordVisibleProvider = StateProvider.family
    .autoDispose<bool, PasswordFormType>((ref, type) => false);
