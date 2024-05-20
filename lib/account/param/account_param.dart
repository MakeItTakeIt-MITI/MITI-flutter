import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../common/param/pagination_param.dart';

part 'account_param.g.dart';

@JsonSerializable()
class SettlementPaginationParam extends DefaultParam {
  final SettlementType? status;

  SettlementPaginationParam({
    this.status,
  });

  @override
  List<Object?> get props => [status];

  @override
  Map<String, dynamic> toJson() => _$SettlementPaginationParamToJson(this);

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class BankTransferPaginationParam extends DefaultParam {
  final BankType? status;

  BankTransferPaginationParam({
    this.status,
  });

  @override
  List<Object?> get props => [status];

  @override
  Map<String, dynamic> toJson() => _$BankTransferPaginationParamToJson(this);

  @override
  bool? get stringify => true;
}

@JsonSerializable()
class BankTransferParam extends DefaultParam {
  final int amount;
  final String account_bank;
  final String account_holder;
  final String account_number;

  BankTransferParam({
    required this.amount,
    required this.account_bank,
    required this.account_holder,
    required this.account_number,
  });

  BankTransferParam copyWith({
    int? amount,
    String? account_bank,
    String? account_holder,
    String? account_number,
  }) {
    return BankTransferParam(
      amount: amount ?? this.amount,
      account_bank: account_bank ?? this.account_bank,
      account_holder: account_holder ?? this.account_holder,
      account_number: account_number ?? this.account_number,
    );
  }

  @override
  List<Object?> get props =>
      [amount, account_bank, account_holder, account_number];

  @override
  Map<String, dynamic> toJson() => _$BankTransferParamToJson(this);

  @override
  bool? get stringify => true;
}
