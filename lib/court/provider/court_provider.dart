import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/court/repository/court_repository.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';

part 'court_provider.g.dart';
final searchProvider = StateProvider.autoDispose<String>((ref) => '');

@riverpod
Future<BaseModel> courtList(CourtListRef ref) async {
  final repository = ref.watch(courtRepositoryProvider);
  final param = ref.watch(gameFormProvider).court.address;
  return await repository.getCourtList(search: param).then<BaseModel>((value) {
    logger.i(value);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

// @riverpod
// class CourtSearch extends _$CourtSearch {
//   @override
//   BaseModel build() {
//     search(page: 1);
//     return LoadingModel();
//   }
//
//   Future<void> search({required int page}) async {
//     state = LoadingModel();
//     final repository = ref.watch(courtRepositoryProvider);
//     final search = ref.watch(searchProvider);
//     repository.getCourtList(search: search, page: page).then((value) {
//       logger.i(value);
//       state = value;
//     }).catchError((e) {
//       final error = ErrorModel.respToError(e);
//       logger.e(
//           'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
//       state = error;
//     });
//   }
// }
