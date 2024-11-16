import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/kakaopay/repository/pay_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../game/provider/game_provider.dart';
import '../model/pay_model.dart';
import '../param/boot_pay_approve_param.dart';

part 'pay_provider.g.dart';

@Riverpod()
Future<BaseModel> readyPay(ReadyPayRef ref,
    {required int gameId, required PaymentMethodType type}) async {
  final repository = ref.watch(payRepositoryProvider);

  return repository
      .readyPay(gameId: gameId, type: type)
      .then<BaseModel>((value) async {
    final model = value.data!;
    switch (type) {
      case PaymentMethodType.kakao_pay:
        model as PayReadyModel;
        final url = model.next_redirect_mobile_url;
        logger.i('readyPay url = $url!');
        break;
      case PaymentMethodType.empty_pay:
        ref
            .read(gameDetailProvider(gameId: gameId).notifier)
            .get(gameId: gameId);

        break;
      default:
        break;
    }
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@Riverpod()
Future<BaseModel> approvalPay(ApprovalPayRef ref,
    {required int requestId, required String pgToken}) async {
  final repository = ref.watch(payRepositoryProvider);
  return repository
      .approvalPay(pgToken: pgToken, requestId: requestId)
      .then<BaseModel>((value) async {
    logger.i('approvalPay = !');
    final model = value.data!;

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@Riverpod()
Future<BaseModel> requestBootPay(RequestBootPayRef ref,
    {required int gameId, required PaymentMethodType paymentMethod}) async {
  final repository = ref.watch(payRepositoryProvider);
  return repository
      .requestBootPay(gameId: gameId, paymentMethod: paymentMethod)
      .then<BaseModel>((value) async {
    logger.i('requestBootPay!');
    final model = value.data!;

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}


@Riverpod()
Future<BaseModel> approveBootPay(ApproveBootPayRef ref,
    {required BootPayApproveParam param }) async {
  final repository = ref.watch(payRepositoryProvider);
  return repository
      .approveBootPay(param)
      .then<BaseModel>((value) async {
    logger.i('requestBootPay!');
    final model = value.data!;

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    print( 'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
