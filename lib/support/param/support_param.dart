import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/param/pagination_param.dart';

part 'support_param.g.dart';

@JsonSerializable()
class SupportParam extends DefaultParam {
  final String title;
  final String content;

  SupportParam({
    required this.title,
    required this.content,
  });

  SupportParam copyWith({String? title, String? content}) {
    return SupportParam(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() => _$SupportParamToJson(this);

  @override
  List<Object?> get props => [title, content];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class FAQParam extends DefaultParam {
  final String search;

  FAQParam({
    required this.search,
  });

  FAQParam copyWith({
    String? search,
  }) {
    return FAQParam(
      search: search ?? this.search,
    );
  }

  Map<String, dynamic> toJson() => _$FAQParamToJson(this);

  @override
  List<Object?> get props => [search];

  @override
  bool? get stringify => true;
}
