import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/util/model/image_path.dart';

part 'post_comment_param.g.dart';

@JsonSerializable()
class PostCommentParam extends Equatable {
  final String content;
  final List<String> images;

  // 로컬 이미지 관리를 위한 필드 추가 (JSON 직렬화에서 제외)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<ImagePath> localImages;

  const PostCommentParam({
    required this.content,
    required this.images,
    this.localImages = const [],
  });

  PostCommentParam copyWith({
    String? content,
    List<String>? images,
    List<ImagePath>? localImages,
  }) {
    return PostCommentParam(
      content: content ?? this.content,
      images: images ?? this.images,
      localImages: localImages ?? this.localImages,
    );
  }

  Map<String, dynamic> toJson() => _$PostCommentParamToJson(this);

  factory PostCommentParam.fromJson(Map<String, dynamic> json) =>
      _$PostCommentParamFromJson(json);

  @override
  List<Object?> get props => [
    content,
    images,
    localImages,
  ];

  @override
  bool? get stringify => true;
}