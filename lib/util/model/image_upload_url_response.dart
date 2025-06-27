import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';

part 'image_upload_url_response.g.dart';

@JsonSerializable()
class BaseImageUploadUrlResponse extends Base {

  final ImageType category;
  final int count;
  final List<ImageUploadUrlResponse> urls;

  BaseImageUploadUrlResponse({
    required this.category,
    required this.count,
    required this.urls,
  });

  factory BaseImageUploadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseImageUploadUrlResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseImageUploadUrlResponseToJson(this);

  BaseImageUploadUrlResponse copyWith({
    ImageType? category,
    int? count,
    List<ImageUploadUrlResponse>? urls,
  }) {
    return BaseImageUploadUrlResponse(
      category: category ?? this.category,
      count: count ?? this.count,
      urls: urls ?? this.urls,
    );
  }
}

@JsonSerializable()
class ImageUploadUrlResponse extends Base {
  @JsonKey(name: 'image_upload_url')
  final String imageUploadUrl;

  @JsonKey(name: 'temp_image_url')
  final String tempImageUrl;

  @JsonKey(name: 'image_path')
  final String imagePath;

  ImageUploadUrlResponse({
    required this.imageUploadUrl,
    required this.tempImageUrl,
    required this.imagePath,
  });

  factory ImageUploadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadUrlResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ImageUploadUrlResponseToJson(this);

  ImageUploadUrlResponse copyWith({
    String? imageUploadUrl,
    String? tempImageUrl,
    String? imagePath,
  }) {
    return ImageUploadUrlResponse(
      imageUploadUrl: imageUploadUrl ?? this.imageUploadUrl,
      tempImageUrl: tempImageUrl ?? this.tempImageUrl,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
