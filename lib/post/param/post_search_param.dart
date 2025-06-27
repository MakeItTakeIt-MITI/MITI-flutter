import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'post_search_param.g.dart';

@JsonSerializable()
class PostSearchParam extends Equatable {
  final String? search;
  final PostCategoryType? category;

  const PostSearchParam({
     this.search,
     this.category,
  });

  PostSearchParam copyWith({
    String? search,
    PostCategoryType? category,
    bool isAll = false,
  }) {
    if (isAll) {
      return PostSearchParam(
        search: search ?? this.search,
        category: null,
      );
    }

    return PostSearchParam(
      search: search ?? this.search,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => _$PostSearchParamToJson(this);

  factory PostSearchParam.fromJson(Map<String, dynamic> json) =>
      _$PostSearchParamFromJson(json);

  @override
  List<Object?> get props => [
        search,
        category,
      ];

  @override
  bool? get stringify => true;
}
