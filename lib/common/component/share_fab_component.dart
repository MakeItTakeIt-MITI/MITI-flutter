import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:miti/common/model/model_id.dart';
import 'package:share_plus/share_plus.dart';

import '../../court/model/v2/court_operations_response.dart';
import '../../game/model/v2/game/game_detail_response.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';
import 'defalut_flashbar.dart';

enum ShareType {
  games,
  courts;
}

class ShareFabComponent extends StatelessWidget {
  final GlobalKey<ExpandableFabState> globalKey;
  final int id;
  final ShareType type;
  final IModelWithId? model;

  const ShareFabComponent(
      {super.key,
      required this.id,
      required this.type,
      required this.globalKey,
      this.model});

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: globalKey,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 60.h,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.black.withOpacity(.64),
      ),
      openButtonBuilder: FloatingActionButtonBuilder(
          size: 44.r,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF000000).withOpacity(0.6),
              ),
              child: SvgPicture.asset(
                AssetUtil.getAssetPath(type: AssetType.icon, name: 'share'),
              ),
            );
          }),
      closeButtonBuilder: FloatingActionButtonBuilder(
          size: 44.r,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double> progress) {
            return GestureDetector(
              onTap: onPressed,
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: MITIColor.gray100, width: .5.r),
                  color: const Color(0xFF000000),
                ),
                child: SvgPicture.asset(
                  AssetUtil.getAssetPath(
                    type: AssetType.icon,
                    name: 'close',
                  ),
                ),
              ),
            );
          }),
      childrenOffset: const Offset(0, 10),
      children: [
        Row(
          children: [
            Text(
              '더보기',
              style:
                  MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray100),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              height: 46.r,
              width: 46.r,
              child: FloatingActionButton.small(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: MITIColor.gray100,
                shape: const CircleBorder(),
                onPressed: () async {
                  final result = await Share.shareUri(Uri(
                    scheme: 'https',
                    host: "www.makeittakeit.kr",
                    path: '${type.name}/$id',
                  ));
                  // log('result.status = ${result.status}');
                  if (ShareResultStatus.success == result.status) {
                    final state = globalKey.currentState;
                    if (state != null) {
                      debugPrint('isOpen:${state.isOpen}');
                      state.toggle();
                    }
                  }
                },
                heroTag: null,
                child: SvgPicture.asset(
                  AssetUtil.getAssetPath(type: AssetType.icon, name: 'h_more'),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '링크 복사',
              style:
                  MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray100),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              height: 46.r,
              width: 46.r,
              child: FloatingActionButton.small(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: MITIColor.gray100,
                shape: const CircleBorder(),
                heroTag: null,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(
                      text: Uri(
                    scheme: 'https',
                    host: "www.makeittakeit.kr",
                    path: '${type.name}/$id',
                  ).toString()));
                  final state = globalKey.currentState;
                  if (state != null) {
                    debugPrint('isOpen:${state.isOpen}');
                    state.toggle();
                  }
                  FlashUtil.showFlash(context, '링크가 복사되었습니다.');
                },
                child: SvgPicture.asset(
                    AssetUtil.getAssetPath(type: AssetType.icon, name: 'link')),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              '카카오톡 공유',
              style:
                  MITITextStyle.smSemiBold.copyWith(color: MITIColor.gray100),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              height: 46.r,
              width: 46.r,
              child: FloatingActionButton.small(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: const Color(0xFFFFF100),
                shape: const CircleBorder(),
                heroTag: null,
                onPressed: () async {
                  String title = "";
                  String desc = "";

                  if (model != null) {
                    if (model is GameDetailResponse) {
                      final gameModel = model as GameDetailResponse;

                      final start = DateTime.parse(
                          "${gameModel.startdate} ${gameModel.starttime}");
                      final end = DateTime.parse(
                          "${gameModel.enddate} ${gameModel.endtime}");

                      log("start $start");
                      final startDate =
                          gameModel.startdate.replaceAll('-', '. ');
                      final endDate = gameModel.startdate.replaceAll('-', '. ');

                      final time =
                          '${gameModel.starttime.substring(0, 5)} ~ ${gameModel.endtime.substring(0, 5)}';
                      final gameDate = startDate == endDate
                          ? '$startDate $time'
                          : '$startDate ${gameModel.starttime.substring(0, 5)} ~ $endDate ${gameModel.endtime.substring(0, 5)}';
                      final address =
                          '${gameModel.court.address} ${gameModel.court.addressDetail ?? ''}';

                      title = gameModel.title;
                      desc = "$gameDate\n$address\n";
                    } else if (model is CourtOperationsResponse) {
                      final courtModel = model as CourtOperationsResponse;
                      title = courtModel.name ?? '미정';
                      desc =
                          "${courtModel.address} ${courtModel.addressDetail ?? ''}";
                    }
                  }

                  final FeedTemplate defaultFeed = FeedTemplate(
                    content: Content(
                      title: title,
                      description: desc,
                      imageUrl: Uri.parse(
                          'https://www.makeittakeit.kr/images/miti_thumbnail.png'),
                      link: Link(
                        webUrl: Uri(
                          scheme: 'https',
                          host: "www.makeittakeit.kr",
                          path: '${type.name}/$id',
                        ),
                        mobileWebUrl: Uri(
                          scheme: 'https',
                          host: "www.makeittakeit.kr",
                          path: '${type.name}/$id',
                        ),
                      ),
                    ),
                    buttons: [
                      Button(
                        title: '웹으로 보기',
                        link: Link(
                          webUrl: Uri(
                            scheme: 'https',
                            host: "www.makeittakeit.kr",
                            path: '${type.name}/$id',
                          ),
                          mobileWebUrl: Uri(
                            scheme: 'https',
                            host: "www.makeittakeit.kr",
                            path: '${type.name}/$id',
                          ),
                        ),
                      ),
                      Button(
                        title: '앱으로 보기',  // 기존: '앱으로보기'
                        link: Link(
                          // 🆕 Custom Scheme 추가
                          // androidExecutionParams: {
                          //   'scheme': 'miti://${type.name}/$id',  // Custom Scheme 사용
                          // },
                          // iosExecutionParams: {
                          //   'scheme': 'miti://${type.name}/$id',  // Custom Scheme 사용
                          // },

                          iosExecutionParams: {
                            'url':
                            'https://www.makeittakeit.kr/${type.name}/$id'
                          },
                          // iOS 용 실행 URL
                          androidExecutionParams: {
                            'url':
                            'https://www.makeittakeit.kr/${type.name}/$id'
                          }, // Android 용 실행 URL
                          // 폴백용 웹 링크 (앱이 없을 때)
                          webUrl: Uri(
                            scheme: 'https',
                            host: "www.makeittakeit.kr",
                            path: '${type.name}/$id',
                          ),
                          mobileWebUrl: Uri(
                            scheme: 'https',
                            host: "www.makeittakeit.kr",
                            path: '${type.name}/$id',
                          ),
                        ),
                      ),
                    ],
                  );
                  // 카카오톡 실행 가능 여부 확인
                  bool isKakaoTalkSharingAvailable =
                      await ShareClient.instance.isKakaoTalkSharingAvailable();

                  if (isKakaoTalkSharingAvailable) {
                    try {
                      Uri uri = await ShareClient.instance
                          .shareDefault(template: defaultFeed);
                      await ShareClient.instance.launchKakaoTalk(uri);
                      print('shareUrl: ${uri}');
                      print('카카오톡 공유 완료');
                      final state = globalKey.currentState;
                      if (state != null) {
                        debugPrint('isOpen:${state.isOpen}');
                        state.toggle();
                      }
                    } catch (error) {
                      print('카카오톡 공유 실패 $error');
                    }
                  } else {
                    try {
                      Uri shareUrl = await WebSharerClient.instance
                          .makeDefaultUrl(template: defaultFeed);
                      print('shareUrl: ${shareUrl}');
                      await launchBrowserTab(shareUrl, popupOpen: true);
                    } catch (error) {
                      print('카카오톡 공유 실패 $error');
                    }
                  }
                },
                child: SvgPicture.asset(AssetUtil.getAssetPath(
                    type: AssetType.icon, name: 'kakao')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
