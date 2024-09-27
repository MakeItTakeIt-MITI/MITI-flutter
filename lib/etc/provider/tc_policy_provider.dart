import 'package:miti/etc/repository/tc_policy_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'tc_policy_provider.g.dart';

@riverpod
class TcPolicyList extends _$TcPolicyList {
  @override
  BaseModel build() {
    get();
    return LoadingModel();
  }

  void get() async {
    final repository = ref.read(tcPolicyRepositoryProvider);
    await repository.getPolicyList().then((value) {
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
class TcPolicy extends _$TcPolicy {
  @override
  BaseModel build({required int policyId}) {
    get(policyId: policyId);
    return LoadingModel();
  }

  void get({required int policyId}) async {
    final repository = ref.read(tcPolicyRepositoryProvider);
    await repository.getDetail(policyId: policyId).then((value) {
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
