import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/color_theme.dart';

class HtmlComponent extends StatelessWidget {
  final String content;

  const HtmlComponent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: content,
      style: {
        '*': Style(color: MITIColor.gray300, margin: Margins.zero),
        '.section': Style(
          margin: Margins.only(top: 8.h, left: 0, bottom: 25.h, right: 0),
        ),
        '.subsection': Style(
          padding: HtmlPaddings(left: HtmlPadding(5.w)),
          margin: Margins.only(top: 6.h, left: 0, bottom: 15.h, right: 0),
        ),
        '.lg-bold': Style(
          fontSize: FontSize(16.sp),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 10.h, left: 0, bottom: 10.h, right: 0),
        ),
        '.m-bold': Style(
          fontSize: FontSize(14.sp),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 10.h, left: 0, bottom: 10.h, right: 0),
        ),
        '.sm': Style(
          fontSize: FontSize(12.sp),
          lineHeight: LineHeight.em(1.5),
          margin: Margins.only(top: 0, left: 0, bottom: 2.h, right: 0),
        ),
        'b': Style(
          color: MITIColor.primary,
        ),
      },
      onLinkTap: (url, _, __) async {
        if (url != null) {
          final Uri _url = Uri.parse(url);
          await launchUrl(_url);
        }
      },
    );
  }
}
