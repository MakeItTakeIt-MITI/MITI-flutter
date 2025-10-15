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
class CursorPaginationParam extends Equatable {
  final int? cursor;
  final int? limit;

  const CursorPaginationParam({
     this.cursor,
     this.limit,
  });

  CursorPaginationParam copyWith({
    int? cursor,
    int? limit,
  }) {
    return CursorPaginationParam(
      cursor: cursor ?? this.cursor,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() => _$CursorPaginationParamToJson(this);

  @override
  List<Object?> get props => [cursor, limit];

  @override
  bool? get stringify => true;
}
