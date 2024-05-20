import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pagination_param.g.dart';

abstract class DefaultParam extends Equatable {}

class PaginationStateParam<T extends DefaultParam> extends Equatable {
  final T? param;
  final int? path;

  PaginationStateParam({
    this.param,
    this.path,
  });

  @override
  List<Object?> get props => [param, path];

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class PaginationParam extends Equatable {
  final int page;

  const PaginationParam({
    required this.page,
  });

  PaginationParam copyWith({
    int? page,
  }) {
    return PaginationParam(
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> toJson() => _$PaginationParamToJson(this);

  @override
  List<Object?> get props => [page];

  @override
  bool? get stringify => true;
}
