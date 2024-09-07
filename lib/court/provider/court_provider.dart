import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:miti/court/repository/court_repository.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../game/model/game_model.dart';
import '../model/court_model.dart';

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

@Riverpod(keepAlive: false)
class CourtDetail extends _$CourtDetail {
  @override
  BaseModel build({required int courtId}) {
    getDetail(courtId: courtId);
    return LoadingModel();
  }

  Future<void> getDetail({required int courtId}) async {
    state = LoadingModel();
    final repository = ref.watch(courtRepositoryProvider);
    repository.getDetail(courtId: courtId).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  Map<String, List<GameHostModel>> groupAndSortByStartDate() {
    // Map으로 그룹화
    final models =
        (state as ResponseModel<CourtDetailModel>).data!.soonest_games;
    Map<String, List<GameHostModel>> groupedMap = {};

    for (var model in models) {
      // 각 모델의 startdate를 키로 사용
      if (!groupedMap.containsKey(model.startdate)) {
        groupedMap[model.startdate] = [];
      }
      groupedMap[model.startdate]!.add(model);
    }

    // 각 그룹을 starttime으로 내림차순 정렬
    groupedMap.forEach((key, value) {
      value.sort((a, b) {
        // starttime을 비교하여 내림차순으로 정렬
        final timeFormat = DateFormat('HH:mm'); // 시간 형식 지정
        final timeA = timeFormat.parse(a.starttime);
        final timeB = timeFormat.parse(b.starttime);
        return timeB.compareTo(timeA); // 내림차순 정렬
      });
    });

    return groupedMap;
  }
}
