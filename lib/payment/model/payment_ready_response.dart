import 'package:json_annotation/json_annotation.dart';
import 'package:miti/common/model/default_model.dart';
import 'package:miti/common/model/entity_enum.dart';
import 'package:miti/payment/model/payment_extra.dart';
import 'package:miti/payment/model/user_payment_response.dart';

part 'payment_ready_response.g.dart';

/*
        "order_id": "GgwJB5AhBdS69WENPjvuQk",
        "order_name": "경기참가비 [[5:5 3파전] MITI 픽업게임..]",
        "item_type": "participation_fee",
        "status": "created",
        "price": 100,
        "tax_free": 0,
        "user": {
            "id": "3",
            "username": "테스트유저2",
            "phone": "01011111111",
            "email": "testuser2@makeittakeit.kr"
        },
        "extra": {
            "common_event_webhook": true,
            "enable_error_webhook": true
        }
 */
@JsonSerializable()
class PaymentReadyResponse extends BaseModel {
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'order_name')
  final String orderName;

  @JsonKey(name: 'item_type')
  final ItemType itemType;

  final String status;

  final int price;

  @JsonKey(name: 'tax_free')
  final int taxFree;

  final UserPaymentResponse user;

  final PaymentExtra? extra;

  PaymentReadyResponse({
    required this.orderId,
    required this.orderName,
    required this.itemType,
    required this.status,
    required this.price,
    required this.taxFree,
    required this.user,
    this.extra,
  });

  factory PaymentReadyResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentReadyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentReadyResponseToJson(this);

  PaymentReadyResponse copyWith({
    String? orderId,
    String? orderName,
    ItemType? itemType,
    String? status,
    int? price,
    int? taxFree,
    UserPaymentResponse? user,
    PaymentExtra? extra,
  }) {
    return PaymentReadyResponse(
      orderId: orderId ?? this.orderId,
      orderName: orderName ?? this.orderName,
      itemType: itemType ?? this.itemType,
      status: status ?? this.status,
      price: price ?? this.price,
      taxFree: taxFree ?? this.taxFree,
      user: user ?? this.user,
      extra: extra ?? this.extra,
    );
  }
}
