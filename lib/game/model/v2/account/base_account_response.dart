import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/model_id.dart';

import '../../../../common/model/entity_enum.dart';

part 'base_account_response.g.dart';

@JsonSerializable()
class BaseAccountResponse extends IModelWithId {

  @JsonKey(name: 'account_type')
  final AccountType accountType;

  @JsonKey(name: 'status')
  final AccountStatusType status;

  @JsonKey(name: 'balance')
  final int balance;

  @JsonKey(name: 'transfer_waiting_amount')
  final int transferWaitingAmount;

  @JsonKey(name: 'transfer_requestable_amount')
  final int transferRequestableAmount;

  BaseAccountResponse({
    required super.id,
    required this.accountType,
    required this.status,
    required this.balance,
    required this.transferWaitingAmount,
    required this.transferRequestableAmount,
  });

  factory BaseAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BaseAccountResponseToJson(this);

  BaseAccountResponse copyWith({
    int? id,
    AccountType? accountType,
    AccountStatusType? status,
    int? balance,
    int? transferWaitingAmount,
    int? transferRequestableAmount,
  }) {
    return BaseAccountResponse(
      id: id ?? this.id,
      accountType: accountType ?? this.accountType,
      status: status ?? this.status,
      balance: balance ?? this.balance,
      transferWaitingAmount: transferWaitingAmount ??
          this.transferWaitingAmount,
      transferRequestableAmount: transferRequestableAmount ??
          this.transferRequestableAmount,
    );
  }
}
