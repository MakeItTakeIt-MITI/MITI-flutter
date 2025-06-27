import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/support/provider/advertise_provider.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/html_component.dart';
import '../../game/model/v2/advertisement/advertisement_response.dart';
import '../../theme/color_theme.dart';
import '../../theme/text_theme.dart';

class AdvertiseDetailScreen extends ConsumerWidget {
  final int advertisementId;

  static String get routeName => 'advertise';

  const AdvertiseDetailScreen({super.key, required this.advertisementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result =
        ref.watch(advertiseProvider(advertisementId: advertisementId));
    if (result is LoadingModel) {
      return const CircularProgressIndicator();
    } else if (result is ErrorModel) {
      return const CircularProgressIndicator();
    }

    final model = (result as ResponseModel<AdvertisementResponse>).data!;

    final createAt = DateFormat('yyyy년 MM월 dd일', "ko")
        .format(model.createdAt ?? DateTime.now());
    return Dialog.fullscreen(
      backgroundColor: MITIColor.gray900,
      child: Scaffold(
        backgroundColor: MITIColor.gray900,
        appBar: const DefaultAppBar(
          hasBorder: false,
          leadingIcon: "remove",
          backgroundColor: MITIColor.gray900,
        ),
        body: Padding(
          padding:
              EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                model.title,
                style: MITITextStyle.xl150.copyWith(
                  color: MITIColor.white,
                ),
              ),
              SizedBox(height: 5.h),
              if (model.subtitle != null)
                Text(
                  model.subtitle!,
                  style: MITITextStyle.xl150.copyWith(
                    color: MITIColor.white,
                  ),
                ),
              SizedBox(height: 12.h),
              if (model.createdAt != null)
                Text(
                  createAt,
                  style: MITITextStyle.xxsmLight
                      .copyWith(color: MITIColor.gray300),
                ),
              SizedBox(height: 48.h),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: HtmlComponent(content: model.content),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              TextButton(
                  onPressed: () => context.pop(), child: const Text("닫기")),
            ],
          ),
        ),
      ),
    );
  }
}
