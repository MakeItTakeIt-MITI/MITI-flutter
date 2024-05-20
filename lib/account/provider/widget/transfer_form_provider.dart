import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../util/util.dart';
import '../../param/account_param.dart';

part 'transfer_form_provider.g.dart';

@riverpod
class TransferForm extends _$TransferForm {
  @override
  BankTransferParam build() {
    return BankTransferParam(
        amount: 0, account_bank: '', account_holder: '', account_number: '');
  }

  void update({
    int? amount,
    String? account_bank,
    String? account_holder,
    String? account_number,
  }) {
    state = state.copyWith(
      amount: amount,
      account_bank: account_bank,
      account_holder: account_holder,
      account_number: account_number,
    );
  }

  bool valid(int amount) {
    return state.amount <= amount && state.amount > 10000 &&
        ValidRegExp.accountNumber(state.account_number) &&
        state.account_holder.isNotEmpty &&
        state.account_bank.isNotEmpty;
  }
}
