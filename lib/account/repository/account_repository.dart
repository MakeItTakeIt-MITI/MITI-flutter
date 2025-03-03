import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/dio_interceptor.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/account/base_account_response.dart';
import '../../game/model/v2/account/base_bank_transfer_response.dart';
import '../../game/model/v2/settlement/game_settlement_detail_response.dart';
import '../../game/model/v2/settlement/game_settlement_response.dart';
import '../model/account_model.dart';
import '../model/transfer_model.dart';
import '../param/account_param.dart';

part 'account_repository.g.dart';

final settlementPaginationRepositoryProvider =
    Provider<SettlementPaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return SettlementPaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class SettlementPaginationRepository extends IBasePaginationRepository<
    GameSettlementResponse, SettlementPaginationParam> {
  factory SettlementPaginationRepository(Dio dio, {String baseUrl}) =
      _SettlementPaginationRepository;

  /// 정산 내역 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/game-hosting-settlements')
  Future<ResponseModel<PaginationModel<GameSettlementResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() SettlementPaginationParam? param,
    @Path('userId') int? path,
  });

  /// 정산 내역 상세 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/game-hosting-settlements/{settlementId}')
  Future<ResponseModel<GameSettlementDetailResponse>> getSettlement({
    @Path('userId') required int userId,
    @Path('settlementId') required int settlementId,
  });
}

final bankTransferPaginationRepositoryProvider =
    Provider<BankTransferPaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return BankTransferPaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class BankTransferPaginationRepository
    extends IBasePaginationRepository<BaseBankTransferResponse,
        BankTransferPaginationParam> {
  factory BankTransferPaginationRepository(Dio dio, {String baseUrl}) =
      _BankTransferPaginationRepository;

  /// 이체 요청 내역 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/transfer-requests')
  Future<ResponseModel<PaginationModel<BaseBankTransferResponse>>> paginate({
    @Queries() required PaginationParam paginationParams,
    @Queries() BankTransferPaginationParam? param,
    @Path('userId') int? path,
  });

  @Headers({'token': 'true'})
  @POST('/users/{userId}/accounts/transfer-requests')
  Future<ResponseModel<BaseBankTransferResponse>> requestTransfer({
    @Path('userId') required int userId,
    @Body() required BankTransferParam param,
  });

  /// 사용자 계좌 정보 조회 API
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts')
  Future<ResponseModel<BaseAccountResponse>> getAccountInfo({
    @Path('userId') required int userId,
  });
}
