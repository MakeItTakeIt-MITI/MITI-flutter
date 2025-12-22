import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:miti/common/component/custom_text_form_field.dart';
import 'package:miti/common/component/default_appbar.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/theme/color_theme.dart';
import 'package:miti/theme/text_theme.dart';
import 'package:miti/user/error/user_error.dart';
import 'package:miti/user/param/user_profile_param.dart';
import 'package:miti/user/provider/user_provider.dart';

import '../../common/component/defalut_flashbar.dart';

class CouponRegistrationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'couponRegistration';
  final bool isReferral;

  const CouponRegistrationScreen({super.key, required this.isReferral});

  @override
  ConsumerState<CouponRegistrationScreen> createState() =>
      _CouponRegistrationScreenState();
}

class _CouponRegistrationScreenState
    extends ConsumerState<CouponRegistrationScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  bool _isTextValid = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_onTextChanged);
    _textFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_onTextChanged);
    _textFocusNode.removeListener(_onFocusChanged);
    _textEditingController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final currentText = _textEditingController.text;
    _validateInput(currentText);
  }

  void _onFocusChanged() {
    if (!_textFocusNode.hasFocus && _textEditingController.text.isNotEmpty) {
      _validateInput(_textEditingController.text);
    }
  }

  void _validateInput(String value) {
    bool isValid;
    String errorMessage = '';

    if (value.isEmpty) {
      isValid = false;
    } else if (widget.isReferral) {
      isValid = validPhone(value);
      if (!isValid && value.isNotEmpty) {
        errorMessage = '올바른 휴대전화 번호 형식이 아닙니다';
      }
    } else {
      isValid = isValid16HexDigits(value);
      if (!isValid && value.isNotEmpty) {
        errorMessage = '16자리 쿠폰 코드를 입력해주세요';
      }
    }

    if (_isTextValid != isValid || _errorMessage != errorMessage) {
      setState(() {
        _isTextValid = isValid;
        _errorMessage = errorMessage;
      });
    }
  }

  bool validPhone(String phone) {
    return RegExp(r"^\d{3}-\d{4}-\d{4}$").hasMatch(phone);
  }

  bool isValid16HexDigits(String input) {
    return RegExp(r'^[0-9a-fA-F]{16}$').hasMatch(input);
  }

  bool get _isValid => _isTextValid;

  Future<void> _onCouponIssue() async {
    if (_isValid) {
      final inputValue = _textEditingController.text;
      if (kDebugMode) {
        print('발급 요청: $inputValue');
      } // 디버깅용

      // TODO: 쿠폰 발급 로직 구현
      final result = await ref.read(registerCouponProvider(
              param: UserCouponRegisterParam(code: inputValue))
          .future);
      if (mounted) {
        if (result is ErrorModel) {
          UserError.fromModel(model: result)
              .responseError(context, UserApiType.registerCoupon, ref);
        } else {
          context.pop();
          Future.delayed(const Duration(milliseconds: 100), () {
            FlashUtil.showFlash(context, '쿠폰이 추가되었습니다!');
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 200.h,
            left: -50.r,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: V2MITIColor.purple5, blurRadius: 150.r)
                ],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 100.h,
            right: -50.r,
            child: Container(
              width: 200.r,
              height: 200.r,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: V2MITIColor.primary5, blurRadius: 150.r)
                ],
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              const DefaultAppBar(
                hasBorder: false,
                backgroundColor: Colors.transparent,
              ),
              Expanded(child: _buildMainContent()),
              _buildBottomButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final title = widget.isReferral ? 'MITI를 소개해준\n유저가 있으신가요?' : 'MITI 쿠폰 발급';
    final subText = widget.isReferral
        ? '소개해준 유저의 휴대전화 번호를 입력하고\n참가비 할인 쿠폰을 받아보세요!'
        : '쿠폰번호를 입력하시고\n다양한 혜택의 쿠폰을 받아보세요!';

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 19.h),
            child: Text(title, style: V2MITITextStyle.title2),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 20.h),
            child: Text(
              subText,
              style: V2MITITextStyle.regularRegularNormal
                  .copyWith(color: V2MITIColor.white),
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    final hintText =
        widget.isReferral ? '추천인 휴대전화 번호를 입력해주세요' : '쿠폰 코드 16자리를 입력해주세요';

    final keyboardType = widget.isReferral ? TextInputType.number : null;
    final inputFormatters = widget.isReferral
        ? <TextInputFormatter>[PhoneNumberFormatter()]
        : <TextInputFormatter>[
            // 16진수만 허용하고 대문자로 변환
            FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
            LengthLimitingTextInputFormatter(16),
            UpperCaseTextFormatter(),
          ];

    return Expanded(
      child: Column(
        children: [
          CustomTextFormField(
            textEditingController: _textEditingController,
            focusNode: _textFocusNode,
            hintText: hintText,
            borderColor: _textFocusNode.hasFocus
                ? (_isValid ? V2MITIColor.primary5 : V2MITIColor.red5)
                : V2MITIColor.gray6,
            onChanged: (value) {
              // 추가 로직이 필요한 경우 여기에 구현
            },
            onNext: () {},
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
          // 에러 메시지 표시
          if (_errorMessage.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              child: Text(
                _errorMessage,
                style: V2MITITextStyle.smallMediumNormal.copyWith(
                  color: V2MITIColor.red5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      height: 89.h,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      child: SizedBox(
        height: 44.h,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isValid ? _onCouponIssue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isValid ? V2MITIColor.primary5 : V2MITIColor.gray7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 10.h),
          ),
          child: Text(
            '쿠폰 발급받기',
            style: V2MITITextStyle.regularBold.copyWith(
              color: _isValid ? V2MITIColor.black : V2MITIColor.white,
            ),
          ),
        ),
      ),
    );
  }
}

// 16진수를 대문자로 변환하는 Formatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// 유틸리티 함수들
extension PhoneNumberFormat on String {
  String formatPhoneNumber() {
    final digits = replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 3) return digits;
    if (digits.length <= 7) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    }
    if (digits.length <= 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7, 11)}';
  }
}

// 모델 클래스 (필요시 사용)
class ReferralRequest {
  final String phoneNumber;

  const ReferralRequest({
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
    };
  }

  factory ReferralRequest.fromJson(Map<String, dynamic> json) {
    return ReferralRequest(
      phoneNumber: json['phoneNumber'] as String,
    );
  }
}

class ReferralResponse {
  final bool success;
  final String? couponId;
  final String? message;

  const ReferralResponse({
    required this.success,
    this.couponId,
    this.message,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      success: json['success'] as bool,
      couponId: json['couponId'] as String?,
      message: json['message'] as String?,
    );
  }
}
