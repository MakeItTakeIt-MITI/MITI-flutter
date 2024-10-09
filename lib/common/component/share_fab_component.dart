import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';
import '../../util/util.dart';

enum ShareType {
  games,
  courts;
}

class ShareFabComponent extends StatelessWidget {
  final _key = GlobalKey<ExpandableFabState>();

  final int id;
  final ShareType type;

  ShareFabComponent({super.key, required this.id, required this.type});

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: _key,
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
                  final state = _key.currentState;
                  if (state != null) {
                    debugPrint('isOpen:${state.isOpen}');
                    state.toggle();
                  }
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
                  final FeedTemplate defaultFeed = FeedTemplate(
                    content: Content(
                      title: '딸기 치즈 케익',
                      description: '#케익 #딸기 #삼평동 #카페 #분위기 #소개팅',
                      imageUrl: Uri.parse(
                          'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
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
                    itemContent: ItemContent(
                      profileText: 'Kakao',
                      profileImageUrl: Uri.parse(
                          'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
                      titleImageUrl: Uri.parse(
                          'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
                      titleImageText: 'Cheese cake',
                      titleImageCategory: 'cake',
                      items: [
                        ItemInfo(item: 'cake1', itemOp: '1000원'),
                        ItemInfo(item: 'cake2', itemOp: '2000원'),
                        ItemInfo(item: 'cake3', itemOp: '3000원'),
                        ItemInfo(item: 'cake4', itemOp: '4000원'),
                        ItemInfo(item: 'cake5', itemOp: '5000원')
                      ],
                      sum: 'total',
                      sumOp: '15000원',
                    ),
                    // social: Social(likeCount: 286, commentCount: 45, sharedCount: 845),
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
                        title: '앱으로보기',
                        link: Link(
                          webUrl:
                              Uri.parse('https://makeittakeit.kr/games/30000'),
                          mobileWebUrl:
                              Uri.parse('https://makeittakeit.kr/games/30000'),
                          // iosExecutionParams: {'gameId': '30000'}, // iOS 앱으로 전달할 파라미터
                          // androidExecutionParams: {'gameId': '30000'}, // Android 앱으로 전달할 파라미터
                          iosExecutionParams: {
                            'url': 'https://makeittakeit.kr/games/30000'
                          },
                          // iOS 용 실행 URL
                          androidExecutionParams: {
                            'url': 'https://makeittakeit.kr/games/30000'
                          }, // Android 용 실행 URL
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
                      final state = _key.currentState;
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
