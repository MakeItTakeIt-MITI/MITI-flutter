import 'package:json_annotation/json_annotation.dart';

import 'default_model.dart';

part 'cursor_model.g.dart';

@JsonSerializable(
  genericArgumentFactories: true,
)
class CursorPaginationModel<T> extends BaseModel {
  @JsonKey(name: 'page_first_cursor')
  final int? pageFirstCursor;
  @JsonKey(name: 'page_last_cursor')
  final int? pageLastCursor;
  @JsonKey(name: 'has_more')
  final bool hasMore;
  final List<T> items;

  CursorPaginationModel({
    required this.pageFirstCursor,
    required this.pageLastCursor,
    required this.hasMore,
    required this.items,
  });

  CursorPaginationModel<T> copyWith({
    int? pageFirstCursor,
    int? pageLastCursor,
    List<T>? items,
    bool? hasMore,
  }) {
    return CursorPaginationModel<T>(
      pageFirstCursor: pageFirstCursor ?? this.pageFirstCursor,
      pageLastCursor: pageLastCursor ?? this.pageLastCursor,
      hasMore: hasMore ?? this.hasMore,
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
    required super.pageFirstCursor,
    required super.pageLastCursor,
    required super.hasMore,
    required super.items,
  });
}

class CursorPaginationModelFetchingMore<T> extends CursorPaginationModel<T> {
  CursorPaginationModelFetchingMore({
    required super.pageFirstCursor,
    required super.pageLastCursor,
    required super.hasMore,
    required super.items,
  });
}
