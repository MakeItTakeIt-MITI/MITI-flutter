import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/court/view/court_map_screen.dart';

import '../../game/model/game_model.dart';

class CustomNMarker extends NMarker {
  CustomNMarker({required super.id, required super.position});
}

class CustomMarker {
  final MapMarkerModel model;

  CustomMarker({required this.model});

  Future<NMarker> getMarker(BuildContext context,
      {bool selected = false}) async {
    final icon = await NOverlayImage.fromWidget(
        widget: SpeechBubble(
          model: model,
          selected: selected,
        ),
        size: Size(
          140.w,
          80.h,
        ),
        context: context);
    return NMarker(
        id: '${model.id}',
        position: NLatLng(model.latitude, model.longitude),
        icon: icon);
  }

  Future<NOverlayImage> getNOverlayImage(BuildContext context,
      {bool selected = false}) async {
    return await NOverlayImage.fromWidget(
        widget: SpeechBubble(
          model: model,
          selected: selected,
        ),
        size: Size(
          140.w,
          80.h,
        ),
        context: context);
  }
}

class MapMarkerModel {
  final int id;
  final String time;
  final String cost;
  final int moreCnt;
  final double latitude;
  final double longitude;

  MapMarkerModel({
    required this.id,
    required this.time,
    required this.cost,
    required this.moreCnt,
    required this.latitude,
    required this.longitude,
  });

// factory MapMarkerModel.fromModel({required GameModel model}) {
//   return MapMarkerModel(
//       id: id,
//       time: time,
//       cost: cost,
//       moreCnt: moreCnt,
//       latitude: latitude,
//       longitude: longitude,);
// }
}

class SpeechBubble extends ConsumerStatefulWidget {
  final MapMarkerModel model;
  final bool selected;

  const SpeechBubble({
    super.key,
    required this.model,
    required this.selected,
  });

  @override
  ConsumerState<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends ConsumerState<SpeechBubble> {
  @override
  Widget build(BuildContext context) {
    // final id = ref.watch(selectMakerProvider);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 125.w,
          height: 60.h,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: _SpeechBubblePainter(
              model: widget.model,
              selected: widget.selected,
            ),
            size: Size(double.infinity, double.infinity),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final MapMarkerModel model;
  final bool selected;

  _SpeechBubblePainter({
    required this.model,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final markerBorderPainter = Paint()
      ..color = selected ? const Color(0xFF040000) : const Color(0xFFFF4A4A)
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke;
    final markerFillPainter = Paint()
      ..color = selected ? const Color(0xFF4065F6) : Colors.white
      ..style = PaintingStyle.fill;
    final timeSpan = TextSpan(
        text: model.time,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontSize: 10.sp,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25.sp,
        ));

    final costSpan = TextSpan(
        text: model.cost,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontSize: 13.sp,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.bold,
          letterSpacing: -0.25.sp,
        ));

    final moreCntSpan = TextSpan(
        text: '+${model.moreCnt - 1}',
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontSize: 12.sp,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25.sp,
        ));

    final timeTextPainter = TextPainter(
      text: timeSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    final costTextPainter = TextPainter(
      text: costSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    final TextPainter basketballPinter = TextPainter(
      text: TextSpan(
          text: '🏀',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25.sp,
          )),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    final moreCntTextPainter = TextPainter(
      text: moreCntSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    timeTextPainter.layout(minWidth: 0, maxWidth: size.width);
    costTextPainter.layout(minWidth: 0, maxWidth: size.width);
    basketballPinter.layout(minWidth: 0, maxWidth: size.width);
    moreCntTextPainter.layout(minWidth: 0, maxWidth: size.width);

    final timeHeight = timeTextPainter.height;
    final basketballWidth = basketballPinter.width;
    final moreCntWidth = moreCntTextPainter.width;

    final mainRadius = 16.r;
    double subRadius = 10.r;
    final x = size.width;
    final y = size.height;

    /// path 설정
    final markerPath = Path()

      /// 왼쪽 윗변부터
      ..moveTo(mainRadius, subRadius)
      ..lineTo(x - mainRadius, subRadius)

      /// 으론쪽 윗 꼭지점
      ..arcToPoint(Offset(x, subRadius + mainRadius),
          radius: Radius.circular(mainRadius))

      /// 오른쪽 변
      ..lineTo(x, y - mainRadius - 10.h)
      // /// 으론쪽 아래 꼭지점
      ..arcToPoint(Offset(x - subRadius, y - 10.h),
          radius: Radius.circular(mainRadius))

      /// 아랫 변
      ..lineTo(x / 3 * 2, y - 10.h)
      ..lineTo(x / 2, y)
      ..lineTo(x / 3, y - 10.h)
      ..lineTo(mainRadius, y - 10.h)

      /// 왼쪽 아래 꼭지점
      ..arcToPoint(Offset(0, y - mainRadius - 10.h),
          radius: Radius.circular(mainRadius))

      /// 왼쪽 변
      ..lineTo(0, subRadius + mainRadius)

      /// 왼쪽 위 꼭지점
      ..arcToPoint(Offset(mainRadius, subRadius),
          radius: Radius.circular(mainRadius))
      ..close();

    /// 그리기
    canvas.drawPath(markerPath, markerFillPainter);
    canvas.drawPath(markerPath, markerBorderPainter);

    /// (글자 너비 = circle width) / 2 <= 반지름 + padding
    final newSubRadius = moreCntWidth / 2 + 4.r;
    if (model.moreCnt > 1) {
      canvas.drawCircle(
          Offset(x - subRadius, subRadius), newSubRadius, markerFillPainter);
      canvas.drawCircle(
          Offset(x - subRadius, subRadius), newSubRadius, markerBorderPainter);
    }

    /// Text 그리기
    basketballPinter.paint(canvas, Offset(14.w, subRadius + 8.h));

    /// x: 왼쪽 paading + basketballWidth + basketball 간격,
    /// y: 위쪽 subRadius + padding
    timeTextPainter.paint(
        canvas, Offset(14.w + 7.w + basketballWidth, 6.h + subRadius));
    costTextPainter.paint(canvas,
        Offset(14.w + 7.w + basketballWidth, 6.h + subRadius + timeHeight));
    if (model.moreCnt > 1) {
      moreCntTextPainter.paint(
          canvas, Offset(x - (newSubRadius) - newSubRadius / 2, 2.r));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
