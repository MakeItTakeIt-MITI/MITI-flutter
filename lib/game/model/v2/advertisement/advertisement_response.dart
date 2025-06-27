import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'advertisement_response.g.dart';

@JsonSerializable()
class AdvertisementResponse extends IModelWithId{

  @JsonKey(name: 'advertisement_status')
  final AdvertisementStatusType advertisementStatus;  // Using existing enum for AdvertisementStatus

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'subtitle')
  final String? subtitle;

  @JsonKey(name: 'thumbnail_image_url')
  final String thumbnailImageUrl;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'data')
  final List<String> data;  // Assuming this is a JSON object

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'expire_at')
  final DateTime expireAt;

  AdvertisementResponse({
    required super.id,
    required this.advertisementStatus,
    required this.title,
    this.subtitle,
    required this.thumbnailImageUrl,
    required this.content,
    required this.data,
    this.createdAt,
    required this.expireAt,
  });

  factory AdvertisementResponse.fromJson(Map<String, dynamic> json) =>
      _$AdvertisementResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdvertisementResponseToJson(this);

  AdvertisementResponse copyWith({
    int? id,
    AdvertisementStatusType? advertisementStatus,
    String? title,
    String? subtitle,
    String? thumbnailImageUrl,
    String? content,
    List<String>? data,
    DateTime? createdAt,
    DateTime? expireAt,
  }) {
    return AdvertisementResponse(
      id: id ?? this.id,
      advertisementStatus: advertisementStatus ?? this.advertisementStatus,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      content: content ?? this.content,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expireAt: expireAt ?? this.expireAt,
    );
  }
}
