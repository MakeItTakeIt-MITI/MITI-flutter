import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/common/model/model_id.dart';

part 'base_bank_transfer_response.g.dart';

@JsonSerializable()
class BaseBankTransferResponse extends IModelWithId {
  @JsonKey(name: 'transfer_status')
  final BankTransferStatusType transferStatus;

  final int amount;

  @JsonKey(name: 'account_bank')
  final BankType accountBank;

  @JsonKey(name: 'account_holder')
  final String accountHolder;

  @JsonKey(name: 'account_number')
  final String accountNumber;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'transferred_at')
  final DateTime? transferredAt;

  BaseBankTransferResponse({
    required super.id,
    required this.transferStatus,
    required this.amount,
    required this.accountBank,
    required this.accountHolder,
    required this.accountNumber,
    required this.createdAt,
    required this.transferredAt,
  });

  factory BaseBankTransferResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseBankTransferResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseBankTransferResponseToJson(this);

  BaseBankTransferResponse copyWith({
    int? id,
    BankTransferStatusType? transferStatus,
    int? amount,
    BankType? accountBank,
    String? accountHolder,
    String? accountNumber,
    DateTime? createdAt,
    DateTime? transferredAt,
  }) {
    return BaseBankTransferResponse(
      id: id ?? this.id,
      transferStatus: transferStatus ?? this.transferStatus,
      amount: amount ?? this.amount,
      accountBank: accountBank ?? this.accountBank,
      accountHolder: accountHolder ?? this.accountHolder,
      accountNumber: accountNumber ?? this.accountNumber,
      createdAt: createdAt ?? this.createdAt,
      transferredAt: transferredAt ?? this.transferredAt,
    );
  }
}
