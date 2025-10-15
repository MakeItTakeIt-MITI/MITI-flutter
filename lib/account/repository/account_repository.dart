import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';

import '../../common/model/cursor_model.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/repository/base_pagination_repository.dart';
import '../../dio/provider/dio_provider.dart';
import '../../game/model/v2/account/base_account_response.dart';
import '../../game/model/v2/account/base_bank_transfer_response.dart';
import '../../game/model/v2/settlement/game_settlement_detail_response.dart';
import '../../game/model/v2/settlement/game_settlement_response.dart';
import '../param/account_param.dart';

part 'account_repository.g.dart';

final settlementCursorPaginationRepositoryProvider =
    Provider<SettlementCursorPaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return SettlementCursorPaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class SettlementCursorPaginationRepository extends IBaseCursorPaginationRepository<
    GameSettlementResponse, SettlementPaginationParam> {
  factory SettlementCursorPaginationRepository(Dio dio, {String baseUrl}) =
      _SettlementCursorPaginationRepository;

  /// 정산 내역 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/game-hosting-settlements')
  Future<ResponseModel<CursorPaginationModel<GameSettlementResponse>>> paginate({
    @Queries() required CursorPaginationParam cursorPaginationParams,
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

final bankTransferCursorPaginationRepositoryProvider =
    Provider<BankTransferCursorPaginationRepository>((ref) {
  final baseUrl =
      dotenv.get('API_URL', fallback: 'https://api.makeittakeit.kr');
  final dio = ref.watch(dioProvider);
  return BankTransferCursorPaginationRepository(dio, baseUrl: baseUrl);
});

@RestApi()
abstract class BankTransferCursorPaginationRepository
    extends IBaseCursorPaginationRepository<BaseBankTransferResponse,
        BankTransferPaginationParam> {
  factory BankTransferCursorPaginationRepository(Dio dio, {String baseUrl}) =
      _BankTransferCursorPaginationRepository;

  /// 이체 요청 내역 목록 조회 API
  @override
  @Headers({'token': 'true'})
  @GET('/users/{userId}/accounts/transfer-requests')
  Future<ResponseModel<CursorPaginationModel<BaseBankTransferResponse>>> paginate({
    @Queries() required CursorPaginationParam cursorPaginationParams,
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
