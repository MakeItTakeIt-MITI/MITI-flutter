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
  final TransferType? status;

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
  final BankType? account_bank;
  final String account_holder;
  final String account_number;
  @JsonKey(includeToJson: false)
  final List<bool> checkBoxes;

  BankTransferParam({
    required this.amount,
    required this.account_bank,
    required this.account_holder,
    required this.account_number,
    required this.checkBoxes,
  });

  BankTransferParam copyWith({
    int? amount,
    BankType? account_bank,
    String? account_holder,
    String? account_number,
    List<bool>? checkBoxes,
  }) {
    return BankTransferParam(
      amount: amount ?? this.amount,
      account_bank: account_bank ?? this.account_bank,
      account_holder: account_holder ?? this.account_holder,
      account_number: account_number ?? this.account_number,
      checkBoxes: checkBoxes ?? this.checkBoxes,
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
