import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';

part 'bank_model.g.dart';

@JsonSerializable()
class BankModel extends IModelWithId {
  final int amount;
  final String account_bank;
  final String account_holder;
  final String account_number;
  final BankType status;
  final DateTime created_at;

  BankModel({
    required super.id,
    required this.amount,
    required this.account_bank,
    required this.account_holder,
    required this.account_number,
    required this.status,
    required this.created_at,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) =>
      _$BankModelFromJson(json);
}
