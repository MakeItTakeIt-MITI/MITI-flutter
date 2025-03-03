import 'package:miti/game/model/game_model.dart';

import '../../../review/model/v2/base_guest_rating_response.dart';

class UserReviewShortInfoModel {
  final String nickname;
  final String profileImageUrl;
  final BaseRatingResponse rating;

  UserReviewShortInfoModel({
    required this.nickname,
    required this.rating,
    required this.profileImageUrl,
  });
}
