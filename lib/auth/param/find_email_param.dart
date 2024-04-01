import 'package:json_annotation/json_annotation.dart';

part 'find_email_param.g.dart';

@JsonSerializable()
class FindEmailParam {
  final String phone;

  FindEmailParam({required this.phone});
  Map<String, dynamic> toJson() => _$FindEmailParamToJson(this);
}
