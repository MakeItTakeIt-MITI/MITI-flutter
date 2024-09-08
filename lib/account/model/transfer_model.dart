import 'package:json_annotation/json_annotation.dart';

import '../../common/model/entity_enum.dart';
import '../../common/model/model_id.dart';

part 'transfer_model.g.dart';

@JsonSerializable()
class TransferModel extends IModelWithId {
  final int amount;
  @JsonKey(name: 'account_bank')
  final BankType accountBank;
  @JsonKey(name: 'account_holder')
  final String accountHolder;
  @JsonKey(name: 'account_number')
  final String accountNumber;
  @JsonKey(name: 'transfer_status')
  final TransferType transferStatus;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'transferred_at')
  final DateTime? transferredAt;

  TransferModel({
    required super.id,
    required this.amount,
    required this.accountBank,
    required this.accountHolder,
    required this.accountNumber,
    required this.transferStatus,
    required this.createdAt,
    this.transferredAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) =>
      _$TransferModelFromJson(json);
}
