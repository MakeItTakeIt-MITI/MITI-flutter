import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../util/model/image_path.dart';

part 'post_form_param.g.dart';

@JsonSerializable()
class PostFormParam extends Equatable {
  final PostCategoryType category;
  final String title;
  final String content;
  final List<String> images;
  @JsonKey(name: "is_anonymous")
  final bool isAnonymous;
  @JsonKey(includeToJson: false)
  final List<ImagePath> localImages;

  const PostFormParam({
    required this.title,
    required this.content,
    required this.category,
    required this.images,
    required this.isAnonymous,
    this.localImages = const [],
  });

  PostFormParam copyWith({
    PostCategoryType? category,
    String? title,
    String? content,
    List<String>? images,
    bool? isAnonymous,
    List<ImagePath>? localImages,
  }) {
    return PostFormParam(
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      localImages: localImages ?? this.localImages,
    );
  }

  Map<String, dynamic> toJson() => _$PostFormParamToJson(this);

  factory PostFormParam.fromJson(Map<String, dynamic> json) =>
      _$PostFormParamFromJson(json);

  @override
  List<Object?> get props => [
        category,
        title,
        content,
        images,
        isAnonymous,
        localImages,
      ];

  @override
  bool? get stringify => true;
}
