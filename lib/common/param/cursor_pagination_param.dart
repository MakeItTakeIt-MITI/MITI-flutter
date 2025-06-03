import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_param.g.dart';

//next/prev
enum Direction {
  next,
  prev;
}

@JsonSerializable()
class CursorPaginationParam extends Equatable {
  @JsonKey(includeIfNull: false)
  final int? cursor;
  @JsonKey(includeIfNull: false)
  final Direction? direction;
  @JsonKey(includeIfNull: false)
  final int? limit;

  const CursorPaginationParam({
    this.cursor,
    this.direction,
    this.limit = 20,
  });

  CursorPaginationParam copyWith({
    int? cursor,
    Direction? direction,
    int? limit,
  }) {
    return CursorPaginationParam(
      cursor: cursor ?? this.cursor,
      direction: direction ?? this.direction,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toJson() => _$CursorPaginationParamToJson(this);

  @override
  List<Object?> get props => [cursor, direction, limit];

  @override
  bool? get stringify => true;
}
