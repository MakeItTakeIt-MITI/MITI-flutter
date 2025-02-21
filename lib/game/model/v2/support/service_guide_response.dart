import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'service_guide_response.g.dart';

@JsonSerializable()
class ServiceGuideResponse extends IModelWithId{

  @JsonKey(name: 'category')
  final UserGuideCategoryType category;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'image')
  final List<String> image;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'modified_at')
  final String? modifiedAt;

  ServiceGuideResponse({
    required super.id,
    required this.category,
    required this.title,
    required this.content,
    required this.image,
    required this.createdAt,
    this.modifiedAt,
  });

  factory ServiceGuideResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceGuideResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceGuideResponseToJson(this);

  ServiceGuideResponse copyWith({
    int? id,
    UserGuideCategoryType? category,
    String? title,
    String? content,
    List<String>? image,
    String? createdAt,
    String? modifiedAt,
  }) {
    return ServiceGuideResponse(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}
