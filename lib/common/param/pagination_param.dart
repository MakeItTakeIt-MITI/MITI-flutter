import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_param.g.dart';

@JsonSerializable()
class PaginationParam extends Equatable {
  final int page;

  const PaginationParam({
    required this.page,
  });

  Map<String, dynamic> toJson() => _$PaginationParamToJson(this);

  @override
  List<Object?> get props => [page];

  @override
  bool? get stringify => true;
}
