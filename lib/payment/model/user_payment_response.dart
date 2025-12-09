import 'package:json_annotation/json_annotation.dart';

part 'user_payment_response.g.dart';

@JsonSerializable()
class UserPaymentResponse {
  final String? id;
  final String username;
  final String phone;
  final String email;

  UserPaymentResponse({
    required this.id,
    required this.username,
    required this.phone,
    required this.email,
  });

  factory UserPaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$UserPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserPaymentResponseToJson(this);

  UserPaymentResponse copyWith({
    String? id,
    String? username,
    String? phone,
    String? email,
  }) {
    return UserPaymentResponse(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
