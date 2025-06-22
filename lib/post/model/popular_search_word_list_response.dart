import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'popular_search_word_list_response.g.dart';

@JsonSerializable()
class PopularSearchWordListResponse extends Base {
  @JsonKey(name: 'search_word')
  final String searchWord;

  final int count;

  PopularSearchWordListResponse({
    required this.searchWord,
    required this.count,
  });

  factory PopularSearchWordListResponse.fromJson(Map<String, dynamic> json) =>
      _$PopularSearchWordListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PopularSearchWordListResponseToJson(this);

  PopularSearchWordListResponse copyWith({
    String? searchWord,
    int? count,
  }) {
    return PopularSearchWordListResponse(
      searchWord: searchWord ?? this.searchWord,
      count: count ?? this.count,
    );
  }
}