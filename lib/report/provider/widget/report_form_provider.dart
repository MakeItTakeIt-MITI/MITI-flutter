import 'package:json_annotation/json_annotation.dart';
import 'package:miti/report/param/report_param.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/entity_enum.dart';

part 'report_form_provider.g.dart';

@riverpod
class ReportForm extends _$ReportForm {
  @override
  ReportParam build({required HostReportCategoryType category}) {
    return ReportParam(category: category, content: '');
  }

  void update({String? content}) {
    state = state.copyWith(
      content: content ?? state.content,
    );
  }
}
