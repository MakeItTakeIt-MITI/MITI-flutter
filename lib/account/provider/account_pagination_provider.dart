import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/cursor_pagination_provider.dart';
import '../../game/model/v2/account/base_bank_transfer_response.dart';
import '../../game/model/v2/settlement/game_settlement_response.dart';
import '../param/account_param.dart';
import '../repository/account_repository.dart';

final settlementPageProvider = StateNotifierProvider.family.autoDispose<
    SettlementPageStateNotifier,
    BaseModel,
    PaginationStateParam<SettlementPaginationParam>>((ref, param) {
  final repository = ref.watch(settlementCursorPaginationRepositoryProvider);
  return SettlementPageStateNotifier(
    repository: repository,
    cursorPageParams: const CursorPaginationParam(),
    param: param.param,
    path: param.path,
  );
});

class SettlementPageStateNotifier extends CursorPaginationProvider<
    GameSettlementResponse,
    SettlementPaginationParam,
    SettlementCursorPaginationRepository> {
  SettlementPageStateNotifier({
    required super.repository,
    required super.cursorPageParams,
    super.param,
    super.path,
  });
}

final bankTransferPageProvider = StateNotifierProvider.family.autoDispose<
    BankTransferPageStateNotifier,
    BaseModel,
    PaginationStateParam<BankTransferPaginationParam>>((ref, param) {
  final repository = ref.watch(bankTransferCursorPaginationRepositoryProvider);
  return BankTransferPageStateNotifier(
    repository: repository,
    cursorPageParams: const CursorPaginationParam(),
    param: param.param,
    path: param.path,
  );
});

class BankTransferPageStateNotifier extends CursorPaginationProvider<
    BaseBankTransferResponse,
    BankTransferPaginationParam,
    BankTransferCursorPaginationRepository> {
  BankTransferPageStateNotifier({
    required super.repository,
    required super.cursorPageParams,
    super.param,
    super.path,
  });
}
