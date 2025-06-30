import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/util/model/upload_url_response.dart';

import '../../common/model/model_id.dart';

part 'file_upload_url_response.g.dart';

@JsonSerializable()
class FileUploadUrlResponse extends Base {
  final FileCategoryType category;

  final List<UploadUrlResponse> png;

  final List<UploadUrlResponse> jpeg;

  final List<UploadUrlResponse> webp;

  FileUploadUrlResponse({
    required this.category,
    required this.png,
    required this.jpeg,
    required this.webp,
  });

  factory FileUploadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadUrlResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FileUploadUrlResponseToJson(this);

  FileUploadUrlResponse copyWith({
    FileCategoryType? category,
    List<UploadUrlResponse>? png,
    List<UploadUrlResponse>? jpeg,
    List<UploadUrlResponse>? webp,
  }) {
    return FileUploadUrlResponse(
      category: category ?? this.category,
      png: png ?? this.png,
      jpeg: jpeg ?? this.jpeg,
      webp: webp ?? this.webp,
    );
  }
}