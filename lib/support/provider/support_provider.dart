import 'dart:developer';

import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/support/provider/widget/support_form_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../account/model/transfer_model.dart';
import '../../account/param/account_param.dart';
import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/param/pagination_param.dart';
import '../../common/provider/pagination_provider.dart';
import '../model/support_model.dart';
import '../param/support_param.dart';
import '../repository/support_repository.dart';

part 'support_provider.g.dart';

final supportPageProvider = StateNotifierProvider.family.autoDispose<
    SupportPageStateNotifier,
    BaseModel,
    PaginationStateParam<SupportParam>>((ref, param) {
  final repository = ref.watch(supportPRepositoryProvider);
  return SupportPageStateNotifier(
    repository: repository,
    pageParams: const PaginationParam(
      page: 1,
    ),
    param: param.param,
    path: param.path,
  );
});

class SupportPageStateNotifier
    extends PaginationProvider<SupportModel, SupportParam, SupportPRepository> {
  SupportPageStateNotifier({
    required super.repository,
    required super.pageParams,
    super.param,
    super.path,
  });
}

@riverpod
Future<BaseModel> supportCreate(SupportCreateRef ref) async {
  final repository = ref.watch(supportPRepositoryProvider);
  final param = ref.watch(supportFormProvider);
  final userId = ref.read(authProvider)!.id!;
  return await repository
      .createSupport(param: param, userId: userId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref
        .read(supportPageProvider(PaginationStateParam(path: userId)).notifier)
        .paginate(
            paginationParams: const PaginationParam(page: 1),
            path: userId,
            forceRefetch: true);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
class Question extends _$Question {
  @override
  BaseModel build({required int questionId}) {
    getQuestion(questionId: questionId);
    return LoadingModel();
  }

  void getQuestion({required int questionId}) {
    final repository = ref.watch(supportPRepositoryProvider);
    final userId = ref.read(authProvider)!.id!;
    repository
        .getQuestion(questionId: questionId, userId: userId)
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
class FAQ extends _$FAQ {
  final searchDebounce = Debouncer(const Duration(milliseconds: 300),
      initialValue: FAQParam(search: ''), checkEquality: false);

  @override
  BaseModel build() {
    searchDebounce.values.listen((FAQParam state) {
      log('throttle!!');
      get(search: state.search);
    });
    get();

    return LoadingModel();
  }

  void updateDebounce({required FAQParam param}) {
    searchDebounce.setValue(param);
  }

  void get({String? search}) {
    final repository = ref.watch(supportPRepositoryProvider);
    repository.getFAQ(search: search).then((value) {
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
class Guide extends _$Guide {
  @override
  BaseModel build() {
    getQuestion();
    return LoadingModel();
  }

  void getQuestion() {
    final repository = ref.watch(supportPRepositoryProvider);
    repository.getGuide().then((value) {
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
