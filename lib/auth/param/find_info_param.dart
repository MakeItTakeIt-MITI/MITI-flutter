import 'package:json_annotation/json_annotation.dart';

part 'find_info_param.g.dart';

@JsonSerializable()
class FindInfoParam {
  final String phone;

  FindInfoParam({required this.phone});
  Map<String, dynamic> toJson() => _$FindInfoParamToJson(this);
}
