import 'package:intl/intl.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/model/auth_model.dart';
import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../model/user_model.dart';

part 'user_provider.g.dart';

enum UserGameType {
  host,
  participation,
}

enum UserReviewType {
  written('written'),
  receive('receive');

  const UserReviewType(this.value);

  final String value;

  static UserReviewType stringToEnum({required String value}) {
    return UserReviewType.values.firstWhere((e) => e.value == value);
  }
}

@Riverpod(keepAlive: false)
class Review extends _$Review {
  @override
  BaseModel build({required UserReviewType type, required int reviewId}) {
    getReviews(type: type, reviewId: reviewId);
    return LoadingModel();
  }

  void getReviews({
    required UserReviewType type,
    required int reviewId,
  }) async {
    state = LoadingModel();
    final repository = ref.watch(userRepositoryProvider);
    final id = ref.read(authProvider)!.id!;
    switch (type) {
      case UserReviewType.written:
        state =
            await repository.getWrittenReview(userId: id, reviewId: reviewId);
        break;
      default:
        state =
            await repository.getReceiveReview(userId: id, reviewId: reviewId);
        break;
    }
  }
}

@riverpod
class UserInfo extends _$UserInfo {
  @override
  BaseModel build() {
    getUserInfo();
    return LoadingModel();
  }

  void getUserInfo() async {
    state = LoadingModel();
    final repository = ref.watch(userRepositoryProvider);
    final id = ref.read(authProvider)!.id!;
    await repository.getUserInfo(userId: id).then((value) {
      logger.i(value);
      state = value;
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }

  void updateNickname(String newNickname) {
    final newData = (state as ResponseModel<UserModel>)
        .data!
        .copyWith(nickname: newNickname);
    state = (state as ResponseModel<UserModel>).copyWith(data: newData);
  }
}

@riverpod
Future<BaseModel> deleteUser(DeleteUserRef ref) async {
  final userId = ref.watch(authProvider)!.id!;
  return await ref
      .watch(userRepositoryProvider)
      .deleteUser(userId: userId)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(authProvider.notifier).logout();
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> updateNickname(UpdateNicknameRef ref) async {
  final userId = ref.watch(authProvider)!.id!;
  final param = ref.watch(userNicknameFormProvider);
  return await ref
      .watch(userRepositoryProvider)
      .updateNickname(userId: userId, param: param)
      .then<BaseModel>((value) {
    logger.i(value);
    final result = ref.watch(userInfoProvider);

    // final model = (result as ResponseModel<UserModel>).data!;

    ref.read(userInfoProvider.notifier).updateNickname(param.nickname!);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> updatePassword(UpdatePasswordRef ref) async {
  final userId = ref.watch(authProvider)!.id!;
  final param = ref.watch(userPasswordFormProvider);
  return await ref
      .watch(userRepositoryProvider)
      .updatePassword(userId: userId, param: param)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(userInfoProvider.notifier).getUserInfo();
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
