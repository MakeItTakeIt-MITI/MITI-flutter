import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:miti/common/component/default_layout.dart';
import 'package:miti/common/component/dispose_sliver_pagination_list_view.dart';
import 'package:miti/court/component/court_list_component.dart';
import 'package:miti/support/model/support_model.dart';
import 'package:miti/support/provider/support_provider.dart';

import '../../common/component/default_appbar.dart';
import '../../common/model/model_id.dart';
import '../../common/param/pagination_param.dart';
import '../../theme/text_theme.dart';

class FAQScreen extends StatefulWidget {
  static String get routeName => 'faq';
  final int bottomIdx;

  const FAQScreen({super.key, required this.bottomIdx});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
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
              title: 'FAQ',
            ),
          ];
        }),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(12.r),
              sliver: DisposeSliverPaginationListView(
                  provider: faqProvider(PaginationStateParam()),
                  itemBuilder: (BuildContext context, int index, Base pModel) {
                    final model = pModel as FAQModel;

                    return _FAQComponent.fromModel(
                      model: model,
                    );
                  },
                  skeleton: Container(),
                  controller: _scrollController,
                  emptyWidget: getEmptyWidget()),
            ),
          ],
        ),
      ),
    );
  }

  Widget getEmptyWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '송금 내역이 없습니다.',
          style: MITITextStyle.pageMainTextStyle,
        ),
        SizedBox(height: 20.h),
        Text(
          '송금 요청을 통해 정산금을 받아보세요!',
          style: MITITextStyle.pageSubTextStyle,
        )
      ],
    );
  }
}

class _FAQComponent extends ConsumerWidget {
  final int id;
  final String title;
  final String content;
  final DateTime created_at;
  final DateTime modified_at;

  const _FAQComponent(
      {super.key,
      required this.title,
      required this.content,
      required this.created_at,
      required this.modified_at,
      required this.id});

  factory _FAQComponent.fromModel({required FAQModel model}) {
    return _FAQComponent(
      title: model.title,
      content: model.content,
      created_at: model.created_at,
      modified_at: model.modified_at,
      id: model.id,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedProvider) == id;
    return GestureDetector(
      onTap: () {
        if (selected) {
          ref.read(selectedProvider.notifier).update((state) => null);
        } else {
          ref.read(selectedProvider.notifier).update((state) => id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: MITITextStyle.plainTextMStyle.copyWith(
                      color: const Color(0xff333333),
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.keyboard_arrow_up_outlined
                      : Icons.keyboard_arrow_down_outlined,
                  size: 24.r,
                )
              ],
            ),
            if (selected)
              Divider(
                height: 19.h,
                color: const Color(0xFFE8E8E8),
              ),
            if (selected)
              Text(
                content,
                style: MITITextStyle.inputValueTextStyle.copyWith(
                  color: const Color(0xff333333),
                ),
              )
          ],
        ),
      ),
    );
  }
}
