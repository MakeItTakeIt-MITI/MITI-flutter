import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/component/html_component.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/etc/model/tc_policy_model.dart';
import 'package:miti/etc/provider/tc_policy_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../notification/view/notification_detail_screen.dart';

class TcPolicyScreen extends StatelessWidget {
  static String get routeName => 'tcPolicy';

  const TcPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DefaultAppBar(
        backgroundColor: MITIColor.gray800,
        hasBorder: false,
        title: '약관 및 정책',
      ),
      backgroundColor: MITIColor.gray800,
      body: Padding(
        padding: EdgeInsets.all(21.r),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final result = ref.watch(tcPolicyListProvider);
            if (result is LoadingModel) {
              return CircularProgressIndicator();
            } else if (result is ErrorModel) {
              return Text('error');
            }
            final model = (result as ResponseListModel<TcPolicyModel>).data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...model.map((m) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierColor: MITIColor.gray800,
                                builder: (context) {
                                  return TcPolicyDetailScreen(
                                    policyId: m.id,
                                  );
                                });
                          },
                          child: Text(
                            m.name,
                            style: MITITextStyle.sm150.copyWith(
                              color: MITIColor.white,
                            ),
                          )),
                    ))
              ],
            );
          },
        ),
      ),
    );
  }
}

class TcPolicyDetailScreen extends ConsumerWidget {
  final int policyId;

  const TcPolicyDetailScreen({
    super.key,
    required this.policyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(tcPolicyProvider(policyId: policyId));
    if (result is LoadingModel) {
      return const Dialog.fullscreen(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    } else if (result is ErrorModel) {
      return const Dialog.fullscreen(
        child: Scaffold(
          body: Text('error'),
        ),
      );
    }

    final model = (result as ResponseModel<TcPolicyDetailModel>).data!;
    return Dialog.fullscreen(
      backgroundColor: MITIColor.gray800,
      child: Scaffold(
        backgroundColor: MITIColor.gray800,
        appBar: const DefaultAppBar(
          hasBorder: false,
          leadingIcon: "remove",
        ),
        body: Padding(
          padding:
              EdgeInsets.only(top: 24.h, left: 21.w, right: 21.w, bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                model.name,
                style: MITITextStyle.xl150.copyWith(
                  color: MITIColor.white,
                ),
              ),
              SizedBox(height: 20.h),
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
