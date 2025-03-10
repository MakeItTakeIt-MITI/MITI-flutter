import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/model/v2/game/game_response.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:miti/report/model/agreement_policy_model.dart';
import 'package:miti/report/provider/report_provider.dart';
import 'package:miti/util/util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/component/custom_text_form_field.dart';
import '../../../common/model/entity_enum.dart';
import '../../model/game_recent_host_model.dart';
import '../../model/v2/game/base_game_with_court_response.dart';
import '../../model/v2/game/game_with_court_response.dart';

part 'game_form_provider.g.dart';

enum InteractionType {
  normal,
  email,
  password,
  date,
  nickname,
  newPassword,
  newPasswordCheck
}

final interactionDescProvider = StateProvider.autoDispose
    .family<InteractionDesc?, InteractionType>((ref, interactionType) => null);

@riverpod
class GameForm extends _$GameForm {
  @override
  GameCreateParam build() {
    // final result = ref
    //     .watch(agreementPolicyProvider(type: AgreementRequestType.game_hosting));
    // if (result is ResponseListModel<AgreementPolicyModel>) {
    //   final List<bool> checkBoxes =
    //       List.generate(result.data!.length + 1, (e) => false);
    //   return GameCreateParam(
    //     title: '',
    //     startdate: '',
    //     starttime: '',
    //     enddate: '',
    //     endtime: '',
    //     min_invitation: '',
    //     max_invitation: '',
    //     info: '',
    //     fee: '',
    //     court: const GameCourtParam(name: '', address: '', address_detail: ''),
    //     checkBoxes: checkBoxes,
    //   );
    // }
    return const GameCreateParam(
      title: '',
      startdate: '',
      starttime: '',
      enddate: '',
      endtime: '',
      min_invitation: '',
      max_invitation: '',
      info: '',
      fee: '',
      court: GameCourtParam(name: '', address: '', address_detail: ''),
      checkBoxes: [false, false, false, false],
    );
  }

  void selectGameHistory(
      {required GameWithCourtResponse model,
      required List<TextEditingController> textEditingControllers}) {
    GameCourtParam court = GameCourtParam(
      name: model.court.name ?? "미정",
      address: model.court.address,
      address_detail: model.court.addressDetail,
    );
    textEditingControllers[0].text = model.title;
    textEditingControllers[1].text = model.court.address;
    textEditingControllers[2].text = model.court.addressDetail ?? '';
    textEditingControllers[3].text = model.court.name ?? '미정';
    textEditingControllers[4].text = model.minInvitation.toString();
    textEditingControllers[5].text = model.maxInvitation.toString();
    textEditingControllers[6].text = model.fee.toString();
    textEditingControllers[7].text = model.info;

    state = state.copyWith(
      title: model.title,
      court: court,
      min_invitation: model.minInvitation.toString(),
      max_invitation: model.maxInvitation.toString(),
      info: model.info,
      fee: model.fee.toString(),
    );
  }

  void update({
    String? title,
    // DateTime? startDateTime,
    // DateTime? endDateTime,
    String? startdate,
    String? starttime,
    String? enddate,
    String? endtime,
    String? min_invitation,
    String? max_invitation,
    String? info,
    String? fee,
    GameCourtParam? court,
    List<bool>? checkBoxes,
  }) {
    if (fee != null) {
      fee = fee.replaceAll(',', '');
    }

    // if (startDateTime != null) {
    //   final dateFormat = DateFormat('yyyy-MM-dd');
    //   final timeFormat = DateFormat('HH:mm');
    //   startdate = dateFormat.format(startDateTime);
    //   starttime = timeFormat.format(startDateTime);
    // }
    // if (endDateTime != null) {
    //   final dateFormat = DateFormat('yyyy-MM-dd');
    //   final timeFormat = DateFormat('HH:mm');
    //   enddate = dateFormat.format(endDateTime);
    //   endtime = timeFormat.format(endDateTime);
    // }

    state = state.copyWith(
      title: title,
      startdate: startdate,
      starttime: starttime,
      enddate: enddate,
      endtime: endtime,
      min_invitation: min_invitation,
      max_invitation: max_invitation,
      info: info,
      fee: fee,
      court: court,
      checkBoxes: checkBoxes,
    );
  }

  void updateCheckBox(int idx) {
    List<bool> newCheckBoxes = state.checkBoxes.toList();
    newCheckBoxes[idx] = !newCheckBoxes[idx];
    if (idx == 0) {
      newCheckBoxes.fillRange(0, newCheckBoxes.length, newCheckBoxes[0]);
    } else {
      final isAllChecked = newCheckBoxes.sublist(1).contains(false);
      if (!isAllChecked) {
        newCheckBoxes.fillRange(0, newCheckBoxes.length, true);
      } else {
        newCheckBoxes[0] = false;
      }
    }
    state = state.copyWith(checkBoxes: newCheckBoxes);
    formValid();
  }

  bool validInvitation() {
    if (state.min_invitation.isNotEmpty && state.max_invitation.isNotEmpty) {
      if (int.parse(state.min_invitation) >= int.parse(state.max_invitation)) {
        return false;
      } else if (int.parse(state.max_invitation) <= 0) {
        return false;
      } else {
        return true;
      }
    }
    return false;
  }

  bool validFee() {
    if (state.fee.isNotEmpty) {
      final fee = int.parse(state.fee);
      if (!(fee == 0 || fee >= 500)) {
        return false;
      }
    }
    return true;
  }

  bool validDateTime() {
    if (state.startdate.isNotEmpty &&
        state.starttime.isNotEmpty &&
        state.enddate.isNotEmpty &&
        state.endtime.isNotEmpty) {
      DateTime startDateTime =
          DateTime.parse("${state.startdate} ${state.starttime}:00");
      DateTime endDateTime =
          DateTime.parse("${state.enddate} ${state.endtime}:00");
      log('startDateTime = $startDateTime endDateTime = $endDateTime');
      final validNum = startDateTime.compareTo(endDateTime);
      if (validNum < 0) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool validDatetimeInteraction() {
    if (state.startdate.isNotEmpty &&
        state.starttime.isNotEmpty &&
        state.enddate.isNotEmpty &&
        state.endtime.isNotEmpty) {
      DateTime startDateTime =
          DateTime.parse("${state.startdate} ${state.starttime}:00");
      DateTime endDateTime =
          DateTime.parse("${state.enddate} ${state.endtime}:00");
      DateTime currentDateTime = DateTime.now();

      // Checking if startDateTime is equal to or after endDateTime
      if (startDateTime.isAtSameMomentAs(endDateTime) ||
          startDateTime.isAfter(endDateTime)) {
        // ref.read(interactionDescProvider(InteractionType.date).notifier).update(
        //     (state) => InteractionDesc(
        //         isSuccess: false, desc: '시작 시간이 종료 시간보다 같거나 이후일 수 없습니다.'));
        return false;
      } else if (startDateTime.isBefore(currentDateTime) &&
          endDateTime.isBefore(currentDateTime)) {
        // ref.read(interactionDescProvider(InteractionType.date).notifier).update(
        //     (state) => InteractionDesc(
        //         isSuccess: false, desc: '경기 시간이 현재 시간보다 이전일 수 없습니다.'));
        return false;
      } else if (currentDateTime.isAfter(startDateTime) &&
          currentDateTime.isBefore(endDateTime)) {
        // ref.read(interactionDescProvider(InteractionType.date).notifier).update(
        //     (state) => InteractionDesc(
        //         isSuccess: false, desc: '현재 시간이 경시 시간 사이에 있을 수 없습니다.'));
        return false;
      } else {
        // ref
        //     .read(interactionDescProvider(InteractionType.date).notifier)
        //     .update((state) => null);
        return true;
      }
    }
    // ref
    //     .read(interactionDescProvider(InteractionType.date).notifier)
    //     .update((state) => null);
    return false;
  }

  bool formValid() {
    log('validInvitation() = ${validInvitation()} validDatetime() = ${validDateTime()}');
    final formValid = state.title.isNotEmpty &
        ValidRegExp.gameAddress(state.court.address) &
        // ValidRegExp.gameAddressDetail(state.court.address_detail) &
        ValidRegExp.courtName(state.court.name);
    log("formvalid = $formValid");
    return validFee() && validInvitation() && validDateTime() && formValid;
  }
}

@riverpod
class ReviewForm extends _$ReviewForm {
  @override
  GameReviewParam build() {
    return const GameReviewParam(
      rating: 0,
      comment: '',
      tags: [],
    );
  }

  void updateRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void updateComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  void updateChip(PlayerReviewTagType chip) {
    if (state.tags.contains(chip)) {
      final newTags = state.tags.toList();
      newTags.remove(chip);
      state = state.copyWith(tags: newTags);
    } else {
      final newTags = state.tags.toList();
      newTags.add(chip);
      state = state.copyWith(tags: newTags);
    }
  }

  bool valid() {
    log('state.rating = ${state.rating}');
    // log('state.comment.isNotEmpty = ${state.comment.isNotEmpty}');
    return state.tags.length > 1;
  }
}

@riverpod
class GameParticipationForm extends _$GameParticipationForm {
  @override
  GameParticipationParam build(
      {required int gameId, required PaymentMethodType type}) {
    final result = ref.watch(
        agreementPolicyProvider(type: AgreementRequestType.game_participation));
    if (result is ResponseListModel<AgreementPolicyModel>) {
      final List<bool> checkBoxes =
          List.generate(result.data!.length, (e) => false);
      return GameParticipationParam(
          gameId: gameId, type: type, isCheckBoxes: checkBoxes);
    }
    return GameParticipationParam(
        gameId: gameId, type: type, isCheckBoxes: const [false, false, false]);
  }

  void update({
    int? gameId,
    PaymentMethodType? type,
    List<bool>? isCheckBoxes,
  }) {
    state = state.copyWith(
      gameId: gameId,
      type: type,
      isCheckBoxes: isCheckBoxes,
    );
  }

  List<bool> onCheck(int idx) {
    List<bool> newCheckBoxes = state.isCheckBoxes.toList();
    newCheckBoxes[idx] = !newCheckBoxes[idx];
    state = state.copyWith(isCheckBoxes: newCheckBoxes);
    return state.isCheckBoxes;
  }
}

@riverpod
class GameRefundForm extends _$GameRefundForm {
  @override
  GameRefundParam build() {
    final result = ref.watch(agreementPolicyProvider(
        type: AgreementRequestType.participation_refund));
    if (result is ResponseListModel<AgreementPolicyModel>) {
      final List<bool> checkBoxes =
          List.generate(result.data!.length, (e) => false);
      return GameRefundParam(isCheckBoxes: checkBoxes);
    }
    return const GameRefundParam(isCheckBoxes: [false, false, false]);
  }

  void update({
    List<bool>? isCheckBoxes,
  }) {
    state = state.copyWith(
      isCheckBoxes: isCheckBoxes,
    );
  }

  List<bool> onCheck(int idx) {
    List<bool> newCheckBoxes = state.isCheckBoxes.toList();
    newCheckBoxes[idx] = !newCheckBoxes[idx];
    state = state.copyWith(isCheckBoxes: newCheckBoxes);
    return state.isCheckBoxes;
  }
}
