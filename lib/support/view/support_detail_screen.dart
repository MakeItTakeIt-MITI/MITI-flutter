import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/support/component/qna_label.dart';
import 'package:miti/support/error/support_error.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../component/skeleton/support_detail_skeleton.dart';
import '../model/support_model.dart';

class SupportDetailScreen extends StatefulWidget {
  static String get routeName => 'supportDetail';
  final int questionId;

  const SupportDetailScreen({
    super.key,
    required this.questionId,
  });

  @override
  State<SupportDetailScreen> createState() => _SupportDetailScreenState();
}

class _SupportDetailScreenState extends State<SupportDetailScreen> {
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
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '상세 문의 내역',
              hasBorder: false,
            ),
          ];
        }),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result = ref
                      .watch(questionProvider(questionId: widget.questionId));
                  if (result is LoadingModel) {
                    return const SupportDetailSkeleton();
                  } else if (result is ErrorModel) {
                    WidgetsBinding.instance.addPostFrameCallback((s) {
                      SupportError.fromModel(model: result)
                          .responseError(context, SupportApiType.get, ref);
                    });
                    return Text('에러');
                  }
                  final model = (result as ResponseModel<QuestionModel>).data!;
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QnaLabel(num_of_answers: model.num_of_answers),
                        SizedBox(height: 20.h),
                        _QuestionComponent.fromModel(model: model),
                        _AnswerComponent(
                          answers: model.answers,
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _QuestionComponent extends StatelessWidget {
  final String title;
  final String content;
  final int num_of_answers;
  final String created_at;
  final DateTime modified_at;

  const _QuestionComponent(
      {super.key,
      required this.title,
      required this.num_of_answers,
      required this.created_at,
      required this.modified_at,
      required this.content});

  factory _QuestionComponent.fromModel({required QuestionModel model}) {
    final created_at = DateFormat('yyyy년 MM월 dd일').format(model.created_at);
    return _QuestionComponent(
      title: model.title,
      num_of_answers: model.num_of_answers,
      created_at: created_at,
      modified_at: model.modified_at,
      content: model.content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: MITITextStyle.mdBold150.copyWith(color: MITIColor.gray100),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Text(
          created_at,
          style: MITITextStyle.xxsmLight.copyWith(
            color: MITIColor.gray300,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          content,
          style: MITITextStyle.sm150.copyWith(
            color: MITIColor.gray100,
          ),
        ),
      ],
    );
  }
}

class _AnswerComponent extends StatelessWidget {
  final List<AnswerModel> answers;

  const _AnswerComponent({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    if (answers.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 20.h),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemBuilder: (_, idx) {
            return _AnswerCard.fromModel(model: answers[idx]);
          },
          separatorBuilder: (_, idx) {
            return SizedBox(height: 12.h);
          },
          itemCount: answers.length,
        ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String content;
  final String created_at;
  final DateTime modified_at;

  const _AnswerCard({
    super.key,
    required this.content,
    required this.created_at,
    required this.modified_at,
  });

  factory _AnswerCard.fromModel({required AnswerModel model}) {
    final created_at = DateFormat('yyyy년 MM월 dd일').format(model.created_at);
    return _AnswerCard(
      content: model.content,
      created_at: created_at,
      modified_at: model.modified_at,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: MITIColor.gray700,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            created_at,
            style: MITITextStyle.xxsmLight.copyWith(color: MITIColor.gray300),
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            style: MITITextStyle.sm150.copyWith(color: MITIColor.gray100),
          ),
        ],
      ),
    );
  }
}
