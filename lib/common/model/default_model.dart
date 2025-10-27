import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../logger/custom_logger.dart';

part 'default_model.g.dart';

abstract class BaseModel {}

class LoadingModel extends BaseModel {}

@JsonSerializable()
class CompletedModel extends BaseModel {
  final int status_code;
  final String message;
  final String? data;

  CompletedModel({
    required this.status_code,
    required this.message,
    required this.data,
  });

  factory CompletedModel.fromJson(Map<String, dynamic> json) =>
      _$CompletedModelFromJson(json);
}

class ErrorModel<T> extends BaseModel {
  final int status_code;
  final String message;
  final T? data;
  final int error_code;

  ErrorModel({
    required this.status_code,
    required this.message,
    required this.data,
    required this.error_code,
  });

  static ErrorModel respToError(e) {
    logger.e(e);
    switch (e.runtimeType) {
      case DioException:
        final dioException = e as DioException;

        // HTTP 500 에러 특별 처리
        if (dioException.response?.statusCode == 500) {
          return ErrorModel(
            status_code: 500,
            message: '서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
            data: dioException.response?.data ?? '',
            error_code: 0, // 기본값 또는 서버에서 제공하는 error_code
          );
        }

        // 응답이 있는 경우 (4xx, 5xx 등)
        if (dioException.response != null) {
          final resp = dioException.response!.data;

          // 서버 응답이 예상된 형식인지 확인
          if (resp is Map<String, dynamic> &&
              resp.containsKey('status_code') &&
              resp.containsKey('message') &&
              resp.containsKey('error_code')) {
            return ErrorModel(
              status_code: resp['status_code'],
              message: resp['message'],
              data: resp['data'],
              error_code: resp['error_code'],
            );
          } else {
            // 서버 응답이 예상된 형식이 아닌 경우
            return ErrorModel(
              status_code: dioException.response!.statusCode ?? 500,
              message: '서버 응답 형식이 올바르지 않습니다.',
              data: resp,
              error_code: 0,
            );
          }
        }

        // 네트워크 에러 등 응답이 없는 경우
        else {
          String message;
          switch (dioException.type) {
            case DioExceptionType.connectionTimeout:
              message = '연결 시간이 초과되었습니다.';
              break;
            case DioExceptionType.sendTimeout:
              message = '요청 전송 시간이 초과되었습니다.';
              break;
            case DioExceptionType.receiveTimeout:
              message = '응답 수신 시간이 초과되었습니다.';
              break;
            case DioExceptionType.connectionError:
              message = '네트워크 연결에 실패했습니다.';
              break;
            case DioExceptionType.cancel:
              message = '요청이 취소되었습니다.';
              break;
            default:
              message = '네트워크 오류가 발생했습니다.';
          }

          return ErrorModel(
            status_code: 0, // 네트워크 에러는 status_code가 없음
            message: message,
            data: dioException.message,
            error_code: 0,
          );
        }

      default:
        return ErrorModel(
          status_code: 500,
          message: 'JsonSerializable 에러',
          data: '',
          error_code: 0,
        );
    }
  }
}

@JsonSerializable(
  genericArgumentFactories: true,
)
class ResponseModel<T> extends BaseModel {
  final int status_code;
  final String message;
  final T? data;

  ResponseModel({
    required this.status_code,
    required this.message,
    required this.data,
  });

  factory ResponseModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return _$ResponseModelFromJson(json, fromJsonT);
  }

  ResponseModel<T> copyWith({
    int? status_code,
    String? message,
    T? data,
  }) {
    return ResponseModel<T>(
      status_code: status_code ?? this.status_code,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

@JsonSerializable(
  genericArgumentFactories: true,
)
class ResponseListModel<T> extends BaseModel {
  final int status_code;
  final String message;
  final List<T>? data;

  ResponseListModel({
    required this.status_code,
    required this.message,
    required this.data,
  });

  factory ResponseListModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return _$ResponseListModelFromJson(json, fromJsonT);
  }

  ResponseListModel<T> copyWith({
    final int? status_code,
    final String? message,
    final List<T>? data,
  }) {
    return ResponseListModel<T>(
      status_code: status_code ?? this.status_code,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
