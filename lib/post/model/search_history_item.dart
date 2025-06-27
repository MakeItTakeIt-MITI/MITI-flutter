
import 'package:json_annotation/json_annotation.dart';
part 'search_history_item.g.dart';

@JsonSerializable()
class SearchHistoryItem {
  final String query;
  final DateTime searchedAt;

  SearchHistoryItem({
    required this.query,
    required this.searchedAt,
  });

  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchHistoryItemToJson(this);
}