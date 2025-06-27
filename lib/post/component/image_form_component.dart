import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/color_theme.dart';
import '../../util/util.dart';

class ImageFormComponent extends StatelessWidget {
  final String? filePath;
  final String? imageUrl;
  final bool isLoading;
  final VoidCallback onDelete;

  const ImageFormComponent({
    super.key,
    required this.onDelete,
    this.filePath,
    this.imageUrl,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.r,
      height: 80.r,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: SizedBox(
              height: 72.r,
              width: 72.r,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: filePath != null
                    ? Image.file(
                        File(filePath!),
                        // height: 72.r,
                        // width: 72.r,
                        fit: BoxFit.fill,
                      )
                    : imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.fill,
                          )
                        : Container(),
              ),
            ),
          ),
          if (isLoading)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                height: 72.r,
                width: 72.r,
                decoration: BoxDecoration(
                  color: MITIColor.gray750.withOpacity(.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.r,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0.r,
            right: 0.r,
            child: InkWell(
              borderRadius: BorderRadius.circular(100.r),
              onTap: onDelete,
              child: Container(
                decoration: const BoxDecoration(
                  color: MITIColor.gray700,
                  shape: BoxShape.circle,
                ),
                margin: EdgeInsets.all(4.r),
                padding: EdgeInsets.all(3.r),
                child: SvgPicture.asset(
                  AssetUtil.getAssetPath(type: AssetType.icon, name: 'close'),
                  width: 12.r,
                  height: 12.r,
                  colorFilter:
                      const ColorFilter.mode(MITIColor.white, BlendMode.srcIn),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
