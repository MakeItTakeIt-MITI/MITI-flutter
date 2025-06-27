import 'package:json_annotation/json_annotation.dart';

import 'default_model.dart';

part 'cursor_model.g.dart';

@JsonSerializable(
  genericArgumentFactories: true,
)
class CursorPaginationModel<T> extends BaseModel {
  /*
    첫번째 게시글 id = earliest_cursor
    최신 작성 게시글 id = latest_cursor
    조회 게시글 목록 중 가장 먼저 작성된 게시글 id = first_cursor
    조회 게시글 목록 중 가장 최신에 작성된 게시글 id = last_cursor
   */
  @JsonKey(name: 'latest_cursor')
  final int? latestCursor;
  @JsonKey(name: 'earliest_cursor')
  final int? earliestCursor;
  @JsonKey(name: 'first_cursor')
  final int? firstCursor;
  @JsonKey(name: 'last_cursor')
  final int? lastCursor;

  final List<T> items;

  CursorPaginationModel({
    required this.latestCursor,
    required this.earliestCursor,
    required this.items,
    required this.firstCursor,
    required this.lastCursor,
  });

  CursorPaginationModel<T> copyWith({
    int? latestCursor,
    int? earliestCursor,
    List<T>? items,
    int? firstCursor,
    int? lastCursor,
  }) {
    return CursorPaginationModel<T>(
      latestCursor: latestCursor ?? this.latestCursor,
      earliestCursor: earliestCursor ?? this.earliestCursor,
      firstCursor: firstCursor ?? this.firstCursor,
      lastCursor: lastCursor ?? this.lastCursor,
      items: items ?? this.items,
    );
  }

  factory CursorPaginationModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return _$CursorPaginationModelFromJson(json, fromJsonT);
  }
}

class CursorPaginationModelRefetching<T> extends CursorPaginationModel<T> {
  CursorPaginationModelRefetching({
    required super.latestCursor,
    required super.earliestCursor,
    required super.firstCursor,
    required super.lastCursor,
    required super.items,
  });
}

class CursorPaginationModelFetchingMore<T> extends CursorPaginationModel<T> {
  CursorPaginationModelFetchingMore({
    required super.latestCursor,
    required super.earliestCursor,
    required super.firstCursor,
    required super.lastCursor,
    required super.items,
  });
}
