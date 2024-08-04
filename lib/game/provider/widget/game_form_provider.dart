import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:miti/game/param/game_param.dart';
import 'package:miti/util/util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/component/custom_text_form_field.dart';
import '../../../common/provider/widget/datetime_provider.dart';

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
      checkBoxes: [false, false, false],
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
      newCheckBoxes.fillRange(0, 3, newCheckBoxes[0]);
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

  bool validDatetime() {
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
        return false;
      } else if (startDateTime.isBefore(currentDateTime) &&
          endDateTime.isBefore(currentDateTime)) {
        return false;
      } else if (currentDateTime.isAfter(startDateTime) &&
          currentDateTime.isBefore(endDateTime)) {
        return false;
      } else {
        ref
            .read(interactionDescProvider(InteractionType.date).notifier)
            .update((state) => null);
        return true;
      }
    }
    ref
        .read(interactionDescProvider(InteractionType.date).notifier)
        .update((state) => null);
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
        ref.read(interactionDescProvider(InteractionType.date).notifier).update(
            (state) => InteractionDesc(
                isSuccess: false, desc: '시작 시간이 종료 시간보다 같거나 이후일 수 없습니다.'));
        return false;
      } else if (startDateTime.isBefore(currentDateTime) &&
          endDateTime.isBefore(currentDateTime)) {
        ref.read(interactionDescProvider(InteractionType.date).notifier).update(
            (state) => InteractionDesc(
                isSuccess: false, desc: '경기 시간이 현재 시간보다 이전일 수 없습니다.'));
        return false;
      } else if (currentDateTime.isAfter(startDateTime) &&
          currentDateTime.isBefore(endDateTime)) {
        ref.read(interactionDescProvider(InteractionType.date).notifier).update(
            (state) => InteractionDesc(
                isSuccess: false, desc: '현재 시간이 경시 시간 사이에 있을 수 없습니다.'));
        return false;
      } else {
        ref
            .read(interactionDescProvider(InteractionType.date).notifier)
            .update((state) => null);
        return true;
      }
    }
    ref
        .read(interactionDescProvider(InteractionType.date).notifier)
        .update((state) => null);
    return false;
  }

  bool formValid() {
    log('validInvitation() = ${validInvitation()} validDatetime() = ${validDatetime()}');
    final formValid = ValidRegExp.gameTitle(state.title) &
        ValidRegExp.gameAddress(state.court.address) &
        // ValidRegExp.gameAddressDetail(state.court.address_detail) &
        ValidRegExp.courtName(state.court.name);
    bool checkBox = state.checkBoxes[1];
    log("formvalid = $formValid");
    log("checkbox = $checkBox");
    return validInvitation() && validDatetime() && formValid && checkBox;
  }
}

@riverpod
class ReviewForm extends _$ReviewForm {
  @override
  GameReviewParam build() {
    return const GameReviewParam(
      rating: null,
      comment: '',
    );
  }

  void updateRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void updateComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  bool valid() {
    log('state.rating = ${state.rating}');
    log('state.comment.isNotEmpty = ${state.comment.isNotEmpty}');
    return state.rating != null && state.comment.isNotEmpty;
  }
}
