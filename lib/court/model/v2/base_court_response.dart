import 'package:json_annotation/json_annotation.dart';

import '../../../common/model/model_id.dart';

part 'base_court_response.g.dart';

@JsonSerializable()
class BaseCourtResponse extends IModelWithId {
  final String? name;
  final String address;
  @JsonKey(name: 'address_detail')
  final String? addressDetail;

  BaseCourtResponse({
    required super.id,
    this.name,
    required this.address,
    this.addressDetail,
  });

  factory BaseCourtResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseCourtResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseCourtResponseToJson(this);

  BaseCourtResponse copyWith({
    int? id,
    String? name,
    String? address,
    String? addressDetail,
  }) {
    return BaseCourtResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      addressDetail: addressDetail ?? this.addressDetail,
    );
  }
}
