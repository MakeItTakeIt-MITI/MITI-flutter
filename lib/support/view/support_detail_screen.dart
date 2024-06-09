import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/support/error/support_error.dart';
import 'package:miti/support/provider/support_provider.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../model/support_model.dart';

class SupportDetailScreen extends StatefulWidget {
  static String get routeName => 'supportDetail';
  final int bottomIdx;
  final int questionId;

  const SupportDetailScreen(
      {super.key, required this.questionId, required this.bottomIdx});

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
    return DefaultLayout(
      bottomIdx: widget.bottomIdx,
      scrollController: _scrollController,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: ((BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '문의 내역',
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
                    return CircularProgressIndicator();
                  } else if (result is ErrorModel) {
                    SupportError.fromModel(model: result)
                        .responseError(context, SupportApiType.get, ref);
                    return Text('에러');
                  }
                  final model = (result as ResponseModel<QuestionModel>).data!;
                  return Column(
                    children: [
                      _QuestionComponent.fromModel(model: model),
                      _AnswerComponent(
                        answers: model.answers,
                      ),
                    ],
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
    final created_at = DateFormat('yyyy.MM.dd HH:mm').format(model.created_at);
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
    return Padding(
      padding: EdgeInsets.all(16.r),
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
            Text(
              title,
              style: MITITextStyle.plainTextMStyle,
              overflow: TextOverflow.ellipsis,
            ),
            Divider(
              height: 25.h,
              color: const Color(0xFFE8E8E8),
            ),
            Text(
              content,
              style: MITITextStyle.plainTextSStyle.copyWith(
                color: const Color(0xff666666),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              created_at,
              textAlign: TextAlign.end,
              style: MITITextStyle.plainTextSStyle.copyWith(
                color: const Color(0xff666666),
              ),
            )
          ],
        ),
      ),
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

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '답변',
            style: MITITextStyle.sectionTitleStyle,
          ),
          SizedBox(height: 12.h),
          ListView.separated(
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
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String content;
  final String created_at;
  final DateTime modified_at;
  final DateTime? deleted_at;
  final int question;

  const _AnswerCard(
      {super.key,
      required this.content,
      required this.created_at,
      required this.modified_at,
      this.deleted_at,
      required this.question});

  factory _AnswerCard.fromModel({required AnswerModel model}) {
    final created_at = DateFormat('yyyy.MM.dd HH:mm').format(model.created_at);
    return _AnswerCard(
      content: model.content,
      created_at: created_at,
      modified_at: model.modified_at,
      question: model.question,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            content,
            style: MITITextStyle.plainTextSStyle
                .copyWith(color: const Color(0xff666666)),
          ),
          SizedBox(height: 12.h),
          Text(
            created_at,
            style: MITITextStyle.plainTextSStyle
                .copyWith(color: const Color(0xff666666)),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
