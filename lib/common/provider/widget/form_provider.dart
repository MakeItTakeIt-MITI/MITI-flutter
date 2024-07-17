import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../component/custom_text_form_field.dart';
import '../../model/entity_enum.dart';

part 'form_provider.g.dart';


class FormModel {
  final Color? borderColor;
  final InteractionDesc? interactionDesc;

  FormModel({
    this.borderColor,
    this.interactionDesc,
  });

  FormModel copyWith({
    Color? borderColor,
    InteractionDesc? interactionDesc,
  }) {
    return FormModel(
      borderColor: borderColor ?? this.borderColor,
      interactionDesc: interactionDesc ?? this.interactionDesc,
    );
  }
}

@riverpod
class FormInfo extends _$FormInfo {
  @override
  FormModel build(InputFormType type) {
    return FormModel();
  }

  void update({
    Color? borderColor,
    InteractionDesc? interactionDesc,
  }) {
    state = state.copyWith(
      borderColor: borderColor,
      interactionDesc: interactionDesc,
    );
  }

  void reset(){
    state = FormModel();
  }
}
