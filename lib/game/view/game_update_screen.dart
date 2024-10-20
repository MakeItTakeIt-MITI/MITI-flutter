import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_dialog.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/game/error/game_error.dart';
import 'package:miti/game/provider/game_provider.dart';
import 'package:miti/game/provider/widget/game_form_provider.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../../common/provider/router_provider.dart';
import '../../util/util.dart';
import '../model/game_model.dart';
import 'game_create_screen.dart';
import 'game_detail_screen.dart';

class GameUpdateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'gameUpdate';
  final int gameId;

  const GameUpdateScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameUpdateScreen> createState() => _GameUpdateScreenState();
}

class _GameUpdateScreenState extends ConsumerState<GameUpdateScreen> {
  late final ScrollController _scrollController;
  final formKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  late final List<FocusNode> focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    for (int i = 0; i < 3; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          focusScrollable(i);
        }
      });
    }
  }

  void focusScrollable(int i) {
    Scrollable.ensureVisible(
      formKeys[i].currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    for (int i = 0; i < 3; i++) {
      focusNodes[i].removeListener(() {
        focusScrollable(i);
      });
    }
    _scrollController.dispose();
    super.dispose();
  }

  bool valid() {
    final form = ref.watch(gameFormProvider);
    return form.max_invitation.isNotEmpty &&
        form.min_invitation.isNotEmpty &&
        form.info.isNotEmpty &&
        ValidRegExp.validForm(form.min_invitation, form.max_invitation);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (v) => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const DefaultAppBar(
          title: '경기 수정하기',
          backgroundColor: MITIColor.gray750,
        ),
        backgroundColor: MITIColor.gray750,
        bottomNavigationBar: BottomButton(
          button: TextButton(
            onPressed: valid()
                ? () async {
                    await onUpdate(context);
                  }
                : () {},
            style: TextButton.styleFrom(
                backgroundColor:
                    valid() ? MITIColor.primary : MITIColor.gray500),
            child: Text(
              '저장하기',
              style: MITITextStyle.btnTextBStyle.copyWith(
                color: valid() ? MITIColor.gray800 : MITIColor.gray50,
              ),
            ),
          ),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final result =
                      ref.watch(gameDetailProvider(gameId: widget.gameId));
                  if (result is LoadingModel) {
                    return CircularProgressIndicator();
                  } else if (result is ErrorModel) {
                    GameError.fromModel(model: result)
                        .responseError(context, GameApiType.get, ref);
                    return Text('에러');
                  }
                  result as ResponseModel<GameDetailModel>;
                  final model = result.data!;
                  return Column(
                    children: [
                      SummaryComponent.fromDetailModel(
                        model: model,
                        isUpdateForm: true,
                      ),
                      getDivider(),
                      _GameUpdateFormComponent(
                        initMaxValue: model.max_invitation.toString(),
                        initMinValue: model.min_invitation.toString(),
                        focusNodes: focusNodes,
                        formKeys: formKeys,
                      ),
                      getDivider(),
                      _InfoComponent(
                        info: model.info,
                        focusNodes: focusNodes,
                        formKeys: formKeys,
                      ),
                      SizedBox(height: 80.h),
                      // const Spacer(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onUpdate(BuildContext context) async {
    final result =
        await ref.read(gameUpdateProvider(gameId: widget.gameId).future);
    if (result is ErrorModel) {
      if (context.mounted) {
        GameError.fromModel(model: result)
            .responseError(context, GameApiType.update, ref);
      }
    } else {
      if (context.mounted) {
        showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            builder: (context) {
              return BottomDialog(
                title: '경기 모집 정보 수정 완료',
                content: '경기 정보가 정상적으로 수정되었습니다.',
                btn: TextButton(
                  onPressed: () {
                    Map<String, String> pathParameters = {
                      'gameId': widget.gameId.toString()
                    };

                    context.pop();
                    context.goNamed(
                      GameDetailScreen.routeName,
                      pathParameters: pathParameters,
                    );
                  },
                  child: const Text("확인"),
                ),
              );
            });
      }
    }
  }

  Widget getDivider() {
    return Container(
      height: 5.h,
      color: MITIColor.gray750,
    );
  }
}

class _GameUpdateFormComponent extends ConsumerStatefulWidget {
  final String initMaxValue;
  final String initMinValue;
  final List<GlobalKey> formKeys;
  final List<FocusNode> focusNodes;

  const _GameUpdateFormComponent({
    super.key,
    required this.initMaxValue,
    required this.initMinValue,
    required this.formKeys,
    required this.focusNodes,
  });

  @override
  ConsumerState<_GameUpdateFormComponent> createState() =>
      _GameUpdateFormComponentState();
}

class _GameUpdateFormComponentState
    extends ConsumerState<_GameUpdateFormComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(gameFormProvider.notifier).update(
          max_invitation: widget.initMaxValue,
          min_invitation: widget.initMinValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '참여 인원 수정',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          ApplyForm(
            initMaxValue: widget.initMaxValue,
            initMinValue: widget.initMinValue,
            formKeys: widget.formKeys,
            focusNodes: widget.focusNodes,
            isUpdateForm: true,
          ),
        ],
      ),
    );
  }
}

class _InfoComponent extends ConsumerStatefulWidget {
  final String info;
  final List<GlobalKey> formKeys;
  final List<FocusNode> focusNodes;

  const _InfoComponent({
    super.key,
    required this.info,
    required this.formKeys,
    required this.focusNodes,
  });

  @override
  ConsumerState<_InfoComponent> createState() => _InfoComponentState();
}

class _InfoComponentState extends ConsumerState<_InfoComponent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(gameFormProvider.notifier).update(info: widget.info);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '모집 정보',
            style: MITITextStyle.mdBold.copyWith(
              color: MITIColor.gray100,
            ),
          ),
          SizedBox(height: 20.h),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              reverse: true,
              child: TextFormField(
                focusNode: widget.focusNodes[2],
                key: widget.formKeys[2],
                initialValue: widget.info,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: MITITextStyle.sm150.copyWith(
                  color: MITIColor.gray100,
                ),
                onChanged: (val) {
                  ref.read(gameFormProvider.notifier).update(info: val);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                  constraints: BoxConstraints(
                    minHeight: 68.h,
                    maxHeight: 500.h,
                  ),
                  hintText:
                      '주차, 샤워 가능 여부, 경기 진행 방식, 필요한 유니폼 색상 등 참가들에게 공지할 정보들을 입력해주세요',
                  hintStyle: MITITextStyle.sm150.copyWith(
                    color: MITIColor.gray500,
                  ),
                  hintMaxLines: 10,
                  fillColor: MITIColor.gray700,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  // isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
