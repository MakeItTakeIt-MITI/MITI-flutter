import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

part 'pay_request_param.g.dart';

@JsonSerializable()
class PayRequestParam extends Equatable {
  @JsonKey(name: 'item_type')
  final ItemType itemType;
  final int game;
  final int? coupon;

  const PayRequestParam({
    required this.itemType,
    required this.game,
    this.coupon,
  });

  @override
  List<Object?> get props => [
        itemType,
        game,
        coupon,
      ];

  @override
  bool? get stringify => true;

  Map<String, dynamic> toJson() => _$PayRequestParamToJson(this);

  factory PayRequestParam.fromJson(Map<String, dynamic> json) =>
      _$PayRequestParamFromJson(json);
}
