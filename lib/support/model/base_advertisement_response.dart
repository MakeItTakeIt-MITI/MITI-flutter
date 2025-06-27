import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'base_advertisement_response.g.dart';

@JsonSerializable()
class BaseAdvertisementResponse extends IModelWithId {
  final String title;

  @JsonKey(name: 'thumbnail_image_url')
  final String thumbnailImageUrl;

  BaseAdvertisementResponse({
    required super.id,
    required this.title,
    required this.thumbnailImageUrl,
  });

  factory BaseAdvertisementResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseAdvertisementResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseAdvertisementResponseToJson(this);

  BaseAdvertisementResponse copyWith({
    int? id,
    String? title,
    String? thumbnailImageUrl,
  }) {
    return BaseAdvertisementResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
    );
  }
}