import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../param/boot_pay_approve_param.dart';
import '../param/pay_request_param.dart';
import '../repository/pay_repository.dart';

part 'pay_provider.g.dart';

@Riverpod()
Future<BaseModel> readyPay(Ref ref,
    {required PayRequestParam param}) async {
  final repository = ref.watch(payRepositoryProvider);

  return repository
      .requestBootPay(param: param)
      .then<BaseModel>((value) async {
    final model = value.data!;
    // switch (type) {
    //   case PaymentMethodType.empty_pay:
    //     ref
    //         .read(gameDetailProvider(gameId: gameId).notifier)
    //         .get(gameId: gameId);
    //     break;
    //   default:
    //     model as BasePaymentRequestResponse;
    //     final orderId = model.orderId;
    //     logger.i('readyPay orderId = $orderId!');
    //     break;
    // }
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
//
// @Riverpod()
// Future<BaseModel> approvalPay(ApprovalPayRef ref,
//     {required int requestId, required String pgToken}) async {
//   final repository = ref.watch(payRepositoryProvider);
//   return repository
//       .approvalPay(pgToken: pgToken, requestId: requestId)
//       .then<BaseModel>((value) async {
//     logger.i('approvalPay = !');
//     final model = value.data!;
//
//     return value;
//   }).catchError((e) {
//     final error = ErrorModel.respToError(e);
//     logger.e(
//         'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
//     return error;
//   });
// }

// @Riverpod()
// Future<BaseModel> requestBootPay(RequestBootPayRef ref,
//     {required int gameId}) async {
//   final repository = ref.watch(payRepositoryProvider);
//   return repository
//       .requestBootPay(gameId: gameId)
//       .then<BaseModel>((value) async {
//     logger.i('requestBootPay!');
//     final model = value.data!;
//
//     return value;
//   }).catchError((e) {
//     final error = ErrorModel.respToError(e);
//     logger.e(
//         'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
//     return error;
//   });
// }

@Riverpod()
Future<BaseModel> approveBootPay(ApproveBootPayRef ref,
    {required BootPayApproveParam param}) async {
  final repository = ref.watch(payRepositoryProvider);
  return repository.approveBootPay(param).then<BaseModel>((value) async {
    logger.i('requestBootPay!');
    final model = value.data!;

    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    print(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
