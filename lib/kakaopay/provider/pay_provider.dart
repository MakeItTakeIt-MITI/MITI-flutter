import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/kakaopay/repository/pay_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'pay_provider.g.dart';

@Riverpod()
Future<BaseModel> readyPay(ReadyPayRef ref, {required int gameId}) async {
  final repository = ref.watch(payRepositoryProvider);
  return repository.readyPay(gameId: gameId).then<BaseModel>((value) async {
    final model = value.data!;
    final url = model.next_redirect_mobile_url;
    logger.i('readyPay url = $url!');

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
