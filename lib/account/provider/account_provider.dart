import 'package:miti/account/provider/widget/transfer_form_provider.dart';
import 'package:miti/account/repository/account_repository.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';

part 'account_provider.g.dart';

@riverpod
class Settlement extends _$Settlement {
  @override
  BaseModel build({required int userId, required int settlementId}) {
    getSettlement(userId: userId, settlementId: settlementId);
    return LoadingModel();
  }

  void getSettlement({required int userId, required int settlementId}) {
    final repository = ref.watch(settlementPaginationRepositoryProvider);
    repository
        .getSettlement(userId: userId, settlementId: settlementId)
        .then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@riverpod
class Account extends _$Account {
  @override
  BaseModel build() {
    getAccountInfo();
    return LoadingModel();
  }

  void getAccountInfo() {
    final repository = ref.watch(bankTransferPaginationRepositoryProvider);
    final userId = ref.read(authProvider)!.id!;
    repository.getAccountInfo(userId: userId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@riverpod
Future<BaseModel> requestTransfer(RequestTransferRef ref) async {
  final repository = ref.watch(bankTransferPaginationRepositoryProvider);
  final userId = ref.watch(authProvider)!.id!;
  final param = ref.watch(transferFormProvider);

  return await repository
      .requestTransfer(userId: userId, param: param)
      .then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
