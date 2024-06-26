import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/court/view/court_map_screen.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/provider/user_provider.dart';
import 'package:miti/user/view/user_delete_success_screen.dart';

import '../../common/component/default_appbar.dart';
import '../../common/component/default_layout.dart';
import '../error/user_error.dart';

class UserDeleteScreen extends ConsumerStatefulWidget {
  static String get routeName => 'deleteUser';
  final int bottomIdx;

  const UserDeleteScreen({
    super.key,
    required this.bottomIdx,
  });

  @override
  ConsumerState<UserDeleteScreen> createState() => _UserDeleteScreenState();
}

class _UserDeleteScreenState extends ConsumerState<UserDeleteScreen> {
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
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const DefaultAppBar(
              isSliver: true,
              title: '회원탈퇴',
            )
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '회원 탈퇴 안내',
                      style: MITITextStyle.pageMainTextStyle,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '고객님께서 회원 탈퇴를 신청하시면, 관련 법령에 따라 회원님의 정보는 30일간 보관 후 완전히 삭제됩니다.\n이 기간 동안 재가입 신청은 불가능하며, 이후 재가입 시 일정 기간 동안 제한이 있을 수 있습니다.\n\n회원 탈퇴를 진행하시려면, 아래의 \'회원 탈퇴\' 버튼을 클릭해 주시기 바랍니다.\n탈퇴 관련 문의 사항이 있으시면 메뉴의 고객센터를 통해 문의해주시기 바랍니다.',
                      style: MITITextStyle.pageSubTextStyle.copyWith(
                        color: const Color(0xff1c1c1c),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final result =
                            await ref.read(deleteUserProvider.future);
                        if (context.mounted) {
                          if (result is ErrorModel) {
                            UserError.fromModel(model: result).responseError(
                                context, UserApiType.delete, ref);
                          } else {
                            final Map<String, String> queryParameters = {
                              'bottomIdx': widget.bottomIdx.toString(),
                            };
                            context.goNamed(
                              UserDeleteSuccessScreen.routeName,
                              queryParameters: queryParameters,
                            );
                          }
                        }
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF64061)),
                      child: const Text('탈퇴하기'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
