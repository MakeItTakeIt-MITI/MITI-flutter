import 'package:dio/dio.dart' hide Headers;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../model/account_model.dart';
import '../model/transfer_model.dart';
import '../param/account_param.dart';

part 'account_repository.g.dart';

final settlementPaginationRepositoryProvider =
    Provider<SettlementPaginationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SettlementPaginationRepository(dio);
});

@RestApi(baseUrl: prodServerURL)
abstract class SettlementPaginationRepository extends IBasePaginationRepository<
    SettlementModel, SettlementPaginationParam> {
  factory SettlementPaginationRepository(Dio dio) =
      _SettlementPaginationRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/game-hosting-settlements')
  Future<ResponseModel<PaginationModel<SettlementModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() SettlementPaginationParam? param,
    @Path('userId') int? path,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/game-hosting-settlements/{settlementId}')
  Future<ResponseModel<SettlementDetailModel>> getSettlement({
    @Path('userId') required int userId,
    @Path('settlementId') required int settlementId,
  });
}

final bankTransferPaginationRepositoryProvider =
    Provider<BankTransferPaginationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BankTransferPaginationRepository(dio);
});

@RestApi(baseUrl: prodServerURL)
abstract class BankTransferPaginationRepository
    extends IBasePaginationRepository<TransferModel, BankTransferPaginationParam> {
  factory BankTransferPaginationRepository(Dio dio) =
      _BankTransferPaginationRepository;

  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/transfer-requests')
  Future<ResponseModel<PaginationModel<TransferModel>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() BankTransferPaginationParam? param,
    @Path('userId') int? path,
  });

  @Headers({'token': 'true'})
  @POST('/users/{userId}/accounts/transfer-requests')
  Future<ResponseModel<TransferModel>> requestTransfer({
    @Path('userId') required int userId,
    @Body() required BankTransferParam param,
  });

  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts')
  Future<ResponseModel<AccountDetailModel>> getAccountInfo({
    @Path('userId') required int userId,
  });
}
