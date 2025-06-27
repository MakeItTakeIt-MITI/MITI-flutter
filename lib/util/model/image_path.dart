import 'package:json_annotation/json_annotation.dart';
part 'image_path.g.dart';
@JsonSerializable()
class ImagePath {
  final String? filePath;
  final String? imageUrl;
  final bool isLoading;

  const ImagePath({
    required this.filePath,
    required this.imageUrl,
    this.isLoading = false,
  });

  ImagePath copyWith({
    String? filePath,
    String? imageUrl,
    bool? isLoading,
  }) {
    return ImagePath(
      filePath: filePath ?? this.filePath,
      imageUrl: imageUrl ?? this.imageUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() => _$ImagePathToJson(this);
  factory ImagePath.fromJson(Map<String, dynamic> json) =>
      _$ImagePathFromJson(json);
}