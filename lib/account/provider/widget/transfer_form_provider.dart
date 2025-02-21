import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/model/default_model.dart';
import '../../../common/model/entity_enum.dart';
import '../../../report/model/agreement_policy_model.dart';
import '../../../report/provider/report_provider.dart';
import '../../../util/util.dart';
import '../../param/account_param.dart';

part 'transfer_form_provider.g.dart';

@riverpod
class TransferForm extends _$TransferForm {
  @override
  BankTransferParam build() {
    final result = ref.watch(
        agreementPolicyProvider(type: AgreementRequestType.transferRequest));
    if (result is ResponseListModel<AgreementPolicyModel>) {
      // final model = result as
      final List<bool> checkBoxes =
          List.generate(result.data!.length, (e) => false);
      return BankTransferParam(
          amount: 0,
          account_bank: null,
          account_holder: '',
          account_number: '',
          checkBoxes: checkBoxes);
    }

    return BankTransferParam(
        amount: 0,
        account_bank: null,
        account_holder: '',
        account_number: '',
        checkBoxes: const [false]);
  }

  void update({
    int? amount,
    BankType? account_bank,
    String? account_holder,
    String? account_number,
    List<bool>? checkBoxes,
  }) {
    state = state.copyWith(
      amount: amount,
      account_bank: account_bank,
      account_holder: account_holder,
      account_number: account_number,
      checkBoxes: checkBoxes,
    );
  }

  List<bool> onCheck(int idx) {
    final checkBoxes = state.checkBoxes;
    checkBoxes[idx] = !checkBoxes[idx];
    update(checkBoxes: checkBoxes.toList());
    return state.checkBoxes;
  }

  bool valid(int amount) {
    return state.amount <= amount &&
        state.amount > 10000 &&
        ValidRegExp.accountNumber(state.account_number) &&
        state.account_holder.isNotEmpty &&
        state.account_bank != null;
  }
}
