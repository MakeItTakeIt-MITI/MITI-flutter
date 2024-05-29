import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/support/provider/widget/support_form_provider.dart';
import 'package:miti/support/view/support_screen.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/provider/router_provider.dart';

class SupportFormScreen extends StatefulWidget {
  final int bottomIdx;

  static String get routeName => 'supportForm';

  const SupportFormScreen({super.key, required this.bottomIdx});

  @override
  State<SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends State<SupportFormScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '문의하기',
            ),
          ];
        }),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
                child: Column(
              children: [
                const _TitleForm(),
                const _ContentForm(),
                const Spacer(),
                Consumer(
                  builder:
                      (BuildContext context, WidgetRef ref, Widget? child) {
                    final form = ref.watch(supportFormProvider);
                    final valid =
                        form.title.isNotEmpty && form.content.isNotEmpty;
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: TextButton(
                        onPressed: valid
                            ? () async {
                                final result =
                                    ref.read(supportCreateProvider.future);
                                if (result is ErrorModel) {
                                } else {
                                  final extra = CustomDialog(
                                    title: '문의 작성 완료',
                                    content: '빠른 시일내로 답변드리도록 하겠습니다.',
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                      final Map<String, String>
                                          queryParameters = {
                                        'bottomIdx':
                                            widget.bottomIdx.toString(),
                                      };
                                      context.goNamed(
                                        SupportScreen.routeName,
                                        queryParameters: queryParameters,
                                      );
                                    },
                                  );
                                  context.pushNamed(DialogPage.routeName,
                                      extra: extra);
                                }
                              }
                            : () {},
                        style: TextButton.styleFrom(
                            backgroundColor: valid
                                ? const Color(0xFF4065F5)
                                : const Color(0xFFE8E8E8)),
                        child: Text(
                          '문의하기',
                          style: MITITextStyle.btnTextBStyle.copyWith(
                              color: valid
                                  ? Colors.white
                                  : const Color(0xFF969696)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class _TitleForm extends ConsumerWidget {
  const _TitleForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '제목',
            style: MITITextStyle.sectionTitleStyle,
          ),
          SizedBox(height: 9.h),
          TextFormField(
            onChanged: (val) {
              ref.read(supportFormProvider.notifier).update(title: val);
            },
            style: MITITextStyle.inputValueMStyle,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              hintText: '제목을 입력해주세요.',
              hintStyle: MITITextStyle.inputValueMStyle.copyWith(
                color: const Color(0xFF969696),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentForm extends ConsumerWidget {
  const _ContentForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '문의 내용',
            style: MITITextStyle.sectionTitleStyle,
          ),
          SizedBox(height: 9.h),
          SingleChildScrollView(
            child: IntrinsicHeight(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 200.h,
                  maxHeight: 500.h,
                ),
                child: TextFormField(
                  onChanged: (val) {
                    ref.read(supportFormProvider.notifier).update(content: val);
                  },
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: null,
                  style: MITITextStyle.inputValueMStyle,
                  keyboardType: TextInputType.multiline,
                  maxLength: 300,
                  expands: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                    hintText: '문의 내용을 입력해주세요.',
                    hintStyle: MITITextStyle.inputValueMStyle.copyWith(
                      color: const Color(0xFF969696),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
