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
        'body': Style(margin: Margins.all(0)),
        'p': Style(
          fontSize: FontSize(16.sp),
          color: MITIColor.gray300,
        ),
        'ul': Style(
          listStyleType: ListStyleType.none,
          margin: Margins.zero,
          padding: HtmlPaddings.all(5.r),
          fontSize: FontSize(12.sp),
          lineHeight: LineHeight.em(1.5),
        ),
        'b': Style(
          color: MITIColor.gray300,
        ),
        'li': Style(
          margin: Margins.all(4.r),
          fontSize: FontSize(12.sp),
          listStyleType: ListStyleType.none,
          lineHeight: LineHeight.em(1.5),
          color: MITIColor.gray300,
          listStylePosition: ListStylePosition.inside,
        ),
        'h1': Style(
          color: MITIColor.gray300,
        ),
        'h2': Style(
          color: MITIColor.gray300,
        ),
        'h3': Style(
          color: MITIColor.gray300,
        ),
        'h4': Style(
          color: MITIColor.gray300,
        ),
        'h5': Style(
          color: MITIColor.gray300,
        ),
        'h6': Style(
          color: MITIColor.gray300,
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
