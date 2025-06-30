import 'package:json_annotation/json_annotation.dart';

import '../../common/model/model_id.dart';

part 'upload_url_response.g.dart';

@JsonSerializable()
class UploadUrlResponse extends Base {
  @JsonKey(name: 'upload_url')
  final String uploadUrl;

  @JsonKey(name: 'file_url')
  final String fileUrl;

  @JsonKey(name: 'file_path')
  final String filePath;

  @JsonKey(name: 'content_type')
  final String contentType;

  UploadUrlResponse({
    required this.uploadUrl,
    required this.fileUrl,
    required this.filePath,
    required this.contentType,
  });

  factory UploadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadUrlResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadUrlResponseToJson(this);

  UploadUrlResponse copyWith({
    String? uploadUrl,
    String? fileUrl,
    String? filePath,
    String? contentType,
  }) {
    return UploadUrlResponse(
      uploadUrl: uploadUrl ?? this.uploadUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      filePath: filePath ?? this.filePath,
      contentType: contentType ?? this.contentType,
    );
  }
}