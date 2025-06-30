import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'file_upload_param.g.dart';

@JsonSerializable()
class FileUploadParam extends Equatable {
  final FileCategoryType category;
  final int? png;
  final int? jpeg;
  final int? webp;

  const FileUploadParam({
    required this.category,
    this.png,
    this.jpeg,
    this.webp,
  });

  FileUploadParam copyWith({
    FileCategoryType? category,
    int? png,
    int? jpeg,
    int? webp,
  }) {
    return FileUploadParam(
      category: category ?? this.category,
      png: png ?? this.png,
      jpeg: jpeg ?? this.jpeg,
      webp: webp ?? this.webp,
    );
  }

  Map<String, dynamic> toJson() => _$FileUploadParamToJson(this);

  factory FileUploadParam.fromJson(Map<String, dynamic> json) =>
      _$FileUploadParamFromJson(json);

  @override
  List<Object?> get props => [
        category,
        png,
        jpeg,
        webp,
      ];

  @override
  bool? get stringify => true;
}
