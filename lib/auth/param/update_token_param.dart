import 'package:json_annotation/json_annotation.dart';

part 'update_token_param.g.dart';

@JsonSerializable()
class UpdateTokenParam {
  final String password;

  UpdateTokenParam({required this.password});

  Map<String, dynamic> toJson() => _$UpdateTokenParamToJson(this);
}
