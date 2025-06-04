import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_notice_param.g.dart';

@JsonSerializable()
class ChatNoticeParam extends Equatable {
  final String title;
  final String body;

  const ChatNoticeParam({
    required this.title,
    required this.body,
  });

  ChatNoticeParam copyWith({
    String? title,
    String? body,
  }) {
    return ChatNoticeParam(
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toJson() => _$ChatNoticeParamToJson(this);

  factory ChatNoticeParam.fromJson(Map<String, dynamic> json) =>
      _$ChatNoticeParamFromJson(json);

  @override
  List<Object?> get props => [title, body];

  @override
  bool? get stringify => true;
}
