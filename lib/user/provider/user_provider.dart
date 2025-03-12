import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:miti/auth/provider/auth_provider.dart';
import 'package:miti/common/param/pagination_param.dart';
import 'package:miti/review/repository/review_repository.dart';
import 'package:miti/user/provider/user_form_provider.dart';
import 'package:miti/user/repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/model/auth_model.dart';
import '../../common/logger/custom_logger.dart';
import '../../common/model/default_model.dart';
import '../../common/model/entity_enum.dart';
import '../../game/model/game_model.dart';
import '../../review/model/v2/guest_review_response.dart';
import '../../review/model/v2/host_review_response.dart';
import '../model/user_model.dart';
import '../model/v2/user_info_response.dart';
import '../param/user_profile_param.dart';

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
class MyReview extends _$MyReview {
  @override
  BaseModel build(
      {required UserReviewType userReviewType,
      required int reviewId,
      required ReviewType reviewType}) {
    getReview(
      userReviewType: userReviewType,
      reviewId: reviewId,
      reviewType: reviewType,
    );
    return LoadingModel();
  }

  void getReview({
    required UserReviewType userReviewType,
    required int reviewId,
    required ReviewType reviewType,
  }) async {
    state = LoadingModel();
    final repository = ref.watch(reviewRepositoryProvider);
    final id = ref.read(authProvider)!.id!;

    late Future<ResponseModel<BaseReviewResponse>> futureResponse;

    if (reviewType == ReviewType.host_review &&
        userReviewType == UserReviewType.receive) {
      /// 받은 호스트 리뷰 상세 조회API
      futureResponse = repository.getReceivedHostReviewDetail(
          userId: id, reviewId: reviewId);
    } else if (reviewType == ReviewType.guest_review &&
        userReviewType == UserReviewType.receive) {
      /// 받은 게스트 리뷰 상세 조회 API
      futureResponse = repository.getReceivedGuestReviewDetail(
          userId: id, reviewId: reviewId);
    } else if (reviewType == ReviewType.host_review &&
        userReviewType == UserReviewType.written) {
      /// 작성 호스트 리뷰 상세 조회 API
      futureResponse =
          repository.getWrittenHostReviewDetail(userId: id, reviewId: reviewId);
    } else {
      /// 작성 호스트 리뷰 상세 조회 API
      futureResponse = repository.getWrittenGuestReviewDetail(
          userId: id, reviewId: reviewId);
    }

    futureResponse.then((value) {
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
    final newData = (state as ResponseModel<UserInfoResponse>)
        .data!
        .copyWith(nickname: newNickname);
    state = (state as ResponseModel<UserInfoResponse>).copyWith(data: newData);
  }
}

@Riverpod(keepAlive: true)
class UserProfile extends _$UserProfile {
  @override
  BaseModel build() {
    getInfo();
    return LoadingModel();
  }

  void getInfo() async {
    state = LoadingModel();
    final repository = ref.watch(userRepositoryProvider);
    final id = ref.read(authProvider)!.id!;
    await repository.getUserProfileInfo(userId: id).then((value) {
      logger.i(value);
      logger.i(value.data?.profileImageUrl);
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
Future<BaseModel> updateProfileInfo(UpdateProfileInfoRef ref) async {
  final userId = ref.watch(authProvider)!.id!;
  final param = ref.watch(userNicknameFormProvider);
  log("updateNickname!!");
  return await ref
      .watch(userRepositoryProvider)
      .updateUserProfileInfo(userId: userId, param: param)
      .then<BaseModel>((value) {
    logger.i(value);
    ref.read(userInfoProvider.notifier).updateNickname(param.nickname);
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
Future<BaseModel> resetProfileImage(ResetProfileImageRef ref) async {
  final userId = ref.watch(authProvider)!.id!;
  log("resetProfileImage!!");
  return await ref
      .watch(userRepositoryProvider)
      .resetProfileImage(userId: userId)
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

@riverpod
Future<BaseModel> updatePassword(
    UpdatePasswordRef ref, int userId, UserPasswordParam param) async {
  // final userId = ref.watch(authProvider)!.id!;
  // final param = ref.watch(userPasswordFormProvider);
  return await ref
      .watch(userRepositoryProvider)
      .updatePassword(userId: userId, param: param)
      .then<BaseModel>((value) {
    logger.i(value);
    // ref.read(userInfoProvider.notifier).getUserInfo();
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}

@riverpod
class PaymentDetail extends _$PaymentDetail {
  @override
  BaseModel build({required int paymentResultId}) {
    getDetail(paymentResultId: paymentResultId);
    return LoadingModel();
  }

  void getDetail({required int paymentResultId}) async {
    state = LoadingModel();
    final repository = ref.watch(userRepositoryProvider);
    final id = ref.read(authProvider)!.id!;
    await repository
        .getPaymentResultDetail(userId: id, paymentResultId: paymentResultId)
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
class PlayerProfile extends _$PlayerProfile {
  @override
  BaseModel build() {
    getInfo();
    return LoadingModel();
  }

  void getInfo() async {
    state = LoadingModel();
    final repository = ref.watch(userRepositoryProvider);
    final id = ref.read(authProvider)!.id!;
    await repository.getPlayerInfo(userId: id).then((value) {
      logger.i(value);
      state = value;
      ref
          .read(userPlayerProfileFormProvider.notifier)
          .updateByModel(value.data!.playerProfile);
    }).catchError((e) {
      final error = ErrorModel.respToError(e);
      logger.e(
          'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
      state = error;
    });
  }
}

@riverpod
Future<BaseModel> updatePlayerProfile(UpdatePlayerProfileRef ref) async {
  final userId = ref.watch(authProvider)!.id!;
  final param = ref.watch(userPlayerProfileFormProvider);

  return await ref
      .watch(userRepositoryProvider)
      .updatePlayerInfo(userId: userId, param: param)
      .then<BaseModel>((value) {
    logger.i(value);
    if(param.gender != null && param.enableGender){
      ref
          .read(userPlayerProfileFormProvider.notifier)
          .update(enableGender: false);
    }
    return value;
  }).catchError((e) {
    final error = ErrorModel.respToError(e);
    logger.e(
        'status_code = ${error.status_code}\nerror.error_code = ${error.error_code}\nmessage = ${error.message}\ndata = ${error.data}');
    return error;
  });
}
