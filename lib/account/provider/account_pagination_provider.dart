import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../../court/param/court_pagination_param.dart';
import '../model/account_model.dart';
import '../model/bank_model.dart';
import '../param/account_param.dart';
import '../repository/account_repository.dart';

final settlementPageProvider = StateNotifierProvider.family.autoDispose<
    SettlementPageStateNotifier,
    BaseModel,
    PaginationStateParam<SettlementPaginationParam>>((ref, param) {
  final repository = ref.watch(settlementPaginationRepositoryProvider);
  return SettlementPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class SettlementPageStateNotifier extends PaginationProvider<SettlementModel,
    SettlementPaginationParam, SettlementPaginationRepository> {
  SettlementPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}

final bankTransferPageProvider = StateNotifierProvider.family.autoDispose<
    BankTransferPageStateNotifier,
    BaseModel,
    PaginationStateParam<BankTransferPaginationParam>>((ref, param) {
  final repository = ref.watch(bankTransferPaginationRepositoryProvider);
  return BankTransferPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class BankTransferPageStateNotifier extends PaginationProvider<BankModel,
    BankTransferPaginationParam, BankTransferPaginationRepository> {
  BankTransferPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}