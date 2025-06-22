import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/model/entity_enum.dart';

import '../../theme/text_theme.dart';

class PostCategory extends StatelessWidget {
  final PostCategoryType category;

  const PostCategory({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: const Color(0xFF89CFF0),
      ),
      child: Text(
        category.displayName,
        style: MITITextStyle.xxxsmLight.copyWith(color: Colors.black),
      ),
    );
  }
}
