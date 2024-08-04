import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

class CustomMarker {
  final MapMarkerModel model;

  CustomMarker({required this.model});

  Future<NMarker> getMarker(BuildContext context,
      {bool selected = false}) async {
    final icon = await NOverlayImage.fromWidget(
        widget: CustomMapMaker(
          model: model,
          selected: selected,
        ),
        size: Size(
          130.r,
          40.r,
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
        widget: CustomMapMaker(
          model: model,
          selected: selected,
        ),
        size: Size(
          130.r,
          40.r,
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

class CustomMapMaker extends ConsumerStatefulWidget {
  final MapMarkerModel model;
  final bool selected;

  const CustomMapMaker({
    super.key,
    required this.model,
    required this.selected,
  });

  @override
  ConsumerState<CustomMapMaker> createState() => _CustomMapMakerState();
}

class _CustomMapMakerState extends ConsumerState<CustomMapMaker> {
  @override
  Widget build(BuildContext context) {
    // final id = ref.watch(selectMakerProvider);
    final timeTextStyle = MITITextStyle.xxxsmLight.copyWith(
      color: widget.selected ? MITIColor.gray500 : MITIColor.gray700,
    );
    final costTextStyle = MITITextStyle.xxsmSemiBold.copyWith(
      fontWeight: FontWeight.w700,
      color: MITIColor.gray800,
    );
    late final String marker;

    final desc = RichText(
      text: TextSpan(
        text: widget.model.cost,
        children: [
          TextSpan(text: " / ${widget.model.time}", style: timeTextStyle),
        ],
        style: costTextStyle,
      ),
    );
    final painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: widget.model.cost,
          children: [
            TextSpan(text: " / ${widget.model.time}", style: timeTextStyle),
          ],
          style: costTextStyle,
        ));
    painter.layout(maxWidth: 130.r);
    // log('painter.width = ${painter.width}');

    final shadow = BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.12),
      blurRadius: 12.r,
      offset: Offset(0, 8.h),
    );
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: Container(
            height: 32.h,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [shadow],
                border: Border.all(
                    color: widget.selected
                        ? MITIColor.gray600
                        : MITIColor.gray300),
                color: widget.selected
                    ? MITIColor.primaryLight
                    : MITIColor.gray50),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: desc,
          ),
        ),
        // if (widget.model.moreCnt > 1)
        Positioned(
          top: 0,
          left: painter.width + 14.w,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [shadow],
              shape: BoxShape.circle,
              color: widget.selected ? MITIColor.gray700 : MITIColor.white,
              border: Border.all(
                  color:
                      widget.selected ? MITIColor.gray700 : MITIColor.gray100),
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
            child: Text(
              "${widget.model.moreCnt}",
              style: MITITextStyle.xxxsmBold.copyWith(
                  color: widget.selected ? MITIColor.white : MITIColor.gray600),
            ),
          ),
        ),
      ],
    );

    if (widget.model.moreCnt > 1) {
      marker =
          widget.selected ? 'selected_more_marker' : 'unselected_more_marker';
    } else {
      marker = widget.selected ? 'selected_marker' : 'unselected_marker';
    }

    return Stack(
      children: [
        Positioned(
          bottom: 0,
          child: SvgPicture.asset(
            'assets/images/icon/$marker.svg',
            height: widget.model.moreCnt > 1 ? 52.r : 45.r,
            width: widget.model.moreCnt > 1 ? 119.r : 111.r,
          ),
        ),
        Positioned(
          left: 35.5.r,
          bottom: 29.r,
          child: Text(
            widget.model.time,
            style: timeTextStyle,
          ),
        ),
        Positioned(
          left: 35.5.r,
          bottom: 12.r,
          child: Text(
            widget.model.cost,
            style: costTextStyle,
          ),
        )
      ],
    );
  }
}

class _CustomMapMakerPainter extends CustomPainter {
  final MapMarkerModel model;
  final bool selected;

  _CustomMapMakerPainter({
    required this.model,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // final markerBorderPainter = Paint()
    //   ..color = selected ? const Color(0xff4065f5) : const Color(0xff4065f5)
    //   ..strokeWidth = 2.w
    //   ..style = PaintingStyle.stroke;
    // final markerFillPainter = Paint()
    //   ..color = selected ? const Color(0xFF4065F6) : Colors.white
    //   ..style = PaintingStyle.fill;
    final timeSpan = TextSpan(
        text: model.time,
        style: MITITextStyle.gameTimeMarkerStyle.copyWith(
          color: selected ? Colors.white : Colors.black,
        ));

    final costSpan = TextSpan(
        text: model.cost,
        style: MITITextStyle.feeMakerStyle.copyWith(
          color: selected ? Colors.white : Colors.black,
        ));

    final moreCntSpan = TextSpan(
        text: '+', //${model.moreCnt - 1}
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xff4065f5),
          fontSize: 12.sp,
          height: 16 / 12,
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
    // final TextPainter basketballPinter = TextPainter(
    //   text: TextSpan(
    //       text: '🏀',
    //       style: TextStyle(
    //         fontSize: 20.sp,
    //         fontWeight: FontWeight.w400,
    //         letterSpacing: -0.25.sp,
    //       )),
    //   textDirection: TextDirection.ltr,
    //   textAlign: TextAlign.left,
    // );
    final moreCntTextPainter = TextPainter(
      text: moreCntSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    timeTextPainter.layout(minWidth: 0, maxWidth: size.width);
    costTextPainter.layout(minWidth: 0, maxWidth: size.width);
    // basketballPinter.layout(minWidth: 0, maxWidth: size.width);
    moreCntTextPainter.layout(minWidth: 0, maxWidth: size.width);

    final timeHeight = timeTextPainter.height;
    // final basketballWidth = basketballPinter.width;
    final moreCntWidth = moreCntTextPainter.width;

    final mainRadius = 16.r;
    double subRadius = 10.r;
    final x = size.width;
    final y = size.height;
    //
    // /// path 설정
    // final markerPath = Path()
    //
    // /// 왼쪽 윗변부터
    //   ..moveTo(mainRadius, subRadius)
    //   ..lineTo(x - mainRadius, subRadius)
    //
    // /// 으론쪽 윗 꼭지점
    //   ..arcToPoint(Offset(x, subRadius + mainRadius),
    //       radius: Radius.circular(mainRadius))
    //
    // /// 오른쪽 변
    //   ..lineTo(x, y - mainRadius - 10.h)
    // // /// 으론쪽 아래 꼭지점
    //   ..arcToPoint(Offset(x - subRadius, y - 10.h),
    //       radius: Radius.circular(mainRadius))
    //
    // /// 아랫 변
    //   ..lineTo(x / 3 * 2, y - 10.h)..lineTo(x / 2, y)..lineTo(
    //       x / 3, y - 10.h)..lineTo(mainRadius, y - 10.h)
    //
    // /// 왼쪽 아래 꼭지점
    //   ..arcToPoint(Offset(0, y - mainRadius - 10.h),
    //       radius: Radius.circular(mainRadius))
    //
    // /// 왼쪽 변
    //   ..lineTo(0, subRadius + mainRadius)
    //
    // /// 왼쪽 위 꼭지점
    //   ..arcToPoint(Offset(mainRadius, subRadius),
    //       radius: Radius.circular(mainRadius))
    //   ..close();
    //
    // /// 그리기
    // canvas.drawPath(markerPath, markerFillPainter);
    // canvas.drawPath(markerPath, markerBorderPainter);
    //
    // /// (글자 너비 = circle width) / 2 <= 반지름 + padding
    // final newSubRadius = moreCntWidth / 2 + 4.r;
    // if (model.moreCnt > 1) {
    //   canvas.drawCircle(
    //       Offset(x - subRadius, subRadius), newSubRadius, markerFillPainter);
    //   canvas.drawCircle(
    //       Offset(x - subRadius, subRadius), newSubRadius, markerBorderPainter);
    // }
    //
    // /// Text 그리기
    // // basketballPinter.paint(canvas, Offset(14.w, subRadius + 8.h));
    //

    Path path_0 = Path();
    path_0.moveTo(16, 8);
    path_0.cubicTo(7.16344, 8, 0, 15.1634, 0, 24);
    path_0.lineTo(0, 27);
    path_0.cubicTo(0, 35.8366, 7.16344, 43, 16, 43);
    path_0.lineTo(44.8791, 43);
    path_0.lineTo(53.6825, 51.3167);
    path_0.cubicTo(54.4534, 52.045, 55.6586, 52.045, 56.4295, 51.3167);
    path_0.lineTo(65.2329, 43);
    path_0.lineTo(95, 43);
    path_0.cubicTo(103.837, 43, 111, 35.8366, 111, 27);
    path_0.lineTo(111, 24);
    path_0.cubicTo(111, 15.1634, 103.837, 8, 95, 8);
    path_0.lineTo(16, 8);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(16, 8);
    path_1.cubicTo(7.16344, 8, 0, 15.1634, 0, 24);
    path_1.lineTo(0, 27);
    path_1.cubicTo(0, 35.8366, 7.16344, 43, 16, 43);
    path_1.lineTo(44.8791, 43);
    path_1.lineTo(53.6825, 51.3167);
    path_1.cubicTo(54.4534, 52.045, 55.6586, 52.045, 56.4295, 51.3167);
    path_1.lineTo(65.2329, 43);
    path_1.lineTo(95, 43);
    path_1.cubicTo(103.837, 43, 111, 35.8366, 111, 27);
    path_1.lineTo(111, 24);
    path_1.cubicTo(111, 15.1634, 103.837, 8, 95, 8);
    path_1.lineTo(16, 8);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = selected ? const Color(0xff4065f5) : Colors.white;
    canvas.drawPath(path_1, paint_1_fill);

    Path path_2 = Path();
    path_2.moveTo(44.8791, 43);
    path_2.lineTo(45.5658, 42.2731);
    path_2.lineTo(45.2768, 42);
    path_2.lineTo(44.8791, 42);
    path_2.lineTo(44.8791, 43);
    path_2.close();
    path_2.moveTo(53.6825, 51.3167);
    path_2.lineTo(52.9958, 52.0436);
    path_2.lineTo(52.9958, 52.0437);
    path_2.lineTo(53.6825, 51.3167);
    path_2.close();
    path_2.moveTo(56.4295, 51.3167);
    path_2.lineTo(55.7427, 50.5898);
    path_2.lineTo(55.7427, 50.5898);
    path_2.lineTo(56.4295, 51.3167);
    path_2.close();
    path_2.moveTo(65.2329, 43);
    path_2.lineTo(65.2329, 42);
    path_2.lineTo(64.8352, 42);
    path_2.lineTo(64.5462, 42.2731);
    path_2.lineTo(65.2329, 43);
    path_2.close();
    path_2.moveTo(1, 24);
    path_2.cubicTo(1, 15.7157, 7.71573, 9, 16, 9);
    path_2.lineTo(16, 7);
    path_2.cubicTo(6.61116, 7, -1, 14.6112, -1, 24);
    path_2.lineTo(1, 24);
    path_2.close();
    path_2.moveTo(1, 27);
    path_2.lineTo(1, 24);
    path_2.lineTo(-1, 24);
    path_2.lineTo(-1, 27);
    path_2.lineTo(1, 27);
    path_2.close();
    path_2.moveTo(16, 42);
    path_2.cubicTo(7.71573, 42, 1, 35.2843, 1, 27);
    path_2.lineTo(-1, 27);
    path_2.cubicTo(-1, 36.3888, 6.61116, 44, 16, 44);
    path_2.lineTo(16, 42);
    path_2.close();
    path_2.moveTo(44.8791, 42);
    path_2.lineTo(16, 42);
    path_2.lineTo(16, 44);
    path_2.lineTo(44.8791, 44);
    path_2.lineTo(44.8791, 42);
    path_2.close();
    path_2.moveTo(54.3693, 50.5898);
    path_2.lineTo(45.5658, 42.2731);
    path_2.lineTo(44.1924, 43.7269);
    path_2.lineTo(52.9958, 52.0436);
    path_2.lineTo(54.3693, 50.5898);
    path_2.close();
    path_2.moveTo(55.7427, 50.5898);
    path_2.cubicTo(55.3573, 50.9539, 54.7547, 50.9539, 54.3693, 50.5898);
    path_2.lineTo(52.9958, 52.0437);
    path_2.cubicTo(54.1521, 53.136, 55.9599, 53.136, 57.1162, 52.0436);
    path_2.lineTo(55.7427, 50.5898);
    path_2.close();
    path_2.moveTo(64.5462, 42.2731);
    path_2.lineTo(55.7427, 50.5898);
    path_2.lineTo(57.1162, 52.0436);
    path_2.lineTo(65.9196, 43.7269);
    path_2.lineTo(64.5462, 42.2731);
    path_2.close();
    path_2.moveTo(95, 42);
    path_2.lineTo(65.2329, 42);
    path_2.lineTo(65.2329, 44);
    path_2.lineTo(95, 44);
    path_2.lineTo(95, 42);
    path_2.close();
    path_2.moveTo(110, 27);
    path_2.cubicTo(110, 35.2843, 103.284, 42, 95, 42);
    path_2.lineTo(95, 44);
    path_2.cubicTo(104.389, 44, 112, 36.3888, 112, 27);
    path_2.lineTo(110, 27);
    path_2.close();
    path_2.moveTo(110, 24);
    path_2.lineTo(110, 27);
    path_2.lineTo(112, 27);
    path_2.lineTo(112, 24);
    path_2.lineTo(110, 24);
    path_2.close();
    path_2.moveTo(95, 9);
    path_2.cubicTo(103.284, 9, 110, 15.7157, 110, 24);
    path_2.lineTo(112, 24);
    path_2.cubicTo(112, 14.6112, 104.389, 7, 95, 7);
    path_2.lineTo(95, 9);
    path_2.close();
    path_2.moveTo(16, 9);
    path_2.lineTo(95, 9);
    path_2.lineTo(95, 7);
    path_2.lineTo(16, 7);
    path_2.lineTo(16, 9);
    path_2.close();

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Color(0xff4065F5).withOpacity(1.0);
    canvas.drawPath(path_2, paint_2_fill);

    Paint paint_3_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    /// 추가 원
    if (model.moreCnt > 1) {
      paint_3_stroke.color = Color(0xff4065F5).withOpacity(1.0);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1923077),
          size.width * 0.07983193, paint_3_stroke);

      Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
      paint_3_fill.color = selected ? const Color(0xff4065f5) : Colors.white;
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1923077),
          size.width * 0.07983193, paint_3_fill);
    }

    Path path_4 = Path();
    path_4.moveTo(108.268, 13.5312);
    path_4.lineTo(108.268, 11.3398);
    path_4.lineTo(106.076, 11.3398);
    path_4.lineTo(106.076, 9.875);
    path_4.lineTo(108.268, 9.875);
    path_4.lineTo(108.268, 7.68359);
    path_4.lineTo(109.732, 7.68359);
    path_4.lineTo(109.732, 9.875);
    path_4.lineTo(111.924, 9.875);
    path_4.lineTo(111.924, 11.3398);
    path_4.lineTo(109.732, 11.3398);
    path_4.lineTo(109.732, 13.5312);
    path_4.lineTo(108.268, 13.5312);
    path_4.close();

    /// 추가 원 안의 +
    // if (model.moreCnt > 1) {
    //   Paint paint_4_fill = Paint()..style = PaintingStyle.fill;
    //   paint_4_fill.color = selected ? Colors.white : const Color(0xff4065f5);
    //   canvas.drawPath(path_4, paint_4_fill);
    // }

    Path path_5 = Path();
    path_5.moveTo(18.5, 15.75);
    path_5.cubicTo(14.7822, 15.75, 11.75, 18.7822, 11.75, 22.5);
    path_5.cubicTo(11.75, 23.5547, 12.1777, 24.7646, 12.7578, 26.0859);
    path_5.cubicTo(13.3379, 27.4072, 14.085, 28.8105, 14.8438, 30.1172);
    path_5.cubicTo(16.3613, 32.7334, 17.8906, 34.9219, 17.8906, 34.9219);
    path_5.lineTo(18.5, 35.8125);
    path_5.lineTo(19.1094, 34.9219);
    path_5.cubicTo(19.1094, 34.9219, 20.6387, 32.7334, 22.1562, 30.1172);
    path_5.cubicTo(22.915, 28.8105, 23.6621, 27.4072, 24.2422, 26.0859);
    path_5.cubicTo(24.8223, 24.7646, 25.25, 23.5547, 25.25, 22.5);
    path_5.cubicTo(25.25, 18.7822, 22.2178, 15.75, 18.5, 15.75);
    path_5.close();
    path_5.moveTo(18.5, 17.25);
    path_5.cubicTo(21.4092, 17.25, 23.75, 19.5908, 23.75, 22.5);
    path_5.cubicTo(23.75, 23.1006, 23.4277, 24.2373, 22.8828, 25.4766);
    path_5.cubicTo(22.3379, 26.7158, 21.585, 28.0898, 20.8438, 29.3672);
    path_5.cubicTo(19.666, 31.4004, 18.9336, 32.4756, 18.5, 33.1172);
    path_5.cubicTo(18.0664, 32.4756, 17.334, 31.4004, 16.1562, 29.3672);
    path_5.cubicTo(15.415, 28.0898, 14.6621, 26.7158, 14.1172, 25.4766);
    path_5.cubicTo(13.5723, 24.2373, 13.25, 23.1006, 13.25, 22.5);
    path_5.cubicTo(13.25, 19.5908, 15.5908, 17.25, 18.5, 17.25);
    path_5.close();
    path_5.moveTo(18.5, 21);
    path_5.cubicTo(17.6709, 21, 17, 21.6709, 17, 22.5);
    path_5.cubicTo(17, 23.3291, 17.6709, 24, 18.5, 24);
    path_5.cubicTo(19.3291, 24, 20, 23.3291, 20, 22.5);
    path_5.cubicTo(20, 21.6709, 19.3291, 21, 18.5, 21);
    path_5.close();

    Paint paint_5_fill = Paint()..style = PaintingStyle.fill;
    paint_5_fill.color = selected ? Colors.white : const Color(0xff4065f5);
    canvas.drawPath(path_5, paint_5_fill);

    // /// x: 왼쪽 paading + basketballWidth + basketball 간격,
    // /// y: 위쪽 subRadius + padding
    timeTextPainter.paint(canvas, Offset(35.5.w, size.height * 0.2));
    costTextPainter.paint(canvas, Offset(35.5.w, size.height * 0.32));
    if (model.moreCnt > 1) {
      moreCntTextPainter.paint(
          canvas, Offset(size.width * 0.77, subRadius / 10));
      // Offset(x - (newSubRadius) - newSubRadius / 2, 2.r)
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
